//
//  BAXCArchivesTrashManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCArchivesTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.archivesPath())
        if appPaths == nil {
            return (nil, 0)
        }
        var fullSize: Int = 0
        var result: [(String, String?, String?, Int)]? = nil
        for pathItem in appPaths! {
            let name: String? = BAXCFileUtil.splitAbnormalPath(pathItem)
            if result == nil {
                result = []
            }
            var innerItems: String? = nil
            let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(pathItem)
            if innerPaths != nil {
                for innerPathItem in innerPaths! {
                    let fileName: String? = BAXCFileUtil.splitAbnormalPath(innerPathItem)
                    if fileName != nil {
                        if innerItems == nil {
                            innerItems = fileName!
                        } else {
                            innerItems = innerItems!.appendingFormat(", %@", fileName!)
                        }
                    }
                }
            }
            let sizeItem: Int = BAXCFileUtil.size(pathItem)
            fullSize = fullSize + sizeItem
            result!.append((pathItem, name, innerItems, sizeItem))
        }
        return (result, fullSize)
    }
}
