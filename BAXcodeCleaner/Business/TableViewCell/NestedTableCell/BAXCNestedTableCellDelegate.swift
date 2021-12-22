//
//  BAXCNestedTableCellDelegate.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCNestedTableCellDelegate: AnyObject {
    func onNestedCellCheckBoxSelected(cell: BAXCNestedTableCell, innerRow: Int)
    func onNestedCellCheckAllBoxSelected(cell: BAXCNestedTableCell)
    func onNestedCellTipsBtnSelected(cell: BAXCNestedTableCell)
    func onNestedCellCopyMenuItemSelected(cell: BAXCNestedTableCell, innerRow: Int)
    func onNestedCellShowInFinderMenuItemSelected(cell: BAXCNestedTableCell, innerRow: Int)
}
