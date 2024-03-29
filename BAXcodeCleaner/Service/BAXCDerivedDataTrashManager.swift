//
//  BAXCDerivedDataTrashManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCDerivedDataTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let itemPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.derivedDataPath())
        if itemPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, String?, String?, Int)]? = nil
        for pathItem in itemPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            let infoPath: String? = BAXCFileUtil.assemblePath(pathItem, "info.plist")
            let workspacePath: String? = BAXCPlistAnalyzer.read(path: infoPath, key: "WorkspacePath") as? String
            let lastUpdateTime: String? = (BAXCPlistAnalyzer.read(path: infoPath, key: "LastAccessedDate") as? Date)?.mc_toSecStr()
            let sizeItem: Int = BAXCFileUtil.size(pathItem)
            if (sizeItem <= 0) {
                continue
            }
            fullSize = fullSize + sizeItem
            if result == nil {
                result = []
            }
            result!.append((pathItem, name, workspacePath, lastUpdateTime, sizeItem))
        }
        return (result, fullSize)
    }
    
    public override class func simplyClean() {
        let itemPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.derivedDataPath())
        if itemPaths == nil {
            return
        }
        for pathItem in itemPaths! {
            self.clean(pathItem)
        }
    }
}
