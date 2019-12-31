//
//  BAXCXcodeAppManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCXcodeAppManager {
    public class func xcodes() -> [(String, String?)]? {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.applicationPath())
        if appPaths == nil {
            return nil
        }
        var result: [(String, String?)]? = nil
        for pathItem in appPaths! {
            let infoPlistPath: String? = BAXCXcodeInfoManager.appPlistPath(pathItem)
            let bundleID: String? = BAXCPlistAnalyzer.read(path: infoPlistPath, key: "CFBundleIdentifier") as? String
            if bundleID == nil || bundleID! != BAXCXcodeInfoManagerConstants.bundleID {
                continue
            }
            let version: String? = BAXCPlistAnalyzer.read(path: infoPlistPath, key: "CFBundleShortVersionString") as? String
            if result == nil {
                result = []
            }
            result!.append((pathItem, version))
        }
        return result
    }
}
