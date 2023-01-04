import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ios_chime_platform_interface.dart';

/// An implementation of [IosChimePlatform] that uses method channels.
class MethodChannelIosChime extends IosChimePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ios_chime');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> setLangCode(String langCode) {
    return methodChannel.invokeMethod<bool>('setLang', langCode);
  }

  @override
  Future<void> hideLoading() {
    return methodChannel.invokeMethod('hideLoading');
  }

  @override
  Future<bool?> requestCameraUsage() {
    return methodChannel.invokeMethod('requestCameraUsage');
  }

  @override
  Future<bool?> requestRecordPermissions() {
    return methodChannel.invokeMethod('requestRecordPermission');
  }

  @override
  Future<void> joinMeeting({required String? params}) {
    return methodChannel.invokeMapMethod('joinMeeting', params);
  }

  @override
  Future<void> endMeeting() {
    return methodChannel.invokeMethod('endMeeting');
  }

  @override
  Future<void> meetingBeingRecorded() {
    return methodChannel.invokeMethod('meetingBeingRecorded');
  }

  @override
  Future<void> meetingStopRecording() {
    return methodChannel.invokeMethod('meetingStopRecording');
  }

  @override
  Future<void> showToast(String message) {
    return methodChannel.invokeMethod('showToast', message);
  }

  @override
  Future<void> setJoinRoomByAgent(bool isSuccess) {
    return methodChannel.invokeListMethod('setJoinRoomByAgent', isSuccess);
  }

  @override
  Future<void> test() {
    return methodChannel.invokeListMethod('test');
  }
}
