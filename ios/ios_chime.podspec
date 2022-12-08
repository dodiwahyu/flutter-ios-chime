#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ios_chime.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ios_chime'
  s.version          = '0.1.0'
  s.summary          = 'ios_chime adalah plugin untuk handle video conference AMS'
  s.description      = <<-DESC
Plugin ini dibagun dengan code inti native swift dan diwrapping dengan code dart
                       DESC
  s.homepage         = 'https://www.dodi.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tokio Marine Life Insurence' => 'me@dodi.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resource_bundles = {
    'ios_chime' => ['Classes/**/*.xib','Assets/*.lproj/*.strings', 'Assets/**/*']
  }

  # The following dependencies are required for the Amazon Chime SDK
  s.static_framework = true
  
  # Core dependencies are required
  s.dependency 'Flutter'
  s.dependency 'AmazonChimeSDK-Bitcode'
  s.dependency 'Toast-Swift', '~> 5.0.1'
  s.dependency 'SVProgressHUD'
  s.dependency 'Connectivity'
  
  # Minimum iOS version
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
