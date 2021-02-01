//
//  BAXCNestedTableCellDelegate.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCNestedTableCellDelegate: class {
    func onCheckBoxSelected(cell: BAXCNestedTableCell, innerRow: Int)
    func onCheckAllBoxSelected(cell: BAXCNestedTableCell)
}
