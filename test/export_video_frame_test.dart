import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:export_video_frame/export_video_frame.dart';

void main() {
  const MethodChannel channel = MethodChannel('export_video_frame');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await ExportVideoFrame.platformVersion, '42');
  // });
}
