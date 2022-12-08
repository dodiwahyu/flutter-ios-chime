import Flutter
import UIKit
import AmazonChimeSDK
import SVProgressHUD

enum FLUTTER_METHOD: String {
    case hideLoading
    case showToast
    case joinMeeting
    case endMeeting
    case meetingBeingRecorded
    case meetingStopRecording
    case test
}

public class SwiftIosChimePlugin: NSObject, FlutterPlugin {
    var logger = ConsoleLogger(name: "ios_chime")
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_chime", binaryMessenger: registrar.messenger())
        let instance = SwiftIosChimePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "IOSChimePluginEvents", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(APPStreamHandler.shared)
        
        let bundle = Bundle.main
        let fonts = [
            "assets/fonts/Poppins-Regular.ttf",
            "assets/fonts/Poppins-Medium.ttf",
            "assets/fonts/Poppins-Bold.ttf"
        ]
        
        for font in fonts {
            let fontKey = registrar.lookupKey(forAsset: font)
            let path = bundle.path(forResource: fontKey, ofType: nil)
            let fontData = NSData(contentsOfFile: path ?? "")
            let dataProvider = CGDataProvider(data: fontData!)
            let fontRef = CGFont(dataProvider!)
            var errorRef: Unmanaged<CFError>? = nil
            if let fr = fontRef {
             CTFontManagerRegisterGraphicsFont(fr, &errorRef)
            } else {
                print("Failed to register font \(font)")
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = FLUTTER_METHOD(rawValue: call.method) else {
            logger.error(msg: "\(call.method) not registered!")
            return
        }
        logger.info(msg: "invokking \(method)")
        
        switch method {
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
        case .test:
            handleTest()
            break
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
    
    private func handleTest() {
        let fontRegular = UIFont(name: "Poppins-Regular", size: 12.0)
        let fontMedium = UIFont(name: "Poppins-Medium", size: 12.0)
        let fontBold = UIFont(name: "Poppins-Bold", size: 12.0)
//        print("Poppins-Regular  \(fontRegular != nil)")
        
        guard let topController = UIApplication.getTopViewController() else {
            return
        }
        
//        DialogVC.show(from: topController, title: "Confirmation", message: "Are you sure want to end the call?", onYes: nil, onNo: nil)
        

        let attendee = AttendeeEntity(externalUserId: "", attendeeId: "", joinToken: "")
        let meeting = CreateMeetingResponse(meeting: Meeting(externalMeetingId: "", mediaPlacement: MediaPlacement(audioFallbackUrl: "", audioHostUrl: "", signalingUrl: "", turnControlUrl: ""), mediaRegion: "", meetingId: ""))
        let attendeRes = CreateAttendeeResponse(attendee: Attendee(attendeeId: "", externalUserId: "", joinToken: ""))

        let viewModel = VideoConferenceVM(uuid: UUID().uuidString, spajNumber: "", attendee: attendee, createMeetingResponse: meeting, createAttendeeResponse: attendeRes, isAsAgent: true)
        let vc = VideoConferenceViewController()
        vc.viewModel = viewModel
        vc.modalPresentationStyle = .fullScreen

        topController.present(vc, animated: true)
        
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
