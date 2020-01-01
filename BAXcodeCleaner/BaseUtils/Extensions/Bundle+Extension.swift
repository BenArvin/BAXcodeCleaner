//
//  Bundle+Extension.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

extension Bundle {
    public func mc_releaseVersion() -> String {
        if Bundle.main.infoDictionary == nil {
            return ""
        }
        let result = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        return result == nil ? "" : result!
    }
    
    public func mc_buildVersion() -> String {
        if Bundle.main.infoDictionary == nil {
            return ""
        }
        let result = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        return result == nil ? "" : result!
    }
}
