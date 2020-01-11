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

    public func numberOfRows() -> Int {
        return 0
    }
    
    public func height(for row: Int) -> CGFloat {
        if row == 0 {
            return 55
        } else {
            return 20
        }
    }
    
    public func cell(for row: Int, column: Int) -> NSTableCellView? {
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
    
    public func setContent(for cell: NSTableCellView, row: Int, column: Int) {
    }
    
    public func refresh() {
    }
    
    func isAllSelected() -> Bool {
        return false
    }
    
    public func isNoneSelected() -> Bool {
        return false
    }
    
    public func selectAll() {
    }
    
    public func unselectAll() {
    }
    
    public func cleanCheck() -> String? {
        return nil
    }
    
    public func clean() {
    }
    
    public func contentForCopy(at row: Int) -> String? {
        return nil
    }
    
    public func pathForOpen(at row: Int) -> String? {
        return nil
    }
    
    public func size() -> (Int, Int) {
        return (0, 0)
    }
}

extension BAXCTableViewSubDataSource: BAXCSectionTitleCellDelegate {
    @objc public func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCell) {
    }
    
    @objc public func onSectionTitleCellTipsBtnSelected(cell: BAXCSectionTitleCell) {
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
