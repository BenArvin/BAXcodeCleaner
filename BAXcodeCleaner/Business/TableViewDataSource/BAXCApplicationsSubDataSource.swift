//
//  BAXCApplicationsSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCApplicationsSubDataSource: BAXCTableViewSubDataSource {
    var appInfos: [(String, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
    
    public override func title() -> String {
        return "Xcode Applications"
    }
    
    public override func description() -> String {
        return "There might be several Xcode applications in your computer, you can clean old versions if you don't it anymore."
    }

    public override func numberOfRows() -> Int {
        if self.appInfos == nil {
            return 0
        }
        return self.appInfos!.count
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
        let (path, version, size, state) = self.appInfos![row]
        if column == 0 {
            let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
            if titleCell != nil {
                titleCell!.text = version
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
        let datas: ([(String, String?, Int)]?, Int) = BAXCXcodeAppTrashManager.datas() as! ([(String, String?, Int)]?, Int)
        let (apps, fullSize) = datas
        if apps == nil {
            self.appInfos = nil
        } else {
            var newAppInfos: [(String, String?, Int, Bool)] = []
            self.fullSize = fullSize
            for (path, version, size) in apps! {
                if size == 0 {
                    continue
                }
                var finded: Bool = false
                if self.appInfos != nil {
                    for (oldPath, _, _, oldState) in self.appInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, version, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, version, size, false))
                }
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, size0, _) = arg0
                let (_, _, size1, _) = arg1
                return size0 > size1
            }
            self.appInfos = newAppInfos
        }
    }
    
    public override func isAllChecked() -> Bool {
        if self.appInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, state) in self.appInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func isNoneChecked() -> Bool {
        if self.appInfos == nil {
            return true
        }
        var noneSelected: Bool = true
        for (_, _, _, state) in self.appInfos! {
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
        if row < 0 || self.appInfos == nil || row >= self.appInfos!.count {
            return
        }
        let (path, version, size, state) = self.appInfos![row]
        self.appInfos![row] = (path, version, size, !state)
    }
    
    public override func checkAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, size, _) in self.appInfos! {
            self.appInfos![index] = (path, version, size, true)
            index = index + 1
        }
    }
    
    public override func uncheckAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, size, _) in self.appInfos! {
            self.appInfos![index] = (path, version, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> (Bool, String?) {
        if self.isAllChecked() == true {
            return (false, "Can't delete all Xcode applications, please keep one at least.")
        } else {
            return (true, nil)
        }
    }
    
    public override func clean() {
        if self.appInfos == nil {
            return
        }
        for (path, _, _, state) in self.appInfos! {
            if state == true {
                BAXCXcodeAppTrashManager.clean(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row < 0 || self.appInfos == nil || row > self.appInfos!.count {
            return nil
        }
        let (path, version, size, _) = self.appInfos![row]
        return String.init(format: "%@  %@  %@", version ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row < 0 || self.appInfos == nil || row > self.appInfos!.count {
            return nil
        }
        let (path, _, _, _) = self.appInfos![row]
        return path
    }
    
    public override func size() -> (Int, Int) {
        if self.appInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        for (_, _, size, state) in self.appInfos! {
            total = total + size
            if state == true {
                selected = selected + size
            }
        }
        return (total, selected)
    }
}
