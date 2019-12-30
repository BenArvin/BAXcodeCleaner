//
//  BAXCInfoPlistAnalyzer.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public class BAXCInfoPlistAnalyzer {
    public class func read(path: String?, key: String?) -> Any? {
        if path == nil || path!.isEmpty || key == nil || key!.isEmpty {
            return nil
        }
        let dic: NSDictionary? = NSDictionary(contentsOfFile: path!)
        if dic == nil {
            return nil
        }
        return dic!.value(forKey: key!)
    }
}
