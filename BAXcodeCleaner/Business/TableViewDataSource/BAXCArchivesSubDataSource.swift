//
//  BAXCArchivesSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCArchivesSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var archiveInfos: [(String, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
}

extension BAXCArchivesSubDataSource {
    public override func numberOfRows() -> Int {
        if self.archiveInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.archiveInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCell? = cell as? BAXCSectionTitleCell
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Archives"
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
                let (_, name, inners, size, state) = self.archiveInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
                    if titleCell != nil {
                        titleCell!.text = name
                    }
                } else if column == 1 {
                    let contentCell: BAXCContentCell? = cell as? BAXCContentCell
                    if contentCell != nil {
                        contentCell!.text = inners
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
        let devices: [(String, String?, String?)]? = BAXCArchivesManager.archives()
        if devices == nil {
            self.archiveInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, name, inners) in devices! {
                let size: Int = BAXCFileUtil.size(path)
                var finded: Bool = false
                if self.archiveInfos != nil {
                    for (oldPath, _, _, _, oldState) in self.archiveInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, inners, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, inners, size, false))
                }
                self.fullSize = self.fullSize + size
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, _, size0, _) = arg0
                let (_, _, _, size1, _) = arg1
                return size0 > size1
            }
            self.archiveInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.archiveInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneSelected() -> Bool {
        var noneSelected: Bool = true
        for (_, _, _, _, state) in self.archiveInfos! {
            if state == true {
                noneSelected = false
            }
        }
        return noneSelected
    }
    
    public override func selectAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, inners, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (path, name, inners, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, inners, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (path, name, inners, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
        for (path, _, _, _, state) in self.archiveInfos! {
            if state == true {
                BAXCFileUtil.recycle(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.archiveInfos == nil || row > self.archiveInfos!.count {
            return nil
        }
        let (path, name, _, size, _) = self.archiveInfos![row - 1]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.archiveInfos == nil || row > self.archiveInfos!.count {
            return nil
        }
        let (path, _, _, _, _) = self.archiveInfos![row - 1]
        return path
    }
}

extension BAXCArchivesSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCell) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.archiveInfos == nil || realIndex >= self.archiveInfos!.count {
            return
        }
        let (path, name, inners, size, _) = self.archiveInfos![realIndex]
        self.archiveInfos![realIndex] = (path, name, inners, size, cell.selected)
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

