//
//  MeetingModule.swift
//  tmchime-sdk
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import AmazonChimeSDK
import AVFoundation
import UIKit

let incomingCallKitDelayInSeconds = 10.0

class MeetingModule {
    static var shared: MeetingModule = MeetingModule()
    private let logger = FlutterLogger(name: "MeetingModule")
    
    var onEndMeeting: (() -> Void)?
    
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
                guard let meeting = sessionEntity.getMeeting(),
                      let attendee = sessionEntity.getAttendee()
                else {
                    self?.logger.fault(msg: "SessionEntity not valid ")
                    completion?(false)
                    return
                }

                let meetingSessionConfig = MeetingSessionConfiguration(
                    createMeetingResponse: meeting,
                    createAttendeeResponse: attendee
                )
                
                let vm = VideoConferenceVM(configuration: meetingSessionConfig)
                let vc = VideoConferenceViewController()
                vc.viewModel = vm
                vc.modalPresentationStyle = .fullScreen
                
                topController.present(vc, animated: true) {
                    completion?(true)
                }
                
                self?.onEndMeeting = {[weak self] in
                    vm.stopMeeting {[weak self] in
                        vc.dismiss(animated: true) {[weak self] in
                            self?.onEndMeeting = nil
                        }
                    }
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

