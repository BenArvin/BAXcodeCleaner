//
//  BAXCArchivesManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCArchivesManager {
    public class func archives() -> [(String, String?, String?)]? {
        let appPaths: [String]? = BAXCFileUtil.contentsOfDir(BAXCXcodeInfoManager.archivesPath())
        if appPaths == nil {
            return nil
        }
        var result: [(String, String?, String?)]? = nil
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
            result!.append((pathItem, name, innerItems))
        }
        return result
    }
}
