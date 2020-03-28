//
//  BAXCIBSupportManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

fileprivate class BAXCSimulatorHelper {
    fileprivate class func _getLastPart(_ str: String?) -> String? {
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
    
    fileprivate class func _getLastSecondPart(_ str: String?) -> String? {
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
    
    fileprivate class func _buildDataPath(_ path: String?) -> String? {
        if path == nil {
            return nil
        }
        return BAXCFileUtil.assemblePath(path!, "data")
    }
}

public class BAXCSimulatorDeviceTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.simulatorDevicesPath())
        if appPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, String?, String?, Int)]? = nil
        for pathItem in appPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            let devicePlistPath: String? = BAXCFileUtil.assemblePath(pathItem, "device.plist")
            let deviceType: String? = BAXCPlistAnalyzer.read(path: devicePlistPath, key: "deviceType") as? String
            let runtime: String? = BAXCPlistAnalyzer.read(path: devicePlistPath, key: "runtime") as? String
            var sizeItem: Int = 0
            let dataPath = BAXCSimulatorHelper._buildDataPath(pathItem)
            if dataPath != nil {
                sizeItem = BAXCFileUtil.size(dataPath)
            }
            if (sizeItem <= 0) {
                continue
            }
            fullSize = fullSize + sizeItem
            if result == nil {
                result = []
            }
            result!.append((pathItem, name, BAXCSimulatorHelper._getLastPart(deviceType), BAXCSimulatorHelper._getLastPart(runtime), sizeItem))
        }
        return (result, fullSize)
    }
    
    public override class func clean(_ path: String?) {
        if path == nil || path!.isEmpty {
            return
        }
        let dataPath = BAXCSimulatorHelper._buildDataPath(path!)
        if dataPath == nil {
            return
        }
        let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(dataPath!)
        if innerPaths == nil {
            return
        }
        for innerPathItem in innerPaths! {
            BAXCFileUtil.recycle(innerPathItem)
        }
    }
}

public class BAXCSimulatorCacheTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.simulatorCachesDyldPath())
        if innerPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, String?, Int)]? = nil
        for innerPathItem in innerPaths! {
            let dyldPaths: [String]? = BAXCFileUtil.contentsOfDir(innerPathItem)
            if dyldPaths == nil {
                continue
            }
            for dyldPathItem in dyldPaths! {
                let name: String? = BAXCFileUtil.splitAbnormalPath(dyldPathItem)
                let sizeItem: Int = BAXCFileUtil.size(dyldPathItem)
                if (sizeItem <= 0) {
                    continue
                }
                fullSize = fullSize + sizeItem
                if result == nil {
                    result = []
                }
                result!.append((dyldPathItem, name, BAXCSimulatorHelper._getLastSecondPart(name), sizeItem))
            }
        }
        return (result, fullSize)
    }
}
