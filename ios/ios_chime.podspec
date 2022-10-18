#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ios_chime.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ios_chime'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resource_bundles = {
    'ios_chime' => ['Classes/**/*.xib', 'Assets/**/*']
}

  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'AmazonChimeSDK-Bitcode'
  s.dependency 'AmazonChimeSDKMachineLearning-Bitcode'
  s.dependency 'Toast-Swift', '~> 5.0.1'
  s.dependency 'SVProgressHUD'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
