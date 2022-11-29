import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ios_chime_method_channel.dart';

abstract class IosChimePlatform extends PlatformInterface {
  /// Constructs a IosChimePlatform.
  IosChimePlatform() : super(token: _token);

  static final Object _token = Object();

  static IosChimePlatform _instance = MethodChannelIosChime();

  /// The default instance of [IosChimePlatform] to use.
  ///
  /// Defaults to [MethodChannelIosChime].
  static IosChimePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IosChimePlatform] when
  /// they register themselves.
  static set instance(IosChimePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> hideLoading() {
    throw UnimplementedError('hideLoading() has not been implemented.');
  }

  Future<void> joinMeeting({required String? params}) {
    throw UnimplementedError('joinMeeting() has not been implemented.');
  }

  Future<void> endMeeting() {
    throw UnimplementedError('endMeeting() has not been implemented.');
  }

  Future<void> meetingBeingRecorded() {
    throw UnimplementedError(
        'meetingBeingRecorded() has not been implemented.');
  }

  Future<void> meetingStopRecording() {
    throw UnimplementedError('meetingStopRecording() has not been implemented');
  }

  Future<void> showToast(String message) {
    throw UnimplementedError('showToast() has not been implemented');
  }

  Future<void> test() {
    throw UnimplementedError('test() has not been implemented');
  }
}
