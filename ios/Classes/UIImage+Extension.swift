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

extension UIImage {
    
    /// alignment [0,0] repesent center.
    /// [1,1] repesent right bottom.
    /// [-1,-1] repesent left top.
    /// scale with repect to image
    func imageAddWatherMark(waterMark:UIImage,alignment:CGPoint,scale:CGFloat) -> UIImage? {
        let width = waterMark.size.width * scale
        let height = waterMark.size.height * scale
        let x = (alignment.x + 1) * (size.width/2.0 - width/2.0)
        let y = (alignment.y + 1) * (size.height/2.0 - height/2.0)
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
