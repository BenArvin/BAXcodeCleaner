//
//  BAXCFileUtil.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCFileUtil {
}

extension BAXCFileUtil {
    public class func isPathExisted(_ path: String) -> (Bool, Bool) {
        if path.isEmpty {
            return (false, false)
        }
        var isDirectory = ObjCBool.init(false)
        let existed: Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return (existed, isDirectory.boolValue)
    }

    public class func remove(_ path: String) throws {
//        if path.isEmpty {
//            return Error
//        }
        let (existed, _) = self.isPathExisted(path)
        if existed == false {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            throw error
        }
    }
    
    public class func contentsOfDir(_ path: String) -> [String]? {
        let (existed, isDir) = self.isPathExisted(path)
        if existed == false || isDir == false {
            return nil
        }
        var items:[String]
        do {
            try items = FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            error.localizedDescription
            return nil
        }
        var result:[String] = []
        for item: String in items {
            if item == ".DS_Store" {
                continue
            }
            let itemPath = self.assemblePath(path, item)
            if itemPath != nil && !itemPath!.isEmpty {
                result.append(itemPath!)
            }
        }
        return result
    }
}

extension BAXCFileUtil {
    public class func assemblePath(_ firstPart: String?, _ secondPart: String?) -> String? {
        if firstPart == nil {
            return secondPart
        }
        if secondPart == nil {
            return firstPart
        }
        return NSURL(fileURLWithPath: firstPart!).appendingPathComponent(secondPart!)!.path
    }
    
    public class func splitFilePath(_ path: String?) -> (String?, String?, String?) {
        if path == nil || path!.isEmpty {
            return (nil, nil, nil)
        }
        let pathUrl: NSURL = NSURL(fileURLWithPath: path!)
        let fullName: String? = pathUrl.lastPathComponent
        let ext: String? = pathUrl.pathExtension
        var realName: String? = fullName
        if fullName != nil && !fullName!.isEmpty && ext != nil && !ext!.isEmpty {
            realName = fullName!.mc_sub(from: 0, to: fullName!.count - ext!.count - 1)
        }
        return (fullName, realName, ext)
    }
    
    public class func splitFileName(_ name: String?) -> (String?, String?) {
        if name == nil || name!.isEmpty {
            return (nil, nil)
        }
        let tmpStr: NSString = name! as NSString
        let range: NSRange = tmpStr.range(of: ".", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: tmpStr.length), locale: nil)
        if range.location == NSNotFound {
            return (name, nil)
        }
        let realName: String? = name!.mc_sub(from: 0, to: range.location)
        let ext: String? = name!.mc_sub(from: range.location + 1, to: name!.count)
        return (realName, ext)
    }
}

extension BAXCFileUtil {
    private class func _fileSize(_ filePath: String?) -> Int {
        if filePath == nil {
            return 0
        }
        let (existed, isDir) = self.isPathExisted(filePath!)
        if existed == false || isDir == true {
            return 0
        }
        var fileAttr: [FileAttributeKey : Any]? = nil
        do {
            try fileAttr = FileManager.default.attributesOfItem(atPath: filePath!)
        } catch {
            return 0
        }
        if fileAttr == nil {
            return 0
        }
        let size: Int = fileAttr![FileAttributeKey.size] as? Int ?? 0
        return size
    }
    
    /// Get size(Byte)
    /// - Parameter filePath: String
    public class func size(_ path: String?) -> Int {
        if path == nil {
            return 0
        }
        let (existed, isDir) = self.isPathExisted(path!)
        if existed == false {
            return 0
        }
        if isDir == false {
            return self._fileSize(path!)
        }
        let contentPaths: [String]? = self.contentsOfDir(path!)
        if contentPaths == nil || contentPaths!.isEmpty {
            return 0
        }
        
        var result: Int = 0
        for itemPaths in contentPaths! {
            result = result + self.size(itemPaths)
        }
        return result
    }
}
