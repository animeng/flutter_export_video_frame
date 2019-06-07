//
//  UIImage+Extension.swift
//  export_video_frame
//
//  Created by wang animeng on 2019/5/21.
//

import Foundation

extension UIImage {
    
    func imageAddWatherMark(waterMark:UIImage,scale:Float) -> UIImage? {
        let width = ceil(CGFloat(scale)*size.width)
        let height = waterMark.size.height * width / waterMark.size.width
        let x = size.width - width - 10
        let y = size.height - height - 10
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        waterMark.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    // CoreImage is coordinates,So rotation is counter-clockwise
    func imageByRotate(radius: CGFloat) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        if radius == 0 {
            return self;
        }
        let ciContext = CIContext(eaglContext: EAGLContext(api: .openGLES2)!)
        let ciImage = CIImage(cgImage: cgImage)
        let rotation = CGAffineTransform(rotationAngle: radius)
        let trans = ciImage.transformed(by: rotation)
        if let result = ciContext.createCGImage(trans, from: trans.extent) {
            return UIImage(cgImage: result, scale: self.scale, orientation: .up)
        }
        return nil
    }
    
}
