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

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ExportVideoFrame {
  static const MethodChannel _channel =
      const MethodChannel('export_video_frame');

  /// Returns whether clean success
  static Future<bool> cleanImageCache() async {
    final String result = await _channel.invokeMethod('cleanImageCache');
    if (result == "success") {
      return true;
    }
    return false;
  }

  /// Save image to album
  ///
  /// - parameters:
  ///    - file: file of video
  ///    - albumName: save the album name
  ///    - waterMark:assetName "images/water_mark.png"
  ///    - alignment: [0,0]represents the center of the rectangle. 
  ///      from -1.0 to +1.0 is the distance from one side of the rectangle to the other side of the rectangle.
  ///      Default value [1,1] repesent right bottom
  ///    - scale: the scale ratio with respect water image size.Default value is 1.0
  /// Returns whether save success
  static Future<bool> saveImage(File file, String albumName,{String waterMark,Alignment alignment,double scale}) async {
    Map<String,dynamic> para = {"filePath":file.path,"albumName":albumName};
    if (waterMark != null) {
      para.addAll({"waterMark":waterMark});
      if (alignment != null) {
        para.addAll({"alignment":{"x":alignment.x,"y":alignment.y}});
      } else {
        para.addAll({"alignment":{"x":1,"y":1}});
      }
      if (scale != null) {
        para.addAll({"scale":scale});
      } else {
        para.addAll({"scale":1.0});
      }
    }
    final bool result =
        await _channel.invokeMethod('saveImage', para);
    return result;
  }

  /// Returns the file list of the exporting image
  ///
  /// - parameters:
  ///    - filePath: file path of video
  ///    - number: export the number of frames
  ///    - quality: scale of export frame."0" is lowest,"1" is origin.("0" is scale for 0.1 in android) 
  static Future<List<File>> exportImage(String filePath, int number,double quality) async {
    var para = {"filePath":filePath,"number":number,"quality":quality};
    final List<dynamic> list =
        await _channel.invokeMethod('exportImage', para);
    var result = list
        .cast<String>()
        .map((path) => File.fromUri(Uri.file(path)))
        .toList();
    return result;
  }

  /// Returns the file list of the exporting frame for gif file
  ///
  /// - parameters:
  ///    - filePath: file path of video
  ///    - quality: scale of export frame."0" is lowest,"1" is origin.("0" is scale for 0.1 in android) 
  static Future<List<File>> exportGifImage(String filePath, double quality) async {
    var para = {"filePath":filePath,"quality":quality};
    final List<dynamic> list =
        await _channel.invokeMethod('exportGifImagePathList', para);
    var result = list
        .cast<String>()
        .map((path) => File.fromUri(Uri.file(path)))
        .toList();
    return result;
  }

  /// Returns the file list of the exporting image
  ///
  /// - parameters:
  ///    - file: file of video
  ///    - duration: export the duration of frames
  ///    - radian: rotation the frame ,which will export frame.Rotation is clockwise.
  static Future<File> exportImageBySeconds(File file, Duration duration,double radian) async {
    var milli = duration.inMilliseconds;
    var para = {"filePath":file.path,"duration":milli,"radian":radian};
    final String path = await _channel
        .invokeMethod('exportImageBySeconds', para);
    try {
      var result = File.fromUri(Uri.file(path));
      return result;
    } catch (e) {
      throw e;
    }
  }
}
