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

let MAX_RECORD_TIME: Double = 2
let WARNING_RECORD_TIME: Double = 1

protocol VideoConferenceVMOutput: AnyObject {
    func vmDidBindLocalScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmDidBindContentScreen(for session: DefaultMeetingSession, tileId: Int)
}

class VideoConferenceVM {
    let logger = FlutterLogger(name: "VideoConferenceVM")
    weak var output: VideoConferenceVMOutput?
    
    var meetingUUID: String!
    var currentAttendee: AttendeeEntity!
    var isAsAgent: Bool = false
    
    var audioVideoConfig = AudioVideoConfiguration(audioMode: .stereo48K)
    var meetingSessionConfig: MeetingSessionConfiguration!
    var meetingSession: DefaultMeetingSession!
    var listAttendeeJoinded: [AttendeeInfo] = []
    var isRecording: Bool = false
    
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
         attendee: AttendeeEntity,
         createMeetingResponse: AmazonChimeSDK.CreateMeetingResponse,
         createAttendeeResponse: AmazonChimeSDK.CreateAttendeeResponse,
         isAsAgent: Bool
    ) {
        self.meetingUUID = uuid
        self.currentAttendee = attendee
        self.isAsAgent = isAsAgent
        self.meetingSessionConfig = MeetingSessionConfiguration(
            createMeetingResponse: createMeetingResponse,
            createAttendeeResponse: createAttendeeResponse
        )
        self.meetingSession = DefaultMeetingSession(
            configuration: self.meetingSessionConfig,
            logger: self.logger.chimeLogger
        )
    }
    
    func addObserver() {
        meetingSession.audioVideo.addAudioVideoObserver(observer: self)
        meetingSession.audioVideo.addRealtimeObserver(observer: self)
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
            MeetingModule.shared.configureAudioSession()
            try meetingSession.audioVideo.start(audioVideoConfiguration: audioVideoConfig)
            meetingSession.audioVideo.startRemoteVideo()
            completion?(true)
        } catch {
            logger.error(msg: error.localizedDescription)
            completion?(false)
        }
    }
    
    func startLocalVideo(completion: BoolCompletion? = nil) {
        do {
            try meetingSession.audioVideo.startLocalVideo()
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
        if recordTimer == nil {
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeRecordDidFire(_:)), userInfo: nil, repeats: true)
            recordTimer = timer
        }
        
        recordTimer?.fire()
        maxRecordTime = Date().addingTimeInterval(TimeInterval(MAX_RECORD_TIME * 60))
    }
    
    @objc
    private func timeRecordDidFire(_ sender: Timer) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        let startDate = startTime ?? Date()
        let now = Date()
        let elapsed = now - startDate
        
        let max: Double = Double(60 * MAX_RECORD_TIME) // 10 minutes
        if (elapsed <= max) {
            if let strElapsed = formatter.string(from: elapsed) {
                self.onTimeDidTick?(strElapsed)
            }
            
            if let endTime = self.maxRecordTime,
               elapsed >= (max - Double(60 * WARNING_RECORD_TIME)) {
                let remaining = endTime - now
                if let strRemaining = formatter.string(from: remaining) {
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
        completion?()
    }
}

extension VideoConferenceVM: VideoTileObserver {
    func videoTileDidAdd(tileState: AmazonChimeSDK.VideoTileState) {
        if tileState.isLocalTile {
            output?.vmDidBindLocalScreen(for: meetingSession, tileId: tileState.tileId)
        } else {
            // TODO: Screen share & Video
            output?.vmDidBindContentScreen(for: meetingSession, tileId: tileState.tileId)
        }
        print("TEST ==> videoTileDidAdd id \(tileState.tileId)")
    }
    
    func videoTileDidRemove(tileState: AmazonChimeSDK.VideoTileState) {
        meetingSession.audioVideo.unbindVideoView(tileId: tileState.tileId)
        print("TEST ==> videoTileDidRemove id \(tileState.tileId)")
    }
    
    func videoTileDidPause(tileState: AmazonChimeSDK.VideoTileState) {
        print("TEST ==> videoTileDidPause id \(tileState.tileId)")
    }
    
    func videoTileDidResume(tileState: AmazonChimeSDK.VideoTileState) {
        print("TEST ==> videoTileDidResume id \(tileState.tileId)")
    }
    
    func videoTileSizeDidChange(tileState: AmazonChimeSDK.VideoTileState) {
        
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
        print("Session did start connecting")
    }
    
    func videoSessionDidStartWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        print("vide did statr with status \(sessionStatus)")
    }
    
    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        
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
        print("attendeesDidJoin APP => \(attendeeInfo)")
        
        for info in attendeeInfo {
            if !listAttendeeJoinded.contains(where: {$0.attendeeId == info.attendeeId}) {
                listAttendeeJoinded.append(info)
            }
        }
    
        // Is there one other attendee?
        // If yes start record all
        if !isRecording,
           listAttendeeJoinded.first(where: {
               $0.attendeeId != currentAttendee.attendeeId
           }) != nil {
            self.requestRecordAll()
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
