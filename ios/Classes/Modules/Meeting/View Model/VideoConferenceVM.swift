//
//  VideoConferenceVM.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation
import AmazonChimeSDK
import AmazonChimeSDKMedia
import SVProgressHUD
import AVFAudio

let MAX_RECORD_TIME: Double = 10
let WARNING_RECORD_TIME: Double = 5

protocol VideoConferenceVMOutput: AnyObject {
    func vmDidBindLocalScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmDidBindContentScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmDidUnBindLocalScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmDidUnBindContentScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmVideoTileSizeDidChange(for session: DefaultMeetingSession, tileId: Int, size: CGSize)
    func vmSessionDidEnd()
}

class VideoConferenceVM {
    let logger = FlutterLogger(name: "VideoConferenceVM")
    weak var output: VideoConferenceVMOutput?
    
    var meetingUUID: String!
    var spajNumber: String!
    var currentAttendee: AttendeeEntity!
    var isAsAgent: Bool = false
    var wordingText: String?
    
    var audioVideoConfig = AudioVideoConfiguration(audioMode: .stereo48K)
    var meetingSessionConfig: MeetingSessionConfiguration!
    var meetingSession: DefaultMeetingSession!
    var listAttendeeJoinded: [AttendeeInfo] = []
    var isRecording: Bool = false
    var isJoinned: Bool?
    
    let timeFormater = DateComponentsFormatter()
    let minuteFormatter = DateComponentsFormatter()
    
    // Timer
    private var startTime: Date?
    private var maxRecordTime: Date?
    private var recordTimer: Timer?
    
    
    var onTimeDidTick: ((String) -> Void)?
    var onTimeAlert: ((String) -> Void)?
    var onTimesup: (() -> Void)?
    
    var onRecordingDidStarted: (() -> Void)?
    var onRecordingDidStopped: (() -> Void)?
    
    
    var eventSink: FlutterEventSink? {
        return APPStreamHandler.shared.getEventSink()
    }
    
    var audioDevices: [MediaDevice] {
        return meetingSession.audioVideo.listAudioDevices()
    }
    
    var currentAudioDevice: MediaDevice? {
        get {
            meetingSession.audioVideo.getActiveAudioDevice()
        }
        
        set {
            guard let new = newValue else { return }
            meetingSession.audioVideo.chooseAudioDevice(mediaDevice: new)
        }
    }
    
    var isMute: Bool = false {
        didSet {
            if isMute {
                let status = meetingSession.audioVideo.realtimeLocalMute()
                logger.info(msg: status ? "mute success" : "mute failed")
            } else {
                let status = meetingSession.audioVideo.realtimeLocalUnmute()
                logger.info(msg: status ? "unmute success": "unmute failed")
            }
        }
    }
    
    var enableCamera: Bool = true {
        didSet {
            do {
                if enableCamera {
                    try self.meetingSession.audioVideo.startLocalVideo()
                } else {
                    self.meetingSession.audioVideo.stopLocalVideo()
                }
            } catch {
                logger.info(msg: error.localizedDescription)
            }
        }
    }
    
    private(set) var isEnded: Bool = false {
        didSet {
            guard isEnded else { return }
            meetingSession.audioVideo.stop()
        }
    }
    
    /**
     - Parameter uuid: `String`; UUID from response get meeting detail
     - Parameter attendee:`AttendeeEntity`
     */
    init(uuid: String,
         spajNumber: String,
         attendee: AttendeeEntity,
         createMeetingResponse: AmazonChimeSDK.CreateMeetingResponse,
         createAttendeeResponse: AmazonChimeSDK.CreateAttendeeResponse,
         wordingText: String?,
         isAsAgent: Bool
    ) {
        self.meetingUUID = uuid
        self.spajNumber = spajNumber
        self.currentAttendee = attendee
        self.wordingText = wordingText
        self.isAsAgent = isAsAgent
        self.meetingSessionConfig = MeetingSessionConfiguration(
            createMeetingResponse: createMeetingResponse,
            createAttendeeResponse: createAttendeeResponse
        )
        self.meetingSession = DefaultMeetingSession(
            configuration: self.meetingSessionConfig,
            logger: self.logger.chimeLogger
        )
        
        timeFormater.unitsStyle = .positional
        timeFormater.allowedUnits = [.hour, .minute, .second]
        timeFormater.zeroFormattingBehavior = .pad
        
        minuteFormatter.unitsStyle = .positional
        minuteFormatter.allowedUnits = [.minute, .second]
        minuteFormatter.zeroFormattingBehavior = .pad
    }
    
    func addObserver() {
        meetingSession.audioVideo.addRealtimeObserver(observer: self)
        meetingSession.audioVideo.addAudioVideoObserver(observer: self)
        meetingSession.audioVideo.addVideoTileObserver(observer: self)
        meetingSession.audioVideo.addDeviceChangeObserver(observer: self)
        meetingSession.audioVideo.addActiveSpeakerObserver(policy: DefaultActiveSpeakerPolicy(), observer: self)
        meetingSession.eventAnalyticsController.addEventAnalyticsObserver(observer: self)
    }
    
    func removeObserver() {
        meetingSession.audioVideo.removeAudioVideoObserver(observer: self)
        meetingSession.audioVideo.removeRealtimeObserver(observer: self)
        meetingSession.audioVideo.removeVideoTileObserver(observer: self)
        meetingSession.audioVideo.removeDeviceChangeObserver(observer: self)
        meetingSession.audioVideo.removeActiveSpeakerObserver(observer: self)
        meetingSession.eventAnalyticsController.removeEventAnalyticsObserver(observer: self)
    }
    
    func startMeeting(completion: ((Bool) -> Void)? = nil) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord,options: AVAudioSession.CategoryOptions.allowBluetooth)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
            
            if audioSession.mode != .voiceChat {
                try audioSession.setMode(.voiceChat)
            }
            
            try self.meetingSession.audioVideo.start(audioVideoConfiguration: self.audioVideoConfig)
            try self.meetingSession.audioVideo.startLocalVideo()
            self.meetingSession.audioVideo.startRemoteVideo()
            completion?(true)
        } catch {
            logger.error(msg: "Error configuring AVAudioSession: \(error.localizedDescription)")
            completion?(false)
        }
    }
    
    func startLocalVideo(completion: BoolCompletion? = nil) {
        do {
            try meetingSession.audioVideo.startLocalVideo()
            requestJoinRoomByAgent()
            completion?(true)
        } catch {
            logger.error(msg: error.localizedDescription)
            completion?(false)
        }
    }
    
    func stopLocalVideo() {
        meetingSession.audioVideo.stopLocalVideo()
    }
    
    func pauseRemoteVideoTile(tileId: Int) {
        meetingSession.audioVideo.pauseRemoteVideoTile(tileId: tileId)
    }
    
    func mute(completion: ((Bool) -> Void)? = nil) {
        let status = meetingSession.audioVideo.realtimeLocalMute()
        completion?(status)
    }
    
    func unMute(completion: ((Bool) -> Void)? = nil) {
        let status = meetingSession.audioVideo.realtimeLocalUnmute()
        completion?(status)
    }
    
    func resetTimerRecord() {
        recordTimer?.invalidate()
        recordTimer = nil
        startTime = nil
    }
}

extension VideoConferenceVM {
    func stopRecordTimer() {
        recordTimer?.invalidate()
        recordTimer = nil
        onTimesup?()
    }
    
    func fireTimeRecord() {
        guard recordTimer == nil else { return }
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeRecordDidFire(_:)), userInfo: nil, repeats: true)
        maxRecordTime = Date().addingTimeInterval(TimeInterval(MAX_RECORD_TIME * 60))
        recordTimer = timer
        recordTimer?.fire()
    }
    
    @objc
    private func timeRecordDidFire(_ sender: Timer) {
        let startDate = startTime ?? Date()
        let now = Date()
        let elapsed = now - startDate
        
        let max: Double = Double(60 * MAX_RECORD_TIME) // 10 minutes
        if (elapsed <= max) {
            if let strElapsed = timeFormater.string(from: elapsed) {
                self.onTimeDidTick?(strElapsed)
            }
            
            if let endTime = self.maxRecordTime,
               elapsed >= (max - Double(60 * WARNING_RECORD_TIME)) {
                let remaining = endTime - now
                if let strRemaining = minuteFormatter.string(from: remaining) {
                    self.onTimeAlert?(strRemaining)
                }
            }
        } else {
            stopRecordTimer()
        }
        
        startTime = startDate
    }
}

// Comunting with dart
extension VideoConferenceVM {
    func requestEndMeeting() {
        SVProgressHUD.show()
        let meetingId = meetingSessionConfig.meetingId
        do {
            let payload = try AppEventType.MeetingSessionRequestEnd.payload(args: ["MeetingID": meetingId])
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
    }
    
    func requestRecordAll() {
        do {
            let payload = try AppEventType.ReqRecordMeetingAll
                .payload(args: ["uuid": meetingUUID])
            SVProgressHUD.show()
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
    }
    
    func requestRecordAttendee() {
        do {
            let payload = try AppEventType.ReqRecordMeetingAttendee
                .payload(args: [
                    "uuid": meetingUUID,
                    "attendeeId": currentAttendee.attendeeId
                ])
            
            SVProgressHUD.show()
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
    }
    
    func requestStopRecording() {
        do {
            let payload = try AppEventType.StopRecordMeeting.payload(args: ["uuid": meetingUUID])
            SVProgressHUD.show()
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
    }
    
    func requestJoinRoomByAgent() {
        guard isJoinned == nil else { return }
        
        isJoinned = false
        
        do {
            let payload = try AppEventType.JoinRoomByAgent.payload(args: ["SpajNumber": spajNumber])
            SVProgressHUD.show()
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
    }
}

// Response from dart
extension VideoConferenceVM {
    func meetingBeingRecorded(_ completion: DefaultPluginCompletion? = nil) {
        SVProgressHUD.showSuccess(withStatus: "Start recording")
        isRecording = true
        onRecordingDidStarted?()
        fireTimeRecord()
        completion?()
    }
    
    func meetingStopRecording(_ completion: DefaultPluginCompletion? = nil) {
        SVProgressHUD.showSuccess(withStatus: "Recording did stopped")
        isRecording = false
        completion?()
    }
    
    func stopMeeting(_ completion: DefaultPluginCompletion? = nil) {
        meetingSession.audioVideo.stop()
        isRecording = false
        recordTimer?.invalidate()
        recordTimer = nil
        completion?()
    }
    
    // If Join Room By Agent failed set `isJoinned` to nil
    // If success set `isJoinned` true
    func setJoinRoomByAgent(_ isSuccess: Bool) {
        isJoinned = isSuccess ? true : nil
        SVProgressHUD.dismiss()
    }
}

extension VideoConferenceVM: VideoTileObserver {
    func videoTileDidAdd(tileState: AmazonChimeSDK.VideoTileState) {
        if tileState.isLocalTile {
            output?.vmDidBindLocalScreen(for: meetingSession, tileId: tileState.tileId)
        } else {
            // Set secondary screen
            output?.vmDidBindContentScreen(for: meetingSession, tileId: tileState.tileId)
            
            // Need update secondary screen aspect ratio
            let size = CGSize(width: CGFloat(tileState.videoStreamContentWidth), height: CGFloat(tileState.videoStreamContentHeight))
            output?.vmVideoTileSizeDidChange(for: meetingSession, tileId: tileState.tileId, size: size)
        }
        
        logger.info(msg: "ios_chime ==> videoTileDidAdd id \(tileState.tileId)")
    }
    
    func videoTileDidRemove(tileState: AmazonChimeSDK.VideoTileState) {
        if let index = self.listAttendeeJoinded.firstIndex(where: {$0.attendeeId == tileState.attendeeId}) {
            self.listAttendeeJoinded.remove(at: index)
        }
        
        meetingSession.audioVideo.unbindVideoView(tileId: tileState.tileId)
        
        if tileState.isLocalTile {
            output?.vmDidUnBindLocalScreen(for: meetingSession, tileId: tileState.tileId)
        } else {
            output?.vmDidUnBindContentScreen(for: meetingSession, tileId: tileState.tileId)
        }
        
        logger.info(msg: "ios_chime ==> videoTileDidRemove id \(tileState.tileId)")
    }

    func videoTileDidPause(tileState: AmazonChimeSDK.VideoTileState) {
        logger.info(msg: "ios_chime ==> videoTileDidPause id \(tileState.tileId)")
    }
    
    func videoTileDidResume(tileState: AmazonChimeSDK.VideoTileState) {
        logger.info(msg: "ios_chime ==> videoTileDidResume id \(tileState.tileId)")
    }
    
    func videoTileSizeDidChange(tileState: AmazonChimeSDK.VideoTileState) {
        let size = CGSize(width: CGFloat(tileState.videoStreamContentWidth), height: CGFloat(tileState.videoStreamContentHeight))
        
        if tileState.isLocalTile {
            // Do nothing
        } else {
            output?.vmVideoTileSizeDidChange(for: meetingSession, tileId: tileState.tileId, size: size)
        }
    }
    
}

extension VideoConferenceVM: AudioVideoObserver {
    func audioSessionDidStartConnecting(reconnecting: Bool) {
        
    }
    
    func audioSessionDidStart(reconnecting: Bool) {
        
    }
    
    func audioSessionDidDrop() {
        
    }
    
    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        
    }
    
    func audioSessionDidCancelReconnect() {
        
    }
    
    func connectionDidRecover() {
        
    }
    
    func connectionDidBecomePoor() {
        
    }
    
    func videoSessionDidStartConnecting() {
        logger.info(msg: "ios_chime ==> Session did start connecting")
    }
    
    func videoSessionDidStartWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "ios_chime ==> video did start with status \(sessionStatus)")
    }
    
    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        if sessionStatus.statusCode == .audioServerHungup || sessionStatus.statusCode == .videoServiceUnavailable {
            stopMeeting() {[weak self] in
                self?.output?.vmSessionDidEnd()
            }
        }
        
        logger.info(msg: "ios_chime ==> video did stop with status \(sessionStatus.statusCode)")
    }
    
    func remoteVideoSourcesDidBecomeAvailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        
    }
    
    func remoteVideoSourcesDidBecomeUnavailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        
    }
    
    func cameraSendAvailabilityDidChange(available: Bool) {
        
    }
    
}


extension VideoConferenceVM: ActiveSpeakerObserver {
    var observerId: String {
        return ""
    }
    
    func activeSpeakerDidDetect(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        
    }
}


extension VideoConferenceVM: RealtimeObserver {
    func volumeDidChange(volumeUpdates: [AmazonChimeSDK.VolumeUpdate]) {
        
    }
    
    func signalStrengthDidChange(signalUpdates: [AmazonChimeSDK.SignalUpdate]) {
        
    }
    
    func attendeesDidJoin(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "ios_chime ==> attendeesDidJoin APP => \(attendeeInfo)")
        
        for info in attendeeInfo {
            if !listAttendeeJoinded.contains(where: {$0.attendeeId == info.attendeeId}) {
                listAttendeeJoinded.append(info)
            }
            
            if currentAttendee.attendeeId == info.attendeeId {
                requestJoinRoomByAgent()
            }
        }
    
        // Is there one other attendee?
        // If yes start record all
        if !isRecording,
           listAttendeeJoinded.first(where: {
               $0.attendeeId != currentAttendee.attendeeId
           }) != nil {
            
            // For AMS
            self.fireTimeRecord()
        }
    }
    
    func attendeesDidLeave(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        
    }
    
    func attendeesDidDrop(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        
    }
    
    func attendeesDidMute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        
    }
    
    func attendeesDidUnmute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        
    }
}




extension VideoConferenceVM: DeviceChangeObserver {
    func audioDeviceDidChange(freshAudioDeviceList: [AmazonChimeSDK.MediaDevice]) {
        
    }
}


extension VideoConferenceVM: EventAnalyticsObserver {
    func eventDidReceive(name: AmazonChimeSDK.EventName, attributes: [AnyHashable : Any]) {
        print("\n")
        print("event-name => \(name) attributes: \(attributes)")
        print("\n")
    }
}
