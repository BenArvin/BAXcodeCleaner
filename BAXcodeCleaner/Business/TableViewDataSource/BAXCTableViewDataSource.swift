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
    
    public enum SelectState: Int {
        case None = 0
        case Part = 1
        case All = 2
    }
    
    public var delegate: BAXCTableViewDataSourceProtocol?
    
    private lazy var _subDS: [BAXCTableViewSubDataSourceProtocol] = {
        let result: [BAXCTableViewSubDataSourceProtocol] = [self._applicationDS, self._derivedDataDS, self._deviceSupportDS, self._archivesDS, self._simulatorDeviceDS, self._simulatorCacheDS]
//        let result: [BAXCTableViewSubDataSourceProtocol] = [self._simulatorCacheDS, self._archivesDS]
        return result
    }()
    
    private lazy var _applicationDS: BAXCApplicationsSubDataSource = {
        let result: BAXCApplicationsSubDataSource = BAXCApplicationsSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    private lazy var _derivedDataDS: BAXCDerivedDataSubDataSource = {
        let result: BAXCDerivedDataSubDataSource = BAXCDerivedDataSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    private lazy var _deviceSupportDS: BAXCDeviceSupportSubDataSource = {
        let result: BAXCDeviceSupportSubDataSource = BAXCDeviceSupportSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    private lazy var _archivesDS: BAXCArchivesSubDataSource = {
        let result: BAXCArchivesSubDataSource = BAXCArchivesSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    private lazy var _simulatorDeviceDS: BAXCSimulatorDeviceSubDataSource = {
        let result: BAXCSimulatorDeviceSubDataSource = BAXCSimulatorDeviceSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    private lazy var _simulatorCacheDS: BAXCSimulatorCacheSubDataSource = {
        let result: BAXCSimulatorCacheSubDataSource = BAXCSimulatorCacheSubDataSource()
        result.onSelected = self._onSubDSSelected
        result.onFoldBtnSelected = self._onSubDSFoldBtnSelected
        result.onSectionSelected = self._onSubDSSectionSelected
        return result
    }()
    
    init() {
    }
}

// MARK: - public methods
extension BAXCTableViewDataSource {
    public func numberOfRows() -> Int {
        var result: Int = 0
        for subDSItem in self._subDS {
            result = result + subDSItem.numberOfRows()
        }
        return result
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
    
    public func refresh(_ completion: (() -> ())?) {
        let group = DispatchGroup.init()
        for subDSItem in self._subDS {
            group.enter()
            DispatchQueue.global().async{
                subDSItem.refresh()
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {[weak self] in
            guard let strongSelf = self else {
                return
            }
            if completion != nil {
                completion!()
            }
            strongSelf._callDelegateDatasChangedFunc()
        }
    }
    
    public func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for subDSItem in self._subDS {
            if subDSItem.isAllSelected() == false {
                allSelected = false
                break
            }
        }
        return allSelected
    }
    
    public func isNoneSelected() -> Bool {
        var noneSelected: Bool = true
        for subDSItem in self._subDS {
            if subDSItem.isNoneSelected() == false {
                noneSelected = false
                break
            }
        }
        return noneSelected
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
    
    public func clean(_ completion: (() -> ())?) {
        let cleanEnable: Bool = self._cleanCheck()
        if cleanEnable == false {
            return
        }
        let group = DispatchGroup.init()
        for subDSItem in self._subDS {
            group.enter()
            DispatchQueue.global().async{
                subDSItem.clean()
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {[weak self] in
            guard let strongSelf = self else {
                return
            }
            if completion != nil {
                completion!()
            }
            strongSelf._callDelegateDatasChangedFunc()
        }
    }
    
    public func contentForCopy(at row: Int) -> String? {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            return subDS!.contentForCopy(at: realRow)
        } else {
            return nil
        }
    }
    
    public func pathForOpen(at row: Int) -> String? {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            return subDS!.pathForOpen(at: realRow)
        } else {
            return nil
        }
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
    
    public func _cleanCheck() -> Bool {
        for subDSItem in self._subDS {
            let errorMsg = subDSItem.cleanCheck()
            if errorMsg != nil {
                let alert: NSAlert = NSAlert.init()
                alert.alertStyle = NSAlert.Style.critical
                alert.messageText = "Clean check failed!"
                alert.informativeText = errorMsg!
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return false
            }
        }
        return true
    }
    
    private func _onSubDSSelected() {
        self._callDelegateDatasChangedFunc()
    }
    
    private func _onSubDSFoldBtnSelected() {
        self._callDelegateDatasChangedFunc()
    }
    
    private func _onSubDSSectionSelected() {
        self._callDelegateDatasChangedFunc()
    }
}
