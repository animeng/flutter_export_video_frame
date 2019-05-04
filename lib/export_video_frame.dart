import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class ExportVideoFrame {
  static const MethodChannel _channel =
      const MethodChannel('export_video_frame');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<File>> exportImage (String filePath) async {
    final List<dynamic> list = await _channel.invokeMethod('exportImage',[filePath]);
    var result = list.cast<String>().map( (path) => File.fromUri(Uri.file(path))).toList();
    return result;
  }
  
}
