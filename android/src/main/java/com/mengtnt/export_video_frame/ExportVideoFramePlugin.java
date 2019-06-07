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

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.FileDescriptor;
import java.io.InputStream;
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
    AblumSaver.share().setCurrent(registrar.context());
    PermissionManager.current().setActivity(registrar.activity());
    ExportVideoFramePlugin plugin = new ExportVideoFramePlugin();
    plugin.setRegistrar(registrar);
    channel.setMethodCallHandler(plugin);
  }

  private Registrar registrar;

  public void setRegistrar(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (!PermissionManager.current().isPermissionGranted()) {
      PermissionManager.current().askForPermission();
    }
    if (!(FileStorage.isExternalStorageReadable() && FileStorage.isExternalStorageWritable())) {
      result.error("File permission exception","Not get external storage permission",null);
      return;
    }

    switch (call.method) {
      case "cleanImageCache": {
        Boolean success = FileStorage.share().cleanCache();
        if (success) {
          result.success("success");
        } else {
          result.error("Clean exception", "Fail", null);
        }
        break;
      }
      case "saveImage": {
        String filePath = call.argument("filePath").toString();
        String albumName = call.argument("albumName").toString();
        Bitmap waterBitMap = null;
        AblumSaver.share().setAlbumName(albumName);
        if (call.argument("waterMark") != null) {
          String waterPathKey = call.argument("waterMark").toString();
          AssetManager assetManager = registrar.context().getAssets();
          String key = registrar.lookupKeyForAsset(waterPathKey);
          try {
            InputStream in = assetManager.open(key);
            waterBitMap = BitmapFactory.decodeStream(in);
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
        AblumSaver.share().saveToAlbum(filePath,waterBitMap,result);
        break;
      }
      case "exportGifImagePathList": {
        String filePath = call.argument("filePath").toString();
        Number quality = call.argument("quality");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,quality);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if (list != null) {
              result.success(list);
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      case "exportImage": {
        String filePath = call.argument("filePath").toString();
        Number number = call.argument("number");
        Number quality = call.argument("quality");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,number.intValue(),quality);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if (list != null) {
              result.success(list);
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      case "exportImageBySeconds": {
        String filePath = call.argument("filePath").toString();
        Number duration = call.argument("duration");
        Number radian = call.argument("radian");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,duration.longValue(),radian);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if ((list != null) && (list.size() > 0)) {
              result.success(list.get(0));
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      default:
        result.notImplemented();
        break;
    }

  }

}
