//
//  BAXCSimulatorCacheSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCSimulatorCacheSubDataSource: BAXCTableViewSubDataSource {
    var cacheInfos: [(String, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
    
    public override func title() -> String {
        return "Simulator Caches"
    }
    
    public override func description() -> String {
        return "Caches for simulator devices, currently it means dyld file only, you can clean it if you don't need it."
    }

    public override func numberOfRows() -> Int {
        if self.cacheInfos == nil {
            return 0
        }
        return self.cacheInfos!.count
    }
    
    public override func numberOfColumns() -> Int {
        return 4
    }
    
    public override func titleFor(column: Int) -> String {
        if column == 0 {
            return "version"
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
        let (path, _, abname, size, state) = self.cacheInfos![row]
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
    
    public override func refresh() {
        let datas: ([(String, String?, String?, Int)]?, Int) = BAXCSimulatorCacheTrashManager.datas() as! ([(String, String?, String?, Int)]?, Int)
        let (caches, fullSize) = datas
        if caches == nil {
            self.cacheInfos = nil
        } else {
            var newCacheInfos: [(String, String?, String?, Int, Bool)] = []
            self.fullSize = fullSize
            for (path, name, abname, size) in caches! {
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
        if row < 0 || self.cacheInfos == nil || row >= self.cacheInfos!.count {
            return
        }
        let (path, name, abname, size, state) = self.cacheInfos![row]
        self.cacheInfos![row] = (path, name, abname, size, !state)
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
                BAXCSimulatorCacheTrashManager.clean(path)
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
}
