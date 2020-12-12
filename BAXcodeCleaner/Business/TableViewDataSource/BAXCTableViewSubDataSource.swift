//
//  BAXCTableViewSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCTableViewSubDataSource {
    var onRowCheckBtnSelected: ((_: NSTableCellView) -> ())? = nil
    var onSectionCheckBtnSelected: ((_: NSTableCellView) -> ())? = nil
    var onFoldBtnSelected: ((_: NSTableCellView) -> ())? = nil
    var onTipsBtnSelected: ((_: NSTableCellView) -> ())? = nil

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
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionTitleCell.identifier)
                result.index = row
                result.delegate = self
                return result
            } else if column == 2 {
                let result: BAXCSectionSizeCell = BAXCSectionSizeCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionSizeCell.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCSectionCheckBoxCell = BAXCSectionCheckBoxCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionCheckBoxCell.identifier)
                result.index = row
                result.delegate = self
                return result
            } else {
                let result: BAXCSectionBlankCell = BAXCSectionBlankCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionBlankCell.identifier)
                result.index = row
                return result
            }
        } else {
            if column == 0 {
                let result: BAXCTitleCell = BAXCTitleCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCTitleCell.identifier)
                result.index = row
                return result
            } else if column == 1 {
                let result: BAXCContentCell = BAXCContentCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCContentCell.identifier)
                result.index = row
                return result
            } else if column == 2 {
                let result: BAXCFileSizeCell = BAXCFileSizeCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCFileSizeCell.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCCheckBoxCell = BAXCCheckBoxCell.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCCheckBoxCell.identifier)
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
    
    func isAllChecked() -> Bool {
        return false
    }
    
    public func isNoneChecked() -> Bool {
        return false
    }
    
    public func onCheckEventForSection() {
    }
    
    public func onCheckEventForRow(_ row: Int) {
    }
    
    public func onFoldEvent() {
    }
    
    public func checkAll() {
    }
    
    public func uncheckAll() {
    }
    
    public func cleanCheck() -> (Bool, String?) {
        return (false, nil)
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
    
    public func tipsForHelp() -> (String?, String?) {
        return (nil, nil)
    }
}

extension BAXCTableViewSubDataSource: BAXCSectionTitleCellDelegate {
    @objc public func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCell) {
        if self.onFoldBtnSelected != nil {
            self.onFoldBtnSelected!(cell)
        }
    }
    
    @objc public func onSectionTitleCellTipsBtnSelected(cell: BAXCSectionTitleCell) {
        if self.onTipsBtnSelected != nil {
            self.onTipsBtnSelected!(cell)
        }
    }
}

extension BAXCTableViewSubDataSource: BAXCCheckBoxCellDelegate {
    @objc public func onCheckBoxSelected(cell: BAXCCheckBoxCell) {
        if self.onRowCheckBtnSelected != nil {
            self.onRowCheckBtnSelected!(cell)
        }
    }
}

extension BAXCTableViewSubDataSource: BAXCSectionCheckBoxCellDelegate {
    @objc public func onSectionCheckBoxSelected(cell: BAXCSectionCheckBoxCell) {
        if self.onSectionCheckBtnSelected != nil {
            self.onSectionCheckBtnSelected!(cell)
        }
    }
}
