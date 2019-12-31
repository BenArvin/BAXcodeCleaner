//
//  BAXCDerivedDataManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCDerivedDataManager {
    public class func items() -> [(String, String?, String?)]? {
        let itemPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.derivedDataPath())
        if itemPaths == nil {
            return nil
        }
        var result: [(String, String?, String?)]? = nil
        for pathItem in itemPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            let infoPath: String? = BAXCFileUtil.assemblePath(pathItem, "info.plist")
            let workspacePath: String? = BAXCPlistAnalyzer.read(path: infoPath, key: "WorkspacePath") as? String
            if result == nil {
                result = []
            }
            result!.append((pathItem, name, workspacePath))
        }
        return result
    }
}
