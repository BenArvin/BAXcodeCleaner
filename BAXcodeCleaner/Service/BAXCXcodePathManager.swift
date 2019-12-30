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
    
    public class func appPlistPath(_ path: String?) -> String? {
        return BAXCFileUtil.assemblePath(path, "Contents/Info.plist")
    }
    
    public class func libraryPath() -> String {
        return BAXCFileUtil.assemblePath(NSHomeDirectory(), "Library")!
    }
    
    public class func derivedDataPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/Xcode/DerivedData")!
    }
    
    public class func archivesPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/Xcode/Archives")!
    }
    
    public class func deviceSupportPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/Xcode/iOS DeviceSupport")!
    }
    
    public class func ibSupportPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/Xcode/UserData/IB Support")!
    }
    
    public class func deviceLogPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/Xcode/UserData/iOS Device Logs")!
    }
    
    public class func simulatorDevicesPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/CoreSimulator/Devices")!
    }
    
    public class func simulatorCachesPath() -> String {
        return BAXCFileUtil.assemblePath(self.libraryPath(), "Developer/CoreSimulator/Caches")!
    }
}
