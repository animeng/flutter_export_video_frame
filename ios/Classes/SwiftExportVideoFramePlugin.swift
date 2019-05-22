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
        
        switch call.method {
        case "cleanImageCache":
            do {
                try FileStorage.share?.cleanAllFile()
                result("success")
            } catch {
                result(error.localizedDescription)
            }
        case "exportImage":
            if let argument = call.arguments as? [String:Any],
                let filePath = argument["filePath"] as? String,
                let number = argument["number"] as? Int,
                let quality = argument["quality"] as? Double {
                exportImagePathList(filePath, number: number,quality: quality) { (originImgList) in
                    result(originImgList)
                }
            } else {
                let empty = [String]()
                result(empty)
            }
        case "exportImageBySeconds":
            if let argument = call.arguments as? [String:Any],
                let filePath = argument["filePath"] as? String,
                let milli = argument["duration"] as? Int,
                let radian = argument["radian"] as? Double {
                DispatchQueue.global(qos: .background).async {
                    if let originImg = self.exportImagePathBySecond(filePath, milli: milli,radian: CGFloat(radian)) {
                        result(originImg)
                    } else {
                        result("")
                    }
                }
            } else {
                result("")
            }
        case "saveImage":
            if let argument = call.arguments as? [String:Any],
                let filePath = argument["filePath"] as? String,
                let albumName = argument["albumName"] as? String {
                let saver = AlbumSaver.share
                saver.albumName = albumName
                saver.save(filePath: filePath) { (success, error) in
                    result(success)
                }
            } else {
                result(false)
            }
        default:
            result("No notImplemented")
        }
        
    }
    
    private func exportImagePathBySecond(_ filePath: String,milli:Int,radian:CGFloat) -> String? {
        let fileUrl = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileUrl)
        let timeScale = asset.duration.timescale
        let current = Double(milli) / 1000.0
        let time = CMTime(seconds: current, preferredTimescale: timeScale)
        
        let imageGenrator = AVAssetImageGenerator(asset: asset)
        imageGenrator.appliesPreferredTrackTransform = true
        imageGenrator.requestedTimeToleranceAfter = .zero
        imageGenrator.requestedTimeToleranceBefore = .zero
        var actualTime: CMTime = .zero
        if let imageRef = try? imageGenrator.copyCGImage(at: time, actualTime: &actualTime),
            let img = UIImage(cgImage: imageRef).imageByRotate(radius: -radian),
            let data = img.jpegData(compressionQuality: 1.0) {
            let radianPrecision = String(format: "%.4f", radian)
            let name = "\(filePath)+\(actualTime.value)" + radianPrecision
            if let filePath = FileStorage.share?.filePath(for: name),
                let result = FileStorage.share?.createFile(name, content: data),result {
                return filePath
            }
        }
        return nil
    }
    
    private func exportImagePathList(_ filePath: String,number:Int,quality:Double,complete:@escaping (([String]) -> Void)) {
        let fileUrl = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileUrl)
        var imageList = [String]()
        var times = [NSValue]()
        let timeScale = asset.duration.timescale
        let total = asset.duration.value
        let step = Int(total) / number
        var accuracyTime:CMTime = CMTime.zero
        for index in 0..<number {
            let index = index * step
            if index <= Int(total) {
                accuracyTime = CMTime(value: CMTimeValue(index), timescale: timeScale)
                times.append(NSValue(time: accuracyTime))
            } else {
                times.append(NSValue(time: CMTime(value: total, timescale: timeScale)))
            }
        }
        
        let imageGenrator = AVAssetImageGenerator(asset: asset)
        imageGenrator.appliesPreferredTrackTransform = true
        imageGenrator.requestedTimeToleranceAfter = accuracyTime
        imageGenrator.requestedTimeToleranceBefore = accuracyTime
        var timesCount = 0
        imageGenrator.generateCGImagesAsynchronously(forTimes: times)
        { (time, imageRef, _, result, error) in
            timesCount = timesCount + 1
            if result == .succeeded,
                let imageRef = imageRef,
                let image = UIImage(cgImage: imageRef).jpegData(compressionQuality: CGFloat(quality))  {
                let name = "\(filePath)+\(time.value)"
                if let filePath = FileStorage.share?.filePath(for: name),
                    let result = FileStorage.share?.createFile(name, content: image),result {
                    imageList.append(filePath)
                }
            }
            if timesCount == times.count {
                DispatchQueue.main.async {
                    complete(imageList)
                }
            }
        }
    }
}
