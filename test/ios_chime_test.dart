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

    expect(await iosChimePlugin.getPlatformVersion(), '42');
  });
}
