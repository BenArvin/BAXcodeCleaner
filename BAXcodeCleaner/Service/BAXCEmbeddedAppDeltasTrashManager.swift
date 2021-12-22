//
//  BAXCEmbeddedAppDeltasTrashManager.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCEmbeddedAppDeltasTrashManager: BAXCTrashDataManager {
    public override class func datas() -> ([Any]?, Int) {
        let privateFolderURL = URL.init(fileURLWithPath: BAXCXcodeInfoManager.sysPrivatePath()).appendingPathComponent("var/folders")
        let folders = BAXCFileUtil.search(.plain("EmbeddedAppDeltas"), in: privateFolderURL.path)
        if folders.count == 0 {
            return (nil, 0)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var fullSize: Int = 0
        var result: [(String, String?, String?, Int)]? = nil
        for folderItem in folders {
            guard let firstInners = BAXCFileUtil.contentsOfDir(folderItem) else {
                continue
            }
            for firstInnerItem in firstInners {
                guard let secondInners = BAXCFileUtil.contentsOfDir(firstInnerItem) else {
                    continue
                }
                for secondInnerItem in secondInners {
                    let sizeTmp = BAXCFileUtil.size(secondInnerItem)
                    if sizeTmp <= 0 {
                        continue
                    }
                    if result == nil {
                        result = []
                    }
                    fullSize = fullSize + sizeTmp
                    if let fileItems = BAXCFileUtil.contentsOfDir(secondInnerItem) {
                        for fileItem in fileItems {
                            let fileItemURl = URL.init(fileURLWithPath: fileItem)
                            let fileItemName = fileItemURl.lastPathComponent
                            if !(fileItemName as NSString).hasSuffix(".app") {
                                continue
                            }
                            let realFileName = fileItemName.replacingOccurrences(of: ".app", with: "")
                            do {
                                let atts = try fileItemURl.resourceValues(forKeys: [.contentModificationDateKey])
                                if let lastModifyDate = atts.contentModificationDate {
                                    let lastModifyDateStr = dateFormatter.string(from: lastModifyDate)
                                    result!.append((secondInnerItem, realFileName, lastModifyDateStr, sizeTmp))
                                } else {
                                    result!.append((secondInnerItem, realFileName, "⚠️", sizeTmp))
                                }
                            } catch {
                                result!.append((secondInnerItem, realFileName, "⚠️", sizeTmp))
                            }
                            break
                        }
                    } else {
                        result!.append((secondInnerItem, "⚠️", "⚠️", sizeTmp))
                    }
                }
            }
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
