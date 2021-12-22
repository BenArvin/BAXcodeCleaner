//
//  BACrashLogAnalyzer.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/15.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BACrashLogAnalyzer {
    public class func searchCrashLogs() -> [(String, String, Date)]? {
        let bundleName: String? = self._getBundleName()
        if bundleName == nil {
            return nil
        }
        
        var logFolderPath: String = String.init(format: "%@/Library/Logs/DiagnosticReports", NSHomeDirectory())
        logFolderPath = logFolderPath.replacingOccurrences(of: "//", with: "/")
        
        var isDirectory = ObjCBool.init(false)
        let existed: Bool = FileManager.default.fileExists(atPath: logFolderPath, isDirectory: &isDirectory)
        if existed == false || isDirectory.boolValue == false {
            return nil
        }
        
        var items:[String]
        do {
            try items = FileManager.default.contentsOfDirectory(atPath: logFolderPath)
        } catch {
            return nil
        }
        
        var result: [(String, String, Date)] = []
        for item: String in items {
            if item == BAXCFileUtil.dsStoreDirName {
                continue
            }
            let itemTmp: NSString = item as NSString
            let range: NSRange = itemTmp.range(of: bundleName!, options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: itemTmp.length), locale: nil)
            if range.location != 0 {
                continue
            }
            let leftPartsTmp = item[item.index(item.startIndex, offsetBy: bundleName!.count + 1)..<item.index(item.startIndex, offsetBy: item.count)]
            let parts: [Substring] = leftPartsTmp.split(separator: "_")
            if parts.count < 1 {
                continue
            }
            let fullPath = String.init(format: "%@/%@", logFolderPath, item)
            let date = self._convertToDate(timeStr: String(parts[0]))
            result.append((fullPath, item, date))
        }
        return result
    }
    
    private class func _getBundleName() -> String? {
        let infoDic = Bundle.main.infoDictionary
        if infoDic == nil {
            return nil
        }
        let bundleName: String? = infoDic!["CFBundleName"] as? String ?? nil
        return bundleName
    }
    
    private class func _convertToDate(timeStr: String) -> Date {
        var realTimeStr: String = timeStr
        if realTimeStr.split(separator: "-").count > 4 {
            let realTimeStrForSearch: NSString = realTimeStr as NSString
            let range: NSRange = realTimeStrForSearch.range(of: "-", options: String.CompareOptions.backwards, range: NSRange.init(location: 0, length: realTimeStrForSearch.length), locale: nil)
            if range.location != NSNotFound {
                let realTimeStrSubTmp = realTimeStr[realTimeStr.index(realTimeStr.startIndex, offsetBy: 0)..<realTimeStr.index(realTimeStr.startIndex, offsetBy: range.location)]
                realTimeStr = String(realTimeStrSubTmp)
            }
        }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat="yyyy-MM-dd-HHmmss"
        return dateformatter.date(from: realTimeStr)!
    }
}
