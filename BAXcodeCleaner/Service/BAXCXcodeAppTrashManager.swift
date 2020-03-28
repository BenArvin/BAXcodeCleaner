//
//  BAXCXcodeAppTrashManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCXcodeAppTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.applicationPath())
        if appPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, Int)]? = nil
        for pathItem in appPaths! {
            let infoPlistPath: String? = BAXCXcodeInfoManager.appPlistPath(pathItem)
            let bundleID: String? = BAXCPlistAnalyzer.read(path: infoPlistPath, key: "CFBundleIdentifier") as? String
            if bundleID == nil || bundleID! != BAXCXcodeInfoManagerConstants.bundleID {
                continue
            }
            let version: String? = BAXCPlistAnalyzer.read(path: infoPlistPath, key: "CFBundleShortVersionString") as? String
            let sizeItem: Int = BAXCFileUtil.size(pathItem)
            if (sizeItem <= 0) {
                continue
            }
            fullSize = fullSize + sizeItem
            if result == nil {
                result = []
            }
            result!.append((pathItem, version, sizeItem))
        }
        return (result, fullSize)
    }
}
