import Flutter
import UIKit
import AVFoundation

public class SwiftExportVideoFramePlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "export_video_frame", binaryMessenger: registrar.messenger())
    let instance = SwiftExportVideoFramePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
        result("iOS " + UIDevice.current.systemVersion)
    } else if call.method == "exportImage" {
        if let arguments = call.arguments as? [String],
            let filePath = arguments.first {
            DispatchQueue.global(qos: .background).async {
                let originImgList = self.exportImagePathList(filePath, number: 10)
                result(originImgList)
            }
        }
    } else {
        result("No notImplemented")
    }
  }
    
    public func exportImagePathList(_ filePath: String,number:Int) -> [String] {
        let fileUrl = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileUrl)
        var imageList = [String]()
        var times = [CMTime]()
        let timeScale = asset.duration.timescale
        let total = asset.duration.value
        let step = Int(total) / number
        for index in 0..<number {
            let index = index * step
            if index <= Int(total) {
                let time = CMTime(value: CMTimeValue(index), timescale: timeScale)
                times.append(time)
            } else {
                times.append(CMTime(value: total, timescale: timeScale))
            }
        }
        
        let imageGenrator = AVAssetImageGenerator(asset: asset)
        imageGenrator.appliesPreferredTrackTransform = true
        imageGenrator.requestedTimeToleranceAfter = .zero
        imageGenrator.requestedTimeToleranceBefore = .zero
        for time in times {
            var actualTime: CMTime = .zero
            if let imageRef = try? imageGenrator.copyCGImage(at: time, actualTime: &actualTime) {
                let img = UIImage(cgImage: imageRef)
                if let data = img.jpegData(compressionQuality: 1.0) {
                    let name = "\(filePath)+\(actualTime.value)"
                    if let filePath = FileStorage.share?.filePath(for: name),
                        let result = FileStorage.share?.createFile(name, content: data),result {
                        imageList.append(filePath)
                    }
                }
            }
            print("actualTime: \(actualTime)")
        }
        return imageList
    }
}
