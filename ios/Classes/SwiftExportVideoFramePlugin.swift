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
        if call.method == "cleanImageCache" {
            do {
                try FileStorage.share?.cleanAllFile()
                result("success")
            } catch {
                result(error.localizedDescription)
            }
        } else if call.method == "exportImage" {
            if let arguments = call.arguments as? [String],
                arguments.count == 2,
                let filePath = arguments.first,
                let second = arguments.last,
                let number = Int(second) {
                DispatchQueue.global(qos: .background).async {
                    let originImgList = self.exportImagePathList(filePath, number: number)
                    result(originImgList)
                }
            } else {
                let empty = [String]()
                result(empty)
            }
        } else {
            result("No notImplemented")
        }
    }
    
    private func exportImagePathList(_ filePath: String,number:Int) -> [String] {
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
        }
        return imageList
    }
}
