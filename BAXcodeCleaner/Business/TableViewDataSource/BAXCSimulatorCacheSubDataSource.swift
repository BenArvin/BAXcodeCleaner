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
                    let sectiontitleCell: BAXCSectionTitleCell? = cell as? BAXCSectionTitleCell
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Simulator Caches"
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
                        if self.isAllChecked() == true {
                            checkBox!.state = BAXCTPCheckBox.State.Check
                        } else if self.isNoneChecked() == true {
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
                    let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
                    if titleCell != nil {
                        titleCell!.text = abname
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
    
    public override func isAllChecked() -> Bool {
        if self.cacheInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.cacheInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneChecked() -> Bool {
        if self.cacheInfos == nil {
            return true
        }
        var noneSelected: Bool = true
        for (_, _, _, _, state) in self.cacheInfos! {
            if state == true {
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
    
    public override func onCheckEventForRow(_ row: Int) {
        let realIndex = row - 1
        if realIndex < 0 || self.cacheInfos == nil || realIndex >= self.cacheInfos!.count {
            return
        }
        let (path, name, abname, size, state) = self.cacheInfos![realIndex]
        self.cacheInfos![realIndex] = (path, name, abname, size, !state)
    }
    
    public override func onFoldEvent() {
        self.isFolded = !self.isFolded
    }
    
    public override func checkAll() {
        if self.cacheInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, abname, size, _) in self.cacheInfos! {
            self.cacheInfos![index] = (path, name, abname, size, true)
            index = index + 1
        }
    }
    
    public override func uncheckAll() {
        if self.cacheInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, abname, size, _) in self.cacheInfos! {
            self.cacheInfos![index] = (path, name, abname, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> (Bool, String?) {
        return (true, nil)
    }
    
    public override func clean() {
        if self.cacheInfos == nil {
            return
        }
        for (path, _, _, _, state) in self.cacheInfos! {
            if state == true {
                BAXCFileUtil.recycle(path)
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
    
    public override func size() -> (Int, Int) {
        if self.cacheInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        for (_, _, _, size, state) in self.cacheInfos! {
            total = total + size
            if state == true {
                selected = selected + size
            }
        }
        return (total, selected)
    }
    
    public override func tipsForHelp() -> (String?, String?) {
        return ("Simulator Caches", "Caches for simulator devices, currently it means dyld file only, you can clean it if you don't need it.")
    }
}
