//
//  BAXCSimulatorCacheSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCSimulatorCacheSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var cacheInfos: [(String, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
}

extension BAXCSimulatorCacheSubDataSource {
    public override func numberOfRows() -> Int {
        if self.cacheInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.cacheInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Simulator Caches (dyld)"
                        sectiontitleCell!.isFolded = self.isFolded
                    }
                } else if column == 2 {
                    let sizeCell: BAXCSectionSizeCellView? = cell as? BAXCSectionSizeCellView
                    if sizeCell != nil {
                        sizeCell!.size = self.fullSize
                    }
                } else if column == 3 {
                    let checkBox: BAXCSectionCheckBoxCellView? = cell as? BAXCSectionCheckBoxCellView
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
                let (path, _, abname, size, state) = self.cacheInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = abname
                    }
                } else if column == 1 {
                    let contentCell: BAXCContentCellView? = cell as? BAXCContentCellView
                    if contentCell != nil {
                        contentCell!.text = path
                    }
                } else if column == 2 {
                    let sizeCell: BAXCFileSizeCellView? = cell as? BAXCFileSizeCellView
                    if sizeCell != nil {
                        sizeCell!.size = size
                    }
                } else if column == 3 {
                    let checkboxCell: BAXCCheckBoxCellView? = cell as? BAXCCheckBoxCellView
                    if checkboxCell != nil {
                        checkboxCell!.selected = state
                    }
                }
            }
        }
    }
    
    public override func refresh() {
        let caches: [(String, String?, String?)]? = BAXCSimulatorManager.caches()
        if caches == nil {
            self.cacheInfos = nil
        } else {
            var newCacheInfos: [(String, String?, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, name, abname) in caches! {
                let size: Int = BAXCFileUtil.size(path)
                if size == 0 {
                    continue
                }
                var finded: Bool = false
                if self.cacheInfos != nil {
                    for (oldPath, _, _, _, oldState) in self.cacheInfos! {
                        if oldPath == path {
                            newCacheInfos.append((path, name, abname, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newCacheInfos.append((path, name, abname, size, false))
                }
                self.fullSize = self.fullSize + size
            }
            newCacheInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, _, size0, _) = arg0
                let (_, _, _, size1, _) = arg1
                return size0 > size1
            }
            self.cacheInfos = newCacheInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.cacheInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneSelected() -> Bool {
        var noneSelected: Bool = true
        for (_, _, _, _, state) in self.cacheInfos! {
            if state == true {
                noneSelected = false
            }
        }
        return noneSelected
    }
    
    public override func selectAll() {
        if self.cacheInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, abname, size, _) in self.cacheInfos! {
            self.cacheInfos![index] = (path, name, abname, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.cacheInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, abname, size, _) in self.cacheInfos! {
            self.cacheInfos![index] = (path, name, abname, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
        for (path, _, _, _, state) in self.cacheInfos! {
            if state == true {
                let dataPath = BAXCFileUtil.assemblePath(path, "data")
                if dataPath != nil && !dataPath!.isEmpty {
                    BAXCFileUtil.recycle(dataPath!)
                }
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.cacheInfos == nil || row > self.cacheInfos!.count {
            return nil
        }
        let (path, name, _, size, _) = self.cacheInfos![row - 1]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.cacheInfos == nil || row > self.cacheInfos!.count {
            return nil
        }
        let (path, _, _, _, _) = self.cacheInfos![row - 1]
        return path
    }
}

extension BAXCSimulatorCacheSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.cacheInfos == nil || realIndex >= self.cacheInfos!.count {
            return
        }
        let (path, name, abname, size, _) = self.cacheInfos![realIndex]
        self.cacheInfos![realIndex] = (path, name, abname, size, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
    
    public override func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCellView) {
        self.isFolded = !self.isFolded
        if self.onFoldBtnSelected != nil {
            self.onFoldBtnSelected!()
        }
    }
    
    public override func onSectionCheckBoxSelected(cell: BAXCSectionCheckBoxCellView) {
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


