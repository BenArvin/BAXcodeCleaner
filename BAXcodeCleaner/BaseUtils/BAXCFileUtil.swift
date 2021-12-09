//
//  BAXCFileUtil.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public enum BAXCFileError: Error {
    public enum RemoveFailedReason {
        case unknown(path: String?)
        case invalidPath(path: String?)
    }
    case RemoveFailed(reason: RemoveFailedReason)
}

extension BAXCFileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .RemoveFailed(let reason):
            switch reason {
            case .unknown(let path):
                return "Remove path failed, unknown reason, path: ".appending(path!)
            case .invalidPath(let path):
                return "Remove path failed, invalid path: ".appending(path == nil ? "null" : path!)
            }
        }
    }
}

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
        if path.isEmpty {
            throw BAXCFileError.RemoveFailed(reason: BAXCFileError.RemoveFailedReason.invalidPath(path: path))
        }
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
    
    public class func recycle(_ path: String) {
        if path.isEmpty {
            return
        }
        let (existed, _) = self.isPathExisted(path)
        if existed == false {
            return
        }
        let url: URL = URL.init(fileURLWithPath: path)
        let sema: DispatchSemaphore = DispatchSemaphore.init(value: 0)
        NSWorkspace.shared.recycle([url], completionHandler: { (urls, error) in
            sema.signal()
        })
        sema.wait()
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
    
    public class func splitPath(_ path: String?) -> (String?, String?, String?) {
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
    
    public class func splitAbnormalPath(_ path: String?) -> String? {
        if path == nil || path!.isEmpty {
            return nil
        }
        let tmpStr: NSString = path! as NSString
        let range: NSRange = tmpStr.range(of: "/", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: tmpStr.length), locale: nil)
        if range.location == NSNotFound {
            return nil
        }
        let name: String? = path!.mc_sub(from: range.location + 1, to: tmpStr.length)
        return name
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
    /// Get size(Byte)
    /// - Parameter path: String
    public class func size(_ path: String?) -> Int {
        guard let path = path else {
            return 0
        }
        var isDir = ObjCBool.init(false)
        let existed: Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        if !existed {
            return 0
        }
        let pathURL = URL.init(fileURLWithPath: path)
        do {
            let atts = try pathURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileResourceTypeKey])
            var result = atts.totalFileAllocatedSize ?? 0
            if !isDir.boolValue {
                return result
            }
            if atts.fileResourceType == .symbolicLink {
                return result
            }
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: path)
                for item in items {
                    result = result + self.size(pathURL.appendingPathComponent(item).path)
                }
                return result
            } catch {
                return result
            }
        } catch {
            return 0
        }
    }
}
