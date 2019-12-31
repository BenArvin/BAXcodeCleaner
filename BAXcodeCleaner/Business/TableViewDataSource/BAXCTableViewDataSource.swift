//
//  BAXCTableViewDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCTableViewDataSourceProtocol: class {
    func onDatasChanged()
}

public class BAXCTableViewDataSource {
    
    public var delegate: BAXCTableViewDataSourceProtocol?
    
    private lazy var _subDS: [BAXCTableViewSubDataSourceProtocol] = {
        let result: [BAXCTableViewSubDataSourceProtocol] = [self._applicationDS]
        return result
    }()
    
    private lazy var _applicationDS: BAXCApplicationsSubDataSource = {
        let result: BAXCApplicationsSubDataSource = BAXCApplicationsSubDataSource()
        return result
    }()
    
    init() {
        self.refresh()
    }
}

// MARK: - public methods
extension BAXCTableViewDataSource {
    public func numberOfRows() -> Int {
        return self._applicationDS.numberOfRows()
    }
    
    public func height(for row: Int) -> CGFloat {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            return subDS!.height(for: realRow)
        } else {
            return 20
        }
    }
    
    public func cell(for row: Int, column: Int) -> NSTableCellView {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            let result: NSTableCellView? = subDS!.cell(for: realRow, column: column)
            if result != nil {
                return result!
            }
        }
        let result: NSTableCellView = NSTableCellView.init()
        result.identifier = NSUserInterfaceItemIdentifier.init("NSTableCellView")
        return result
    }
    
    public func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            subDS!.setContent(for: cell, row: realRow, column: column)
        }
    }
    
    public func refresh() {
        for subDSItem in self._subDS {
            subDSItem.refresh()
        }
        self._callDelegateDatasChangedFunc()
    }
    
    public func selectAll() {
        for subDSItem in self._subDS {
            subDSItem.selectAll()
        }
        self._callDelegateDatasChangedFunc()
    }
    
    public func unselectAll() {
        for subDSItem in self._subDS {
            subDSItem.unselectAll()
        }
        self._callDelegateDatasChangedFunc()
    }
    
    public func clean() {
        for subDSItem in self._subDS {
            subDSItem.clean()
        }
        self._callDelegateDatasChangedFunc()
    }
}

// MARK: - private methods
extension BAXCTableViewDataSource {
    private func _callDelegateDatasChangedFunc() {
        if self.delegate != nil {
            self.delegate!.onDatasChanged()
        }
    }
    
    private func _subDataSource(for row: Int) -> (BAXCTableViewSubDataSourceProtocol?, Int) {
        var rowOffset: Int = 0
        for subDSItem in self._subDS {
            let countTmp: Int = subDSItem.numberOfRows()
            if row >= rowOffset && row < rowOffset + countTmp {
                return (subDSItem, row - rowOffset)
            }
            rowOffset = rowOffset + countTmp
        }
        return (nil, 0)
    }
}
