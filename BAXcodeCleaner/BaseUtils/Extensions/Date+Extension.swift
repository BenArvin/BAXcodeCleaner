//
//  Date+Extension.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2021/2/2.
//  Copyright © 2021 BenArvin. All rights reserved.
//

import Foundation

extension Date {
    public func mc_toSecStr() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateformatter.string(from: self)
    }
    
    public func mc_toMillSecStr() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateformatter.string(from: self)
    }
    
    public func mc_toNaSecTimestampStr() -> String {
        return String.init(format: "%.9f", self.timeIntervalSince1970)
    }
}
