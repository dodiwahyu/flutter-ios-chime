#import "IosChimePlugin.h"
#if __has_include(<ios_chime/ios_chime-Swift.h>)
#import <ios_chime/ios_chime-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ios_chime-Swift.h"
#endif

@implementation IosChimePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIosChimePlugin registerWithRegistrar:registrar];
}
@end
