//
//  UIImage+Extension.swift
//  export_video_frame
//
//  Created by wang animeng on 2019/5/21.
//

import Foundation

extension UIImage {
    
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
