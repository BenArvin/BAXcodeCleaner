//
//  BAXCDeviceSupportManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCDeviceSupportManager {
    public class func devices() -> [(String, String?)]? {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.deviceSupportPath())
        if appPaths == nil {
            return nil
        }
        var result: [(String, String?)]? = nil
        for pathItem in appPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            if result == nil {
                result = []
            }
            result!.append((pathItem, name))
        }
        return result
    }
}
