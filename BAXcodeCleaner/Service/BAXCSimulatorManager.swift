//
//  BAXCIBSupportManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCSimulatorManager {
    public class func simulators() -> [(String, String?, String?, String?)]? {
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
}
