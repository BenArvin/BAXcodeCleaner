//
//  BAXCIBSupportManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCSimulatorManager {
    public class func devices() -> [(String, String?, String?, String?)]? {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.simulatorDevicesPath())
        if appPaths == nil {
            return nil
        }
        var result: [(String, String?, String?, String?)]? = nil
        for pathItem in appPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            let devicePlistPath: String? = BAXCFileUtil.assemblePath(pathItem, "device.plist")
            let deviceType: String? = BAXCPlistAnalyzer.read(path: devicePlistPath, key: "deviceType") as? String
            let runtime: String? = BAXCPlistAnalyzer.read(path: devicePlistPath, key: "runtime") as? String
            if result == nil {
                result = []
            }
            result!.append((pathItem, name, self._getLastPart(deviceType), self._getLastPart(runtime)))
        }
        return result
    }
    
    public class func caches() -> [(String, String?, String?)]? {
        let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.simulatorCachesDyldPath())
        if innerPaths == nil {
            return nil
        }
        var result: [(String, String?, String?)]? = nil
        for innerPathItem in innerPaths! {
            let dyldPaths: [String]? = BAXCFileUtil.contentsOfDir(innerPathItem)
            if dyldPaths == nil {
                continue
            }
            for dyldPathItem in dyldPaths! {
                let name: String? = BAXCFileUtil.splitAbnormalPath(dyldPathItem)
                if result == nil {
                    result = []
                }
                result!.append((dyldPathItem, name, self._getLastSecondPart(name)))
            }
        }
        return result
    }
    
    private class func _getLastPart(_ str: String?) -> String? {
        if str == nil {
            return nil
        }
        let tmpStr: NSString = str! as NSString
        let range: NSRange = tmpStr.range(of: ".", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: tmpStr.length), locale: nil)
        if range.location == NSNotFound {
            return str
        }
        return str!.mc_sub(from: range.location + 1, to: tmpStr.length)
    }
    
    private class func _getLastSecondPart(_ str: String?) -> String? {
        if str == nil {
            return nil
        }
        let tmpStr: NSString = str! as NSString
        let range: NSRange = tmpStr.range(of: ".", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: tmpStr.length), locale: nil)
        if range.location == NSNotFound {
            return str
        }
        let range2: NSRange = tmpStr.range(of: ".", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: range.location), locale: nil)
        if range2.location == NSNotFound {
            return str
        }
        return str!.mc_sub(from: range2.location + 1, to: range.location)
    }
}
