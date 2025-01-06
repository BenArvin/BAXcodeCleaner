//
//  BAXCSimulatorDeviceSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCSimulatorDeviceSubDataSource: BAXCTableViewSubDataSource {
    var simulatoInfos: [(Int, String, String?, String?, String?, Int, Int)]? = nil
    var fullSize: Int = 0
    
    public override func title() -> String {
        return "Simulator Devices"
    }
    
    public override func description() -> String {
        return "Simulator devices and datas for Xcode, clean it if unnecessary."
    }

    public override func numberOfRows() -> Int {
        if self.simulatoInfos == nil {
            return 0
        }
        return self.simulatoInfos!.count
    }
    
    public override func numberOfColumns() -> Int {
        return 4
    }
    
    public override func titleFor(column: Int) -> String {
        if column == 0 {
            return "name"
        } else if column == 1 {
            return "path"
        } else if column == 2 {
            return "size"
        } else {
            return super.titleFor(column: column)
        }
    }
    
    public override func maxWidthFor(column: Int) -> CGFloat {
        if column == 3 {
            return 30
        } else {
            return super.maxWidthFor(column: column)
        }
    }
    
    public override func defaultWidthFor(column: Int, totalWidth: CGFloat) -> CGFloat {
        let realWidth = totalWidth - 30
        if column == 0 {
            return 0.2 * realWidth
        } else if column == 1 {
            return 0.7 * realWidth
        } else if column == 2 {
            return 0.1 * realWidth
        } else if column == 3 {
            return 30
        } else {
            return super.defaultWidthFor(column: column, totalWidth: totalWidth)
        }
    }
    
    public override func cell(for row: Int, column: Int, delegate: Any) -> NSTableCellView? {
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
            result.delegate = (delegate as! BAXCCheckBoxCellDelegate)
            return result
        } else {
            return super.cell(for: row, column: column, delegate: delegate)
        }
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        let (level, path, name, model, version, size, state) = self.simulatoInfos![row]
        if column == 0 {
            let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
            if titleCell != nil {
                if level == 0 {
                    titleCell!.text = (model != nil && version != nil) ? (String.init(format: "%@(%@)", model!, version!)) : name
                } else {
                    titleCell!.text = name
                }
                for _ in 0..<level {
                    titleCell!.text = "\t" + titleCell!.text!
                }
            }
        } else if column == 1 {
            let contentCell: BAXCContentCell? = cell as? BAXCContentCell
            if contentCell != nil {
                contentCell!.text = path
            }
        } else if column == 2 {
            let sizeCell: BAXCFileSizeCell? = cell as? BAXCFileSizeCell
            if sizeCell != nil {
                sizeCell!.size = size
            }
        } else if column == 3 {
            let checkboxCell: BAXCCheckBoxCell? = cell as? BAXCCheckBoxCell
            if checkboxCell != nil {
                if state == 0 {
                    checkboxCell!.state = .Uncheck
                } else if state == 1 {
                    checkboxCell!.state = .Check
                } else {
                    checkboxCell!.state = .Part
                }
            }
        }
    }
    
    public override func refresh() {
        let datas: ([(Int, String, String?, String?, String?, Int)]?, Int) = BAXCSimulatorDeviceTrashManager.datas() as! ([(Int, String, String?, String?, String?, Int)]?, Int)
        let (devices, fullSize) = datas
        if devices == nil {
            self.simulatoInfos = nil
        } else {
            var newAppInfos: [(Int, String, String?, String?, String?, Int, Int)] = []
            self.fullSize = fullSize
            for (level, path, name, model, version, size) in devices! {
                if size == 0 {
                    continue
                }
                var finded: Bool = false
                if self.simulatoInfos != nil {
                    for (level, oldPath, _, _, _, _, oldState) in self.simulatoInfos! {
                        if oldPath == path {
                            newAppInfos.append((level, path, name, model, version, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((level, path, name, model, version, size, 0))
                }
            }
            self.simulatoInfos = newAppInfos
        }
    }
    
    public override func isAllChecked() -> Bool {
        if self.simulatoInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, _, _, _, state) in self.simulatoInfos! {
            if state != 1 {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneChecked() -> Bool {
        if self.simulatoInfos == nil {
            return true
        }
        var noneSelected: Bool = true
        for (_, _, _, _, _, _, state) in self.simulatoInfos! {
            if state != 0 {
                noneSelected = false
            }
        }
        return noneSelected
    }
    
    public override func onCheckEventForSection() {
        if self.isNoneChecked() == true {
            self.checkAll()
        } else {
            self.uncheckAll()
        }
    }
    
    public override func onCheckEventForRow(_ row: Int) -> BAXCTPCheckBox.State {
        if row < 0 || self.simulatoInfos == nil || row >= self.simulatoInfos!.count {
            return .Uncheck
        }
        let (level, path, name, model, version, size, state) = self.simulatoInfos![row]
        if level == 0 {
            if state == 0 {
                self.simulatoInfos![row] = (level, path, name, model, version, size, 1)
                self._markSubRows(row, 1)
                return .Check
            } else if state == 1 {
                self.simulatoInfos![row] = (level, path, name, model, version, size, 0)
                self._markSubRows(row, 0)
                return .Uncheck
            } else {
                self.simulatoInfos![row] = (level, path, name, model, version, size, 1)
                self._markSubRows(row, 1)
                return .Check
            }
        } else {
            self.simulatoInfos![row] = (level, path, name, model, version, size, state == 0 ? 1 : 0)
            self._markSuperRow(row)
            return state == 0 ? .Check : .Uncheck
        }
    }
    
    private func _markSubRows(_ startRow: Int, _ newState: Int) {
        var row = startRow + 1
        while true {
            if row >= self.simulatoInfos!.count {
                break
            }
            let (level, path, name, model, version, size, _) = self.simulatoInfos![row]
            if level == 0 {
                break
            }
            self.simulatoInfos![row] = (level, path, name, model, version, size, newState)
            row = row + 1
        }
    }
    
    private func _markSuperRow(_ startRow: Int) {
        var superRow = startRow
        while true {
            if superRow < 0 {
                break
            }
            let (level, _, _, _, _, _, _) = self.simulatoInfos![superRow]
            if level == 0 {
                break
            }
            superRow = superRow - 1
        }
        if superRow < 0 {
            return
        }
        var allSelected = true
        var noneSelected = true
        var rowTmp = superRow + 1
        while true {
            if rowTmp >= self.simulatoInfos!.count {
                break
            }
            let (level, _, _, _, _, _, state) = self.simulatoInfos![rowTmp]
            if level == 0 {
                break
            }
            if state == 0 {
                allSelected = false
            } else {
                noneSelected = false
            }
            rowTmp = rowTmp + 1
        }
        var newState = 2
        if allSelected {
            newState = 1
        } else if noneSelected {
            newState = 0
        }
        let (level, path, name, model, version, size, _) = self.simulatoInfos![superRow]
        self.simulatoInfos![superRow] = (level, path, name, model, version, size, newState)
    }
    
    public override func checkAll() {
        if self.simulatoInfos == nil {
            return
        }
        var index: Int = 0
        for (level, path, name, model, version, size, _) in self.simulatoInfos! {
            self.simulatoInfos![index] = (level, path, name, model, version, size, 1)
            index = index + 1
        }
    }
    
    public override func uncheckAll() {
        if self.simulatoInfos == nil {
            return
        }
        var index: Int = 0
        for (level, path, name, model, version, size, _) in self.simulatoInfos! {
            self.simulatoInfos![index] = (level, path, name, model, version, size, 0)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> (Bool, String?) {
        return (true, nil)
    }
    
    public override func clean() {
        if self.simulatoInfos == nil {
            return
        }
        var superSelected = false
        for (level, path, _, _, _, _, state) in self.simulatoInfos! {
            if level == 0 {
                if state == 1 {
                    superSelected = true
                    BAXCSimulatorDeviceTrashManager.clean(path)
                } else {
                    superSelected = false
                }
            } else {
                if !superSelected && state == 1 {
                    BAXCFileUtil.recycle(path)
                }
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row < 0 || self.simulatoInfos == nil || row > self.simulatoInfos!.count {
            return nil
        }
        let (_, path, name, _, _, size, _) = self.simulatoInfos![row]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row < 0 || self.simulatoInfos == nil || row > self.simulatoInfos!.count {
            return nil
        }
        let (_, path, _, _, _, _, _) = self.simulatoInfos![row]
        return path
    }
    
    public override func size() -> (Int, Int) {
        if self.simulatoInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        var superSelected = false
        for (level, _, _, _, _, size, state) in self.simulatoInfos! {
            if level == 0 {
                total = total + size
                if state == 1 {
                    superSelected = true
                    selected = selected + size
                } else {
                    superSelected = false
                }
            } else {
                if !superSelected && state == 1 {
                    selected = selected + size
                }
            }
        }
        return (total, selected)
    }
}
