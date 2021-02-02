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
            let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(pathItem)
            if innerPaths != nil {
                for innerPathItem in innerPaths! {
                    let pathURL: URL? = URL.init(fileURLWithPath: innerPathItem)
                    if pathURL == nil {
                        continue
                    }
                    let infoPlistPath = pathURL?.appendingPathComponent("Info.plist")
                    let (isExisted, isDir) = BAXCFileUtil.isPathExisted(infoPlistPath!.path)
                    if !isExisted || isDir {
                        continue
                    }
                    let name: String? = BAXCPlistAnalyzer.read(path: infoPlistPath!.path, key: "Name") as? String
                    if name == nil {
                        continue
                    }
                    let creationDate: String? = (BAXCPlistAnalyzer.read(path: infoPlistPath!.path, key: "CreationDate") as? Date)?.mc_toSecStr()
                    let sizeItem: Int = BAXCFileUtil.size(innerPathItem)
                    if result == nil {
                        result = []
                    }
                    result!.append((name!, creationDate, innerPathItem, sizeItem))
                }
            }
            let sizeItem: Int = BAXCFileUtil.size(pathItem)
            if sizeItem <= 0 {
                continue
            }
            fullSize = fullSize + sizeItem
            if result == nil {
                result = []
            }
        }
        return (result, fullSize)
    }
}
