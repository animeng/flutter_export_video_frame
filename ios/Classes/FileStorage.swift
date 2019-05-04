//
//  FileStorage.swift
//  VirtualAvaSDK
//
//  Created by wang animeng on 2018/7/27.
//  Copyright © 2018年 Friends. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}

public class FileStorage {
    
    public static let share:FileStorage? = {
        return try? FileStorage(subDirName:"ExportImage")
    }()
    
    let fileManager: FileManager
    let path: String
    
    init(subDirName:String,mainDirURL:URL? = nil) throws {
        let url: URL
        self.fileManager = FileManager.default
        if let hasUrl = mainDirURL {
            url = hasUrl
        }
        else{
            url = try fileManager.url(
                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
            )
        }
        
        path = url.appendingPathComponent(subDirName, isDirectory: true).path
        try createDirectory()
    }
    
    func createDirectory() throws {
        guard !fileManager.fileExists(atPath: path) else {
            return
        }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                        attributes: nil)
    }
    
    func createFile(_ name:String,content:Data?) -> Bool {
        _ = removeFile(for: name)
        let result = fileManager.createFile(atPath: filePath(for: name), contents: content, attributes: nil)
        return result
    }
    
    func fileName(for key: String) -> String {
        return key.md5()
    }
    
    func filePath(for key: String) -> String {
        return "\(path)/\(fileName(for: key))"
    }
    
    public func searchFile(for key:String) -> URL? {
        if fileManager.fileExists(atPath: filePath(for: key)){
            return URL(fileURLWithPath: filePath(for: key))
        }
        return nil
    }
    
    func removeFile(for key:String) -> Bool {
        let url = URL(fileURLWithPath: filePath(for: key))
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    func fileSize(path:String) -> UInt64 {
        let attributes = try? fileManager.attributesOfItem(atPath: path)
        if let fileSize = attributes?[.size] as? UInt64 {
            return fileSize
        }
        return 0
    }
    
    func fileSize(key:String) -> UInt64 {
        let path = filePath(for: key)
        return fileSize(path:path)
    }
    
}
