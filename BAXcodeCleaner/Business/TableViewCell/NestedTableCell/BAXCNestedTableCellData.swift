//
//  BAXCNestedTableCellData.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAXCNestedTableCellData: NSObject {
    var title: String? = nil
    var totalSize: Int = 0
    var selectedSize: Int = 0
    var columnCount: Int = 0
    var columnTitles: [String]? = nil
    var columnMinWidth: [CGFloat]? = nil
    var columnWidth: [CGFloat]? = nil
    var lines: [[String]?]? = nil
}
