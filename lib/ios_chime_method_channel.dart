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
  Future<void> hideLoading() {
    return methodChannel.invokeMethod('hideLoading');
  }

  @override
  Future<void> joinMeeting({required String? params}) {
    return methodChannel.invokeMapMethod('joinMeeting', params);
  }

  @override
  Future<void> endMeeting() {
    return methodChannel.invokeMethod('endMeeting');
  }
}
