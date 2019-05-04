#import "ExportVideoFramePlugin.h"
#import <export_video_frame/export_video_frame-Swift.h>

@implementation ExportVideoFramePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftExportVideoFramePlugin registerWithRegistrar:registrar];
}
@end
