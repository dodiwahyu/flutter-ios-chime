import Flutter
import UIKit
import AmazonChimeSDK
import SVProgressHUD

enum FLUTTER_METHOD: String {
    case getPlatformVersion
    case hideLoading
    case showToast
    case joinMeeting
    case endMeeting
    case meetingBeingRecorded
    case meetingStopRecording
}

public class SwiftIosChimePlugin: NSObject, FlutterPlugin {
    var logger = ConsoleLogger(name: "ios_chime")
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_chime", binaryMessenger: registrar.messenger())
        let instance = SwiftIosChimePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "IOSChimePluginEvents", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(APPStreamHandler.shared)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = FLUTTER_METHOD(rawValue: call.method) else {
            logger.error(msg: "\(call.method) not registered!")
            return
        }
        logger.info(msg: "invokking \(method)")
        
        switch method {
        case .getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
        case .hideLoading:
            SVProgressHUD.dismiss()
        case .showToast:
            SVProgressHUD.showError(withStatus: call.arguments as? String)
        case .joinMeeting:
            handleJoinMeeting(args: call.arguments, result: result)
        case .endMeeting:
            handleEndMeeting(result: result)
        case .meetingBeingRecorded:
            handleMeetingBeingRecorded(args: call.arguments, result: result)
        case .meetingStopRecording:
            handleMeetingStopRecording(args: call.arguments, result: result)
        }
    }
    
    private func handleJoinMeeting(args: Any?, result: @escaping FlutterResult) {
        guard let json: String = args as? String else
        {
            logger.error(msg: "invalid parameter")
            return
        }
        
        guard let sessionEntity = json.toObject(MeetingSessionEntity.self) else {
            logger.error(msg: "invalid object")
            return
        }
        
        MeetingModule.shared.prepareMeeting(sessionEntity: sessionEntity)
    }
    
    private func handleEndMeeting(result: @escaping FlutterResult) {
        MeetingModule.shared.onEndMeeting?()
    }
    
    private func handleMeetingBeingRecorded(args: Any?, result: @escaping FlutterResult) {
        MeetingModule.shared.onMeetingBeignRecorded?()
    }
    
    private func handleMeetingStopRecording(args: Any?, result: @escaping FlutterResult) {
        MeetingModule.shared.onMeetingStopRecording?()
    }
}


class APPStreamHandler: NSObject, FlutterStreamHandler {
    private static var _exampleStreamHandler : APPStreamHandler?
    
    private var _eventSink: FlutterEventSink?
    
    public static let shared: APPStreamHandler = APPStreamHandler()

    public func getEventSink() -> FlutterEventSink? {
        return _eventSink
    }
        
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("ExampleStreamHandler onListen")
        _eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        print("ExampleStreamHandler onCancel")
        return nil
    }
}
