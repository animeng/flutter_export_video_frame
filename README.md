#Export Video frame for Flutter

A Flutter plugin for iOS and Android for exporting picture from video file.

##Installation

add ```export_video_frame``` as a dependency in your pubspec.yaml file.

##Usage
```
/// Returns the file list of the exporting image
///
/// - parameters:
///    - filePath: file path of video
///    - number: export the number of frames
static Future<List<File>> exportImage (String filePath,int number) async {
	final List<dynamic> list = await _channel.invokeMethod('exportImage',[filePath,"$number"]);
	var result = list.cast<String>().map( (path) => File.fromUri(Uri.file(path))).toList();
	return result;
}
```

```
/// Returns whether clean success
static Future<bool> cleanImageCache() async {
	final String result = await _channel.invokeMethod('cleanImageCache');
	if (result == "success") {
	  return true;
	}
	return false;
}
```

[Example Demo](https://pub.dev/packages/export_video_frame#-example-tab-)