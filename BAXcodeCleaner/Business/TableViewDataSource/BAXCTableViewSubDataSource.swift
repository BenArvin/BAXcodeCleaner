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
                let result: BAXCSectionTitleCellView = BAXCSectionTitleCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionTitleCellViewConstants.identifier)
                result.index = row
                result.delegate = self
                return result
            } else if column == 2 {
                let result: BAXCSectionSizeCellView = BAXCSectionSizeCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionSizeCellViewConstants.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCSectionBlankCellView = BAXCSectionBlankCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionBlankCellViewConstants.identifier)
                result.index = row
                return result
            } else {
                let result: BAXCSectionBlankCellView = BAXCSectionBlankCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionBlankCellViewConstants.identifier)
                result.index = row
                return result
            }
        } else {
            if column == 0 {
                let result: BAXCTitleCellView = BAXCTitleCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCTitleCellViewConstants.identifier)
                result.index = row
                return result
            } else if column == 1 {
                let result: BAXCContentCellView = BAXCContentCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCContentCellViewConstants.identifier)
                result.index = row
                return result
            } else if column == 2 {
                let result: BAXCFileSizeCellView = BAXCFileSizeCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCFileSizeCellViewConstants.identifier)
                result.index = row
                return result
            } else if column == 3 {
                let result: BAXCCheckBoxCellView = BAXCCheckBoxCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCCheckBoxCellViewConstants.identifier)
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
    
    @objc public func selectAll() {
    }
    
    @objc public func unselectAll() {
    }
    
    @objc public func onSelected(closure: @escaping () -> ()) {
        self.onSelected = closure
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
}

extension BAXCTableViewSubDataSource: BAXCSectionTitleCellViewDelegate {
    @objc public func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCellView) {
    }
}

extension BAXCTableViewSubDataSource: BAXCCheckBoxCellViewDelegate {
    @objc public func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
    }
}
