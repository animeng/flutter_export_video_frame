/** 
MIT License

Copyright (c) 2019 mengtnt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
