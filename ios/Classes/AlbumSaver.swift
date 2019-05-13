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

import UIKit
import MobileCoreServices
import Photos

class AlbumSaver {
    let albumName: String
    
    class func fetchAssetCollection(_ albumName:String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        return collection.firstObject
    }
    
    init(folderName: String) {
        self.albumName = folderName
    }
    
    private func checkAuthorization(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorization(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
        }
        else {
            completion(false)
        }
    }
    
    func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if AlbumSaver.fetchAssetCollection(albumName) != nil {
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                guard let `self` = self else { return }
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            }) { success, error in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func save(filePath: String,complete:((Bool, Error?) -> Void)? = nil) {
        
        self.checkAuthorization {[weak self] (success) in
            guard let `self` = self else { return }
            if success,
                let assetCollection = AlbumSaver.fetchAssetCollection(self.albumName),
                let image = UIImage(contentsOfFile: filePath) {
                PHPhotoLibrary.shared()
                .performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    if let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset,
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder]
                        albumChangeRequest.addAssets(enumeration)
                    }
                    
                }, completionHandler: complete)
            } else {
                complete?(false,NSError(domain: "Permision deny", code: -100, userInfo: nil))
            }
        }
        
    }
}
