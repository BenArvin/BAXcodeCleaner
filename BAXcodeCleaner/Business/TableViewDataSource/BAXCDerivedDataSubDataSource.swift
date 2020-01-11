//
//  BAXCDerivedDataSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCDerivedDataSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var derivedDataInfos: [(String, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0

    public override func numberOfRows() -> Int {
        if self.derivedDataInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.derivedDataInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCell? = cell as? BAXCSectionTitleCell
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Derived Data"
                        sectiontitleCell!.isFolded = self.isFolded
                    }
                } else if column == 2 {
                    let sizeCell: BAXCSectionSizeCell? = cell as? BAXCSectionSizeCell
                    if sizeCell != nil {
                        sizeCell!.size = self.fullSize
                    }
                } else if column == 3 {
                    let checkBox: BAXCSectionCheckBoxCell? = cell as? BAXCSectionCheckBoxCell
                    if checkBox != nil {
                        if self.isAllSelected() == true {
                            checkBox!.state = BAXCTPCheckBox.State.Check
                        } else if self.isNoneSelected() == true {
                            checkBox!.state = BAXCTPCheckBox.State.Uncheck
                        } else {
                            checkBox!.state = BAXCTPCheckBox.State.Part
                        }
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (_, name, targetPath, size, state) = self.derivedDataInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
                    if titleCell != nil {
                        titleCell!.text = name
                    }
                } else if column == 1 {
                    let contentCell: BAXCContentCell? = cell as? BAXCContentCell
                    if contentCell != nil {
                        if targetPath != nil {
                            let (isExisted, _) = BAXCFileUtil.isPathExisted(targetPath!)
                            contentCell!.text = String.init(format: "%@%@", isExisted == true ? "" : "⚠️", targetPath!)
                        } else {
                            contentCell!.text = "⚠️"
                        }
                    }
                } else if column == 2 {
                    let sizeCell: BAXCFileSizeCell? = cell as? BAXCFileSizeCell
                    if sizeCell != nil {
                        sizeCell!.size = size
                    }
                } else if column == 3 {
                    let checkboxCell: BAXCCheckBoxCell? = cell as? BAXCCheckBoxCell
                    if checkboxCell != nil {
                        checkboxCell!.selected = state
                    }
                }
            }
        }
    }
    
    public override func refresh() {
        let derivedDatas: [(String, String?, String?)]? = BAXCDerivedDataManager.items()
        if derivedDatas == nil {
            self.derivedDataInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, name, targetPath) in derivedDatas! {
                let size: Int = BAXCFileUtil.size(path)
                var finded: Bool = false
                if self.derivedDataInfos != nil {
                    for (oldPath, _, _, _, oldState) in self.derivedDataInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, targetPath, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, targetPath, size, false))
                }
                self.fullSize = self.fullSize + size
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, _, size0, _) = arg0
                let (_, _, _, size1, _) = arg1
                return size0 > size1
            }
            self.derivedDataInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        if self.derivedDataInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.derivedDataInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneSelected() -> Bool {
        if self.derivedDataInfos == nil {
            return true
        }
        var noneSelected: Bool = true
        for (_, _, _, _, state) in self.derivedDataInfos! {
            if state == true {
                noneSelected = false
            }
        }
        return noneSelected
    }
    
    public override func selectAll() {
        if self.derivedDataInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, targetPath, size, _) in self.derivedDataInfos! {
            self.derivedDataInfos![index] = (path, name, targetPath, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.derivedDataInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, targetPath, size, _) in self.derivedDataInfos! {
            self.derivedDataInfos![index] = (path, name, targetPath, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
        if self.derivedDataInfos == nil {
            return
        }
        for (path, _, _, _, state) in self.derivedDataInfos! {
            if state == true {
                BAXCFileUtil.recycle(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.derivedDataInfos == nil || row > self.derivedDataInfos!.count {
            return nil
        }
        let (path, name, _, size, _) = self.derivedDataInfos![row - 1]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.derivedDataInfos == nil || row > self.derivedDataInfos!.count {
            return nil
        }
        let (path, _, _, _, _) = self.derivedDataInfos![row - 1]
        return path
    }
    
    public override func size() -> (Int, Int) {
        if self.derivedDataInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        for (_, _, _, size, state) in self.derivedDataInfos! {
            total = total + size
            if state == true {
                selected = selected + size
            }
        }
        return (total, selected)
    }
}

extension BAXCDerivedDataSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCell) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.derivedDataInfos == nil || realIndex >= self.derivedDataInfos!.count {
            return
        }
        let (path, name, targetPath, size, _) = self.derivedDataInfos![realIndex]
        self.derivedDataInfos![realIndex] = (path, name, targetPath, size, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
    
    public override func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCell) {
        self.isFolded = !self.isFolded
        if self.onFoldBtnSelected != nil {
            self.onFoldBtnSelected!()
        }
    }
    
    public override func onSectionCheckBoxSelected(cell: BAXCSectionCheckBoxCell) {
        if self.isNoneSelected() {
            self.selectAll()
        } else {
            self.unselectAll()
        }
        if self.onSectionSelected != nil {
            self.onSectionSelected!()
        }
    }
}
