//
//  BAXCTableViewSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCTableViewSubDataSource: NSObject {
    private var _columnWidth: [CGFloat] = []
    
    public var columnEverSetted: Bool = false
    public var onRowCheckBtnSelected: ((_: NSTableCellView, _: Int) -> ())? = nil
    public var onSectionCheckBtnSelected: ((_: NSTableCellView) -> ())? = nil
    public var onFoldBtnSelected: ((_: NSTableCellView) -> ())? = nil
    public var onTipsBtnSelected: ((_: NSTableCellView) -> ())? = nil
    public var onCopyMenuItemSelected: ((_: NSTableCellView, _: Int) -> ())? = nil
    public var onShowInFinderMenuItemSelected: ((_: NSTableCellView, _: Int) -> ())? = nil
    
    public override init() {
        super.init()
        for _ in 0..<self.numberOfColumns() {
            _columnWidth.append(0)
        }
    }
    
    public func totalHeight() -> CGFloat {
        var result: CGFloat = BAXCNestedTableCell.minHeight()
        for row in 0..<self.numberOfRows() {
            result = result + self.height(for: row) + 1 // 1px for divid line
        }
        return result < 200 ? 200 : result
    }
    
    public func title() -> String {
        return "Unknown"
    }
    
    public func description() -> String {
        return "Unknown"
    }

    public func numberOfRows() -> Int {
        return 0
    }
    
    public func numberOfColumns() -> Int {
        return 0
    }
    
    public func titleFor(column: Int) -> String {
        return " "
    }
    
    public func minWidthFor(column: Int) -> CGFloat {
        return 30
    }
    
    public func maxWidthFor(column: Int) -> CGFloat {
        return CGFloat.greatestFiniteMagnitude
    }
    
    public func defaultWidthFor(column: Int, totalWidth: CGFloat) -> CGFloat {
        return 0.0
    }
    
    public func widthFor(column: Int) -> CGFloat {
        return self._columnWidth[column]
    }
    
    public func update(width: CGFloat, for column: Int) {
        self._columnWidth[column] = width
    }
    
    public func height(for row: Int) -> CGFloat {
        return 20
    }
    
    public func cell(for row: Int, column: Int, delegate: Any) -> NSTableCellView? {
        let result: NSTableCellView = NSTableCellView.init()
        result.identifier = NSUserInterfaceItemIdentifier.init("NSTableCellView")
        return result
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

extension BAXCTableViewSubDataSource: BAXCNestedTableCellDelegate {
    public func onNestedCellTipsBtnSelected(cell: BAXCNestedTableCell) {
        if self.onTipsBtnSelected != nil {
            self.onTipsBtnSelected!(cell)
        }
    }
    
    public func onNestedCellCheckAllBoxSelected(cell: BAXCNestedTableCell) {
        if self.onSectionCheckBtnSelected != nil {
            self.onSectionCheckBtnSelected!(cell)
        }
    }
    
    public func onNestedCellCheckBoxSelected(cell: BAXCNestedTableCell, innerRow: Int) {
        if self.onRowCheckBtnSelected != nil {
            self.onRowCheckBtnSelected!(cell, innerRow)
        }
    }
    
    public func onNestedCellCopyMenuItemSelected(cell: BAXCNestedTableCell, innerRow: Int) {
        if self.onCopyMenuItemSelected != nil {
            self.onCopyMenuItemSelected!(cell, innerRow)
        }
    }
    
    public func onNestedCellShowInFinderMenuItemSelected(cell: BAXCNestedTableCell, innerRow: Int) {
        if self.onShowInFinderMenuItemSelected != nil {
            self.onShowInFinderMenuItemSelected!(cell, innerRow)
        }
    }
}
