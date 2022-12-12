import 'package:flutter/services.dart';

import 'ios_chime_platform_interface.dart';

class IosChime {
  static const EventChannel _eventChannel =
      EventChannel('IOSChimePluginEvents');

  /// The event channel you can subscribe to with
  /// IosChime.eventChannel.receiveBroadcastStream().listen()
  static EventChannel get eventChannel => _eventChannel;

  static Future<String?> getPlatformVersion() {
    return IosChimePlatform.instance.getPlatformVersion();
  }

  static Future<bool> requestCameraUsage() async {
    return await IosChimePlatform.instance.requestCameraUsage() ?? false;
  }

  static Future<bool> requestRecordPermissions() async {
    return await IosChimePlatform.instance.requestRecordPermissions() ?? false;
  }

  static Future<void> hideLoading() {
    return IosChimePlatform.instance.hideLoading();
  }

  static Future<void> joinMeeting({required String? params}) {
    return IosChimePlatform.instance.joinMeeting(params: params);
  }

  static Future<void> endMetting() {
    return IosChimePlatform.instance.endMeeting();
  }

  static Future<void> meetingBeingRecorded() {
    return IosChimePlatform.instance.meetingBeingRecorded();
  }

  static Future<void> meetingStopRecording() {
    return IosChimePlatform.instance.meetingStopRecording();
  }

  static Future<void> showToast(String message) {
    return IosChimePlatform.instance.showToast(message);
  }

  static Future<void> setJoinRoomByAgent(bool isSuccess) {
    return IosChimePlatform.instance.setJoinRoomByAgent(isSuccess);
  }

  static Future<void> test() {
    return IosChimePlatform.instance.test();
  }
}
