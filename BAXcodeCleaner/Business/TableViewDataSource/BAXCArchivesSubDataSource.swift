//
//  BAXCArchivesSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCArchivesSubDataSource: BAXCTableViewSubDataSource {
    var archiveInfos: [(String, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
    
    public override func title() -> String {
        return "Archives"
    }
    
    public override func description() -> String {
        return "History archive files for your project, you can clean it if you don't need it anymore."
    }

    public override func numberOfRows() -> Int {
        if self.archiveInfos == nil {
            return 0
        }
        return self.archiveInfos!.count
    }
    
    public override func numberOfColumns() -> Int {
        return 5
    }
    
    public override func titleFor(column: Int) -> String {
        if column == 0 {
            return "name"
        } else if column == 1 {
            return "creation date"
        } else if column == 2 {
            return "path"
        } else if column == 3 {
            return "size"
        } else {
            return super.titleFor(column: column)
        }
    }
    
    public override func maxWidthFor(column: Int) -> CGFloat {
        if column == 4 {
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
            return 0.2 * realWidth
        } else if column == 2 {
            return 0.5 * realWidth
        } else if column == 3 {
            return 0.1 * realWidth
        } else if column == 4 {
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
            let result: BAXCContentCell = BAXCContentCell.init()
            result.identifier = NSUserInterfaceItemIdentifier.init(BAXCContentCell.identifier)
            result.index = row
            return result
        } else if column == 3 {
            let result: BAXCFileSizeCell = BAXCFileSizeCell.init()
            result.identifier = NSUserInterfaceItemIdentifier.init(BAXCFileSizeCell.identifier)
            result.index = row
            return result
        } else if column == 4 {
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
        let (name, creationDate, path, size, state) = self.archiveInfos![row]
        if column == 0 {
            let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
            if titleCell != nil {
                titleCell!.text = name
            }
        } else if column == 1 {
            let contentCell: BAXCContentCell? = cell as? BAXCContentCell
            if contentCell != nil {
                contentCell!.text = creationDate
            }
        } else if column == 2 {
            let contentCell: BAXCContentCell? = cell as? BAXCContentCell
            if contentCell != nil {
                contentCell!.text = path
            }
        } else if column == 3 {
            let sizeCell: BAXCFileSizeCell? = cell as? BAXCFileSizeCell
            if sizeCell != nil {
                sizeCell!.size = size
            }
        } else if column == 4 {
            let checkboxCell: BAXCCheckBoxCell? = cell as? BAXCCheckBoxCell
            if checkboxCell != nil {
                checkboxCell!.selected = state
            }
        }
    }
    
    public override func refresh() {
        let datas: ([(String, String?, String?, Int)]?, Int) = BAXCArchivesTrashManager.datas() as! ([(String, String?, String?, Int)]?, Int)
        let (devices, fullSize) = datas
        if devices == nil {
            self.archiveInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, Int, Bool)] = []
            self.fullSize = fullSize
            for (name, creationDate, path, size) in devices! {
                if size == 0 {
                    continue
                }
                var finded: Bool = false
                if self.archiveInfos != nil {
                    for (_, _, oldPath, _, oldState) in self.archiveInfos! {
                        if oldPath == path {
                            newAppInfos.append((name, creationDate, path, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((name, creationDate, path, size, false))
                }
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, _, size0, _) = arg0
                let (_, _, _, size1, _) = arg1
                return size0 > size1
            }
            self.archiveInfos = newAppInfos
        }
    }
    
    public override func isAllChecked() -> Bool {
        if self.archiveInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.archiveInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneChecked() -> Bool {
        if self.archiveInfos == nil {
            return true
        }
        var noneSelected: Bool = true
        for (_, _, _, _, state) in self.archiveInfos! {
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
        if row < 0 || self.archiveInfos == nil || row >= self.archiveInfos!.count {
            return
        }
        let (name, creationDate, path, size, state) = self.archiveInfos![row]
        self.archiveInfos![row] = (name, creationDate, path, size, !state)
    }
    
    public override func checkAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (name, creationDate, path, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (name, creationDate, path, size, true)
            index = index + 1
        }
    }
    
    public override func uncheckAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (name, creationDate, path, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (name, creationDate, path, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> (Bool, String?) {
        return (true, nil)
    }
    
    public override func clean() {
        if self.archiveInfos == nil {
            return
        }
        for (_, _, path, _, state) in self.archiveInfos! {
            if state == true {
                BAXCArchivesTrashManager.clean(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row < 0 || self.archiveInfos == nil || row > self.archiveInfos!.count {
            return nil
        }
        let (name, _, path, size, _) = self.archiveInfos![row]
        return String.init(format: "%@  %@  %@", name, path!, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row < 0 || self.archiveInfos == nil || row > self.archiveInfos!.count {
            return nil
        }
        let (_, _, path, _, _) = self.archiveInfos![row]
        return path
    }
    
    public override func size() -> (Int, Int) {
        if self.archiveInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        for (_, _, _, size, state) in self.archiveInfos! {
            total = total + size
            if state == true {
                selected = selected + size
            }
        }
        return (total, selected)
    }
}

