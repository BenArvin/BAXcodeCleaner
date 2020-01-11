//
//  BAXCSimulatorDeviceSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCSimulatorDeviceSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var simulatoInfos: [(String, String?, String?, String?, Int, Bool)]? = nil
    var fullSize: Int = 0

    public override func numberOfRows() -> Int {
        if self.simulatoInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.simulatoInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCell? = cell as? BAXCSectionTitleCell
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Simulator Devices"
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
                let (path, name, model, version, size, state) = self.simulatoInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCell? = cell as? BAXCTitleCell
                    if titleCell != nil {
                        titleCell!.text = (model != nil && version != nil) ? (String.init(format: "%@(%@)", model!, version!)) : name
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
        let devices: [(String, String?, String?, String?)]? = BAXCSimulatorManager.devices()
        if devices == nil {
            self.simulatoInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, name, model, version) in devices! {
                let size: Int = BAXCFileUtil.size(path)
                if size == 0 {
                    continue
                }
                var finded: Bool = false
                if self.simulatoInfos != nil {
                    for (oldPath, _, _, _, _, oldState) in self.simulatoInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, model, version, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, model, version, size, false))
                }
                self.fullSize = self.fullSize + size
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, _, _, size0, _) = arg0
                let (_, _, _, _, size1, _) = arg1
                return size0 > size1
            }
            self.simulatoInfos = newAppInfos
        }
    }
    
    public override func isAllChecked() -> Bool {
        if self.simulatoInfos == nil {
            return true
        }
        var allSelected: Bool = true
        for (_, _, _, _, _, state) in self.simulatoInfos! {
            if state == false {
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
        for (_, _, _, _, _, state) in self.simulatoInfos! {
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
        if realIndex < 0 || self.simulatoInfos == nil || realIndex >= self.simulatoInfos!.count {
            return
        }
        let (path, name, model, version, size, state) = self.simulatoInfos![realIndex]
        self.simulatoInfos![realIndex] = (path, name, model, version, size, !state)
    }
    
    public override func onFoldEvent() {
        self.isFolded = !self.isFolded
    }
    
    public override func checkAll() {
        if self.simulatoInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, model, version, size, _) in self.simulatoInfos! {
            self.simulatoInfos![index] = (path, name, model, version, size, true)
            index = index + 1
        }
    }
    
    public override func uncheckAll() {
        if self.simulatoInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, model, version, size, _) in self.simulatoInfos! {
            self.simulatoInfos![index] = (path, name, model, version, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
        if self.simulatoInfos == nil {
            return
        }
        for (path, _, _, _, _, state) in self.simulatoInfos! {
            if state == true {
                let dataPath = BAXCFileUtil.assemblePath(path, "data")
                if dataPath == nil {
                    continue
                }
                let innerPaths: [String]? = BAXCFileUtil.contentsOfDir(dataPath!)
                if innerPaths == nil {
                    continue
                }
                for innerPathItem in innerPaths! {
                    BAXCFileUtil.recycle(innerPathItem)
                }
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.simulatoInfos == nil || row > self.simulatoInfos!.count {
            return nil
        }
        let (path, name, _, _, size, _) = self.simulatoInfos![row - 1]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.simulatoInfos == nil || row > self.simulatoInfos!.count {
            return nil
        }
        let (path, _, _, _, _, _) = self.simulatoInfos![row - 1]
        return path
    }
    
    public override func size() -> (Int, Int) {
        if self.simulatoInfos == nil {
            return (0, 0)
        }
        var total = 0
        var selected = 0
        for (_, _, _, _, size, state) in self.simulatoInfos! {
            total = total + size
            if state == true {
                selected = selected + size
            }
        }
        return (total, selected)
    }
}
