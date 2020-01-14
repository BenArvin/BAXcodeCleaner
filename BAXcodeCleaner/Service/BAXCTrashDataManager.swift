//
//  BAXCTrashDataManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/14.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCTrashDataManager {
    public class func datas() -> ([Any]?, Int) {
        return (nil, 0)
    }
    
    public class func clean(_ path: String?) {
        if path == nil || path!.isEmpty {
            return
        }
        BAXCFileUtil.recycle(path!)
    }
    
    public class func simplyClean() {
    }
}
