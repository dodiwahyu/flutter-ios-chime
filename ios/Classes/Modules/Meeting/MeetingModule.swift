//
//  MeetingModule.swift
//  tmchime-sdk
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import AmazonChimeSDK
import AVFoundation
import UIKit


class MeetingModule {
    static var shared: MeetingModule = MeetingModule()
    private let logger = FlutterLogger(name: "MeetingModule")
    
    var onEndMeeting: (() -> Void)?
    var onMeetingBeignRecorded: (() -> Void)?
    var onMeetingStopRecording: (() -> Void)?
    var onJoinRoomByAgent: ((Bool) -> Void)?
    
    /**
     Method to clear all session in this module.
     This method called when `VideoConferenceViewController` did disappear
     */
    func clear() {
        self.onEndMeeting = nil
        self.onMeetingBeignRecorded = nil
        self.onMeetingStopRecording = nil
        self.onJoinRoomByAgent = nil
    }
    
    /**
     In this part we need to check microphone access permission and camera access permissin are `Granted` by user.
     If not do nothing.
     
     We use `DispatchGroup` to manage process multiple request permission.
     When process are completed, do init view controller meeting and present it to most top of controller from stack.
     
     - Parameter sessionEntity: `MeetingSessionEntity`
     - Parameter completion: `Bool` return callBack
     */
    func prepareMeeting(sessionEntity: MeetingSessionEntity,
                        completion: ((Bool) -> Void)? = nil) {
        
        guard let topController = UIApplication.getTopViewController() else {
            logger.fault(msg: "Top Controller not found")
            completion?(false)
            return
        }
        
        var isMicEnabled = false
        var isCameraEnabled = false
        
        let queueQroup = DispatchGroup()
        
        queueQroup.notify(queue: .main) { [weak self] in
            if isMicEnabled, isCameraEnabled {
                guard let meetingUUID = sessionEntity.uuid,
                      let spajNumber = sessionEntity.spajNumber,
                      let attendee = sessionEntity.attendee,
                      let meetingResponse = sessionEntity.getMeetingResponse(),
                      let attendeeResponse = sessionEntity.getAttendeeResponse()
                else {
                    self?.logger.fault(msg: "SessionEntity not valid ")
                    completion?(false)
                    return
                }
                
                let asAgent = sessionEntity.asAgent ?? false
                let vm = VideoConferenceVM(
                    uuid: meetingUUID,
                    spajNumber: spajNumber,
                    attendee: attendee,
                    createMeetingResponse: meetingResponse,
                    createAttendeeResponse: attendeeResponse,
                    wordingTextAgent: sessionEntity.wordingTextAgent,
                    wordingTextClient: sessionEntity.wordingTextClient,
                    recordDate: sessionEntity.recordDate,
                    isAsAgent: asAgent
                )
                let vc = VideoConferenceViewController()
                vc.viewModel = vm
                vc.modalPresentationStyle = .fullScreen
                
                topController.present(vc, animated: true) {
                    completion?(true)
                }
                
                self?.onEndMeeting = {
                    vm.stopMeeting {
                        vc.dismiss(animated: true) { [weak self] in
                            self?.clear()
                        }
                    }
                }
                
                self?.onMeetingBeignRecorded = {
                    vm.meetingBeingRecorded()
                }
                
                self?.onMeetingStopRecording = {
                    vm.meetingStopRecording()
                }
                
                self?.onJoinRoomByAgent = { isSuccess in
                    vm.setJoinRoomByAgent(isSuccess)
                }
            }
        }
        
        queueQroup.enter()
        queueQroup.enter()
        
        MeetingModule.shared.requestRecordPermission { isEnabled in
            isMicEnabled = true
            queueQroup.leave()
        }
        
        MeetingModule.shared.requestVideoPermission { isEnabled in
            isCameraEnabled = isMicEnabled
            queueQroup.leave()
        }
    }
    
    /**
     Request audiosession with completion
     - Parameter completion: `Bool` return callback
     */
    func requestRecordPermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .denied:
            logger.error(msg: "User did not grant audio permission, it should redirect to Settings")
            completion(false)
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    completion(true)
                } else {
                    self.logger.error(msg: "User did not grant audio permission")
                    completion(false)
                }
            }
        case .granted:
            completion(true)
        @unknown default:
            logger.error(msg: "Audio session record permission unknown case detected")
            completion(false)
        }
    }

    /**
     Request camera video permission with completion
     - Parameter completion: `Boo` return callBack
     */
    func requestVideoPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            logger.error(msg: "User did not grant video permission, it should redirect to Settings")
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    completion(true)
                } else {
                    self.logger.error(msg: "User did not grant video permission")
                    completion(false)
                }
            }
        case .authorized:
            completion(true)
        @unknown default:
            logger.error(msg: "AVCaptureDevice authorizationStatus unknown case detected")
            completion(false)
        }
    }

    /**
     Configure audio session before start metting session
     */
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                             options: AVAudioSession.CategoryOptions.allowBluetooth)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
            if audioSession.mode != .voiceChat {
                try audioSession.setMode(.voiceChat)
            }
        } catch {
            logger.error(msg: "Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }
}

