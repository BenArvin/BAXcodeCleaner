//
//  BAXCXcodeInfoManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public struct BAXCXcodeInfoManagerConstants {
    static let bundleID: String = "com.apple.dt.Xcode"
}

public class BAXCXcodeInfoManager {
    public class func applicationPath() -> String {
        return "/Applications/"
    }
    
    public class func libraryPath() -> String {
        return "/Library/"
    }
}
