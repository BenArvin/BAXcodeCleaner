//
//  BAXCTableViewDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCTableViewDataSourceProtocol_new: class {
    func onDatasChanged()
    func onRowCheckBtnSelected(cell: NSTableCellView)
    func onSectionCheckBtnSelected(cell: NSTableCellView)
    func onFoldBtnSelected(cell: NSTableCellView)
    func onTipsBtnSelected(cell: NSTableCellView)
}

public class BAXCTableViewDataSource {
    
    public enum SelectState: Int {
        case None = 0
        case Part = 1
        case All = 2
    }
    
    public var delegate: BAXCTableViewDataSourceProtocol_new?
    
    private lazy var _subDS: [BAXCTableViewSubDataSource] = {
        let result: [BAXCTableViewSubDataSource] = [BAXCDerivedDataSubDataSource(),
                                                    BAXCArchivesSubDataSource(),
                                                    BAXCDeviceSupportSubDataSource(),
                                                    BAXCSimulatorDeviceSubDataSource(),
                                                    BAXCSimulatorCacheSubDataSource(),
                                                    BAXCApplicationsSubDataSource()]
//        let result: [BAXCTableViewSubDataSource] = [BAXCArchivesSubDataSource(), BAXCSimulatorDeviceSubDataSource()]
        for subDSItem in result {
            subDSItem.onRowCheckBtnSelected = self._onSubDSRowCheckBtnSelected
            subDSItem.onSectionCheckBtnSelected = self._onSubDSSectionCheckBtnSelected
            subDSItem.onFoldBtnSelected = self._onSubDSFoldBtnSelected
            subDSItem.onTipsBtnSelected = self._onSubDStipsBtnSelected
        }
        return result
    }()
    
    init() {
    }
}

// MARK: - public methods
extension BAXCTableViewDataSource {
    public func numberOfKinds() -> Int {
        return self._subDS.count
    }
    
//    public func numberOfRows(in kind: Int) -> Int {
//        let item = self._subDS[kind]
//        return item.numberOfRows()
//    }
    
    public func height(for kind: Int) -> CGFloat {
        return 20
    }
    
    public func createKindCell(for kind: Int) -> NSTableCellView {
        let result: BAXCNestedTableCell = BAXCNestedTableCell.init()
        result.identifier = NSUserInterfaceItemIdentifier.init(BAXCNestedTableCell.identifier)
        return result
    }
    
    public func dataSourceForkind(_ kind: Int) -> BAXCTableViewSubDataSource {
        return self._subDS[kind]
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
    
    public func isAllChecked() -> Bool {
        var allSelected: Bool = true
        for subDSItem in self._subDS {
            if subDSItem.isAllChecked() == false {
                allSelected = false
                break
            }
        }
        return allSelected
    }
    
    public func isNoneChecked() -> Bool {
        var noneSelected: Bool = true
        for subDSItem in self._subDS {
            if subDSItem.isNoneChecked() == false {
                noneSelected = false
                break
            }
        }
        return noneSelected
    }
    
    public func onCheckEventForSection(_ row: Int) {
        let (subDS, _) = self._subDataSource(for: row)
        if subDS == nil {
            return
        }
        subDS!.onCheckEventForSection()
        self._callDelegateDatasChangedFunc()
    }
    
    public func onCheckEventForRow(_ row: Int) {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS == nil {
            return
        }
        subDS!.onCheckEventForRow(realRow)
        self._callDelegateDatasChangedFunc()
    }
    
    public func checkAll() {
        for subDSItem in self._subDS {
            subDSItem.checkAll()
        }
        self._callDelegateDatasChangedFunc()
    }
    
    public func uncheckAll() {
        for subDSItem in self._subDS {
            subDSItem.uncheckAll()
        }
        self._callDelegateDatasChangedFunc()
    }
    
    public func clean(_ completion: ((_: Bool, _: String?) -> ())?) {
        let (cleanEnable, errorMsg) = self._cleanCheck()
        if cleanEnable == false {
            if completion != nil {
                completion!(false, errorMsg)
            }
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
                completion!(true, nil)
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
    
    public func isSectionRow(_ row: Int) -> Bool {
        let (subDS, realRow) = self._subDataSource(for: row)
        if subDS != nil {
            return realRow == 0 ? true : false
        } else {
            return false
        }
    }
    
    public func size() -> (Int, Int) {
        var total = 0
        var selected = 0
        for subDSItem in self._subDS {
            let (totalTmp, selectedTmp) = subDSItem.size()
            total = total + totalTmp
            selected = selected + selectedTmp
        }
        return (total, selected)
    }
    
    public func tipsForHelp(_ row: Int) -> (String?, String?) {
        let (subDS, _) = self._subDataSource(for: row)
        if subDS != nil {
            return subDS!.tipsForHelp()
        } else {
            return (nil, nil)
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
    
    private func _subDataSource(for row: Int) -> (BAXCTableViewSubDataSource?, Int) {
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
    
    public func _cleanCheck() -> (Bool, String?) {
        for subDSItem in self._subDS {
            let (valid, errorMsg) = subDSItem.cleanCheck()
            if valid == false {
                return (false, errorMsg)
            }
        }
        return (true, nil)
    }
    
    private func _onSubDSRowCheckBtnSelected(cell: NSTableCellView) {
        if self.delegate != nil {
            self.delegate!.onRowCheckBtnSelected(cell: cell)
        }
    }
    
    private func _onSubDSSectionCheckBtnSelected(cell: NSTableCellView) {
        if self.delegate != nil {
            self.delegate!.onSectionCheckBtnSelected(cell: cell)
        }
    }
    
    private func _onSubDSFoldBtnSelected(cell: NSTableCellView) {
        if self.delegate != nil {
            self.delegate!.onFoldBtnSelected(cell: cell)
        }
    }
    
    private func _onSubDStipsBtnSelected(cell: NSTableCellView) {
        if self.delegate != nil {
            self.delegate!.onTipsBtnSelected(cell: cell)
        }
    }
}
