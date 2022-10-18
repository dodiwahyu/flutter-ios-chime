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

protocol VideoConferenceVMOutput: AnyObject {
    func vmDidBindLocalScreen(for session: DefaultMeetingSession, tileId: Int)
    func vmDidBindContentScreen(for session: DefaultMeetingSession, tileId: Int)
}

class VideoConferenceVM {
    weak var output: VideoConferenceVMOutput?
    var eventSink: FlutterEventSink? {
        return APPStreamHandler.shared.getEventSink()
    }
    
    
    var audioVideoConfig = AudioVideoConfiguration(audioMode: .stereo48K)
    var meetingSessionConfig: MeetingSessionConfiguration!
    var meetingSession: DefaultMeetingSession!
    let logger = FlutterLogger(name: "VideoConferenceVM")
    
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
    
    init(configuration: MeetingSessionConfiguration) {
        self.meetingSessionConfig = configuration
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
    
    func stopMeeting(_ completion: (() -> Void)? = nil) {
        meetingSession.audioVideo.stop()
        completion?()
    }
    
    func startLocalVideo(completion: ((Bool) -> Void)? = nil) {
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
    
    func requestEndMeeting() {
        SVProgressHUD.show()
        let meetingId = meetingSessionConfig.meetingId
        do {
            let payload = try AppEventType.MettingSessionRequestEnd.payload(args: ["MeetingID": meetingId])
            eventSink?(payload)
        } catch {
            logger.fault(msg: error.localizedDescription)
        }
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
