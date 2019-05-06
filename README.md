#Export Video frame for Flutter

A Flutter plugin for iOS and Android for exporting picture from video file.

##Installation

add ```export_video_frame``` as a dependency in your pubspec.yaml file.

##Usage

* First parameter is file path of video,second parameter will export the number of frames.Returns the file list of the frame image.
```List<File> images = await ExportVideoFrame.exportImage(filpath,number);```
 
* Clean cache images after exporting frame.
```ExportVideoFrame.cleanImageCache();```