package com.mengtnt.export_video_frame;
import java.util.ArrayList;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ExportVideoFramePlugin */
public class ExportVideoFramePlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "export_video_frame");
    FileStorage.share().setContext(registrar.context());
    PermissionManager.current().setActivity(registrar.activity());
    channel.setMethodCallHandler(new ExportVideoFramePlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("exportImage")) {
      if (!PermissionManager.current().isPermissionGranted()) {
        PermissionManager.current().askForPermission();
      }
      ArrayList<String> list = (ArrayList<String>)call.arguments;
      String path = list.get(0);
      ExportImageTask task = new ExportImageTask();
      task.execute(path,20);
      task.setCallBack(new Callback() {
        @Override
        public void exportPath(ArrayList<String> list) {
          if (list != null) {
            result.success(list);
          } else {
            result.error("Media exception","get frame fail", null);
          }
        }
      });
    } else {
      result.notImplemented();
    }
  }

}
