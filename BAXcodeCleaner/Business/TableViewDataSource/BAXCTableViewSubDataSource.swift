//
//  BAXCTableViewSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCTableViewSubDataSource {
    var onSelected: (() -> ())? = nil
    var onSectionSelected: (() -> ())? = nil
    var onFoldBtnSelected: (() -> ())? = nil
}

extension BAXCTableViewSubDataSource: BAXCTableViewSubDataSourceProtocol {
    @objc public func numberOfRows() -> Int {
        return 0
    }
    
    @objc public func height(for row: Int) -> CGFloat {
        if row == 0 {
            return 55
        } else {
            return 20
        }
    }
    
    @objc public func cell(for row: Int, column: Int) -> NSTableCellView? {
        if row == 0 {
            if column == 0 {
                let result: BAXCSectionTitleCell = BAXCSectionTitleCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionTitleCellConstants.identifier)
                result.index = row
                result.delegate = self
                return result
            } else if column == 2 {
                let result: BAXCSectionSizeCell = BAXCSectionSizeCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionSizeCellConstants.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCSectionCheckBoxCell = BAXCSectionCheckBoxCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionCheckBoxCellConstants.identifier)
                result.index = row
                result.delegate = self
                return result
            } else {
                let result: BAXCSectionBlankCell = BAXCSectionBlankCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionBlankCellConstants.identifier)
                result.index = row
                return result
            }
        } else {
            if column == 0 {
                let result: BAXCTitleCell = BAXCTitleCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCTitleCellConstants.identifier)
                result.index = row
                return result
            } else if column == 1 {
                let result: BAXCContentCell = BAXCContentCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCContentCellConstants.identifier)
                result.index = row
                return result
            } else if column == 2 {
                let result: BAXCFileSizeCell = BAXCFileSizeCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCFileSizeCellConstants.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCCheckBoxCell = BAXCCheckBoxCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCCheckBoxCellConstants.identifier)
                result.index = row
                result.delegate = self
                return result
            }
        }
        return nil
    }
    
    @objc public func setContent(for cell: NSTableCellView, row: Int, column: Int) {
    }
    
    @objc public func refresh() {
    }
    
    @objc public func isAllSelected() -> Bool {
        return false
    }
    
    @objc public func isNoneSelected() -> Bool {
        return false
    }
    
    @objc public func selectAll() {
    }
    
    @objc public func unselectAll() {
    }
    
    @objc public func onSelected(closure: @escaping () -> ()) {
        self.onSelected = closure
    }
    
    @objc public func onSectionSelected(closure: @escaping () -> ()) {
        self.onSectionSelected = closure
    }
    
    @objc public func cleanCheck() -> String? {
        return nil
    }
    
    @objc public func clean() {
    }
    
    @objc public func contentForCopy(at row: Int) -> String? {
        return nil
    }
    
    @objc public func pathForOpen(at row: Int) -> String? {
        return nil
    }
    
    @objc public func totalSize() -> Int {
        return 0
    }
    
    @objc public func selectedSize() -> Int {
        return 0
    }
}

extension BAXCTableViewSubDataSource: BAXCSectionTitleCellDelegate {
    @objc public func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCell) {
    }
}

extension BAXCTableViewSubDataSource: BAXCCheckBoxCellDelegate {
    @objc public func onCheckBoxSelected(cell: BAXCCheckBoxCell) {
    }
}

extension BAXCTableViewSubDataSource: BAXCSectionCheckBoxCellDelegate {
    @objc public func onSectionCheckBoxSelected(cell: BAXCSectionCheckBoxCell) {
    }
}
