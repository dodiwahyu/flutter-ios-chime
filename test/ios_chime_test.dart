import 'package:flutter_test/flutter_test.dart';
import 'package:ios_chime/ios_chime.dart';
import 'package:ios_chime/ios_chime_platform_interface.dart';
import 'package:ios_chime/ios_chime_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIosChimePlatform
    with MockPlatformInterfaceMixin
    implements IosChimePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> endMeeting() {
    // TODO: implement endMeeting
    throw UnimplementedError();
  }

  @override
  Future<void> hideLoading() {
    // TODO: implement hideLoading
    throw UnimplementedError();
  }

  @override
  Future<void> joinMeeting({required String? params}) {
    // TODO: implement joinMeeting
    throw UnimplementedError();
  }

  @override
  Future<void> meetingBeingRecorded() {
    // TODO: implement meetingBeingRecorded
    throw UnimplementedError();
  }

  @override
  Future<void> meetingStopRecording() {
    // TODO: implement meetingStopRecording
    throw UnimplementedError();
  }

  @override
  Future<bool?> requestCameraUsage() {
    // TODO: implement requestCameraUsage
    throw UnimplementedError();
  }

  @override
  Future<bool?> requestRecordPermissions() {
    // TODO: implement requestRecordPermissions
    throw UnimplementedError();
  }

  @override
  Future<void> setJoinRoomByAgent(bool isSuccess) {
    // TODO: implement setJoinRoomByAgent
    throw UnimplementedError();
  }

  @override
  Future<bool?> setLangCode(String langCode) {
    // TODO: implement setLangCode
    throw UnimplementedError();
  }

  @override
  Future<void> showToast(String message) {
    // TODO: implement showToast
    throw UnimplementedError();
  }

  @override
  Future<void> test() {
    // TODO: implement test
    throw UnimplementedError();
  }
}

void main() {
  final IosChimePlatform initialPlatform = IosChimePlatform.instance;

  test('$MethodChannelIosChime is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIosChime>());
  });

  test('getPlatformVersion', () async {
    IosChime iosChimePlugin = IosChime();
    MockIosChimePlatform fakePlatform = MockIosChimePlatform();
    IosChimePlatform.instance = fakePlatform;
  });
}
