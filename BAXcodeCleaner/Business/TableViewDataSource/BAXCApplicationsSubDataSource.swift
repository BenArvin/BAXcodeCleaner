//
//  BAXCApplicationsSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCApplicationsSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var appInfos: [(String, String?, Int, Bool)]? = nil
    var fullSize: Int = 0

    public override func numberOfRows() -> Int {
        if self.appInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.appInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCell? = cell as? BAXCSectionTitleCell
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Xcode Applications"
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
                let (path, version, size, state) = self.appInfos![realRow]
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
        }
    }
    
    public override func refresh() {
        let apps: [(String, String?)]? = BAXCXcodeAppManager.xcodes()
        if apps == nil {
            self.appInfos = nil
        } else {
            var newAppInfos: [(String, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, version) in apps! {
                let size: Int = BAXCFileUtil.size(path)
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
                self.fullSize = self.fullSize + size
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
        let realIndex = row - 1
        if realIndex < 0 || self.appInfos == nil || realIndex >= self.appInfos!.count {
            return
        }
        let (path, version, size, state) = self.appInfos![realIndex]
        self.appInfos![realIndex] = (path, version, size, !state)
    }
    
    public override func onFoldEvent() {
        self.isFolded = !self.isFolded
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
                BAXCFileUtil.recycle(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.appInfos == nil || row > self.appInfos!.count {
            return nil
        }
        let (path, version, size, _) = self.appInfos![row - 1]
        return String.init(format: "%@  %@  %@", version ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.appInfos == nil || row > self.appInfos!.count {
            return nil
        }
        let (path, _, _, _) = self.appInfos![row - 1]
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
    
    public override func tipsForHelp() -> (String?, String?) {
        return ("Xcode Applications", "There might be several Xcode applications in your computer, you can clean old versions if you don't it anymore.")
    }
}
