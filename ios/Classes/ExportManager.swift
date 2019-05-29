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

import Foundation
import AVFoundation
import Photos

class ExportManager {
    
    static func exportImagePathBySecond(_ filePath: String,milli:Int,radian:CGFloat) -> String? {
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
    
    static func exportGifImagePathList(_ filePath: String,quality:Double) -> [String] {
        
        let gifUrl = URL(fileURLWithPath: filePath)
        
        var imagePaths = [String]()
        var totalTime:Double = 0
        
        if let source = CGImageSourceCreateWithURL(gifUrl as CFURL, nil) {
            let count = CGImageSourceGetCount(source)
            for index in 0..<count {
                if let property = CGImageSourceCopyPropertiesAtIndex(source,index,nil) as? [AnyHashable:Any],
                    let gifPorperty = property[kCGImagePropertyGIFDictionary as String] as? [AnyHashable:Any] {
                    var delayTime = gifPorperty[kCGImagePropertyGIFUnclampedDelayTime as String]
                    if delayTime == nil {
                        delayTime = gifPorperty[kCGImagePropertyGIFDelayTime as String]
                    }
                    if let time = delayTime as? Double {
                        totalTime += time
                    } else {
                        totalTime += 1
                    }
                }
                if let imageRef = CGImageSourceCreateImageAtIndex(source,index,nil),
                    let image = UIImage(cgImage: imageRef).jpegData(compressionQuality: CGFloat(quality)) {
                    let precision = String(format: "%.3f", totalTime)
                    let name = "\(filePath)+\(precision)"
                    if let filePath = FileStorage.share?.filePath(for: name),
                        let result = FileStorage.share?.createFile(name, content: image),result {
                        imagePaths.append(filePath)
                    }
                }
            }
        }
        return imagePaths
    }
    
    static func exportImagePathList(_ filePath: String,number:Int,quality:Double,complete:@escaping (([String]) -> Void)) {
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
