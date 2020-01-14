//
//  BAXCDeviceSupportTrashManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCDeviceSupportTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.deviceSupportPath())
        if appPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, Int)]? = nil
        for pathItem in appPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            if result == nil {
                result = []
            }
            let sizeItem: Int = BAXCFileUtil.size(pathItem)
            fullSize = fullSize + sizeItem
            result!.append((pathItem, name, sizeItem))
        }
        return (result, fullSize)
    }
    
    public override class func simplyClean() {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.deviceSupportPath())
        if appPaths == nil {
            return
        }
        for pathItem in appPaths! {
            self.clean(pathItem)
        }
    }
}
