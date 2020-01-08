//
//  BAXCDeviceSupportSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCDeviceSupportSubDataSource: BAXCTableViewSubDataSource {
    var isFolded: Bool = false
    var deviceSupportInfos: [(String, String?, Int, Bool)]? = nil
    var fullSize: Int = 0
}

extension BAXCDeviceSupportSubDataSource {
    public override func numberOfRows() -> Int {
        if self.deviceSupportInfos == nil {
            return 0
        }
        return self.isFolded == true ? 1 : self.deviceSupportInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Device Support"
                        sectiontitleCell!.isFolded = self.isFolded
                    }
                } else if column == 2 {
                    let sizeCell: BAXCSectionSizeCellView? = cell as? BAXCSectionSizeCellView
                    if sizeCell != nil {
                        sizeCell!.size = self.fullSize
                    }
                } else if column == 3 {
                }
            } else {
                let realRow: Int = row - 1
                let (path, name, size, state) = self.deviceSupportInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = name
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
        let devices: [(String, String?)]? = BAXCDeviceSupportManager.devices()
        if devices == nil {
            self.deviceSupportInfos = nil
        } else {
            var newAppInfos: [(String, String?, Int, Bool)] = []
            self.fullSize = 0
            for (path, name) in devices! {
                let size: Int = BAXCFileUtil.size(path)
                var finded: Bool = false
                if self.deviceSupportInfos != nil {
                    for (oldPath, _, _, oldState) in self.deviceSupportInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, size, false))
                }
                self.fullSize = self.fullSize + size
            }
            newAppInfos.sort { (arg0, arg1) -> Bool in
                let (_, _, size0, _) = arg0
                let (_, _, size1, _) = arg1
                return size0 > size1
            }
            self.deviceSupportInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, state) in self.deviceSupportInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func selectAll() {
        if self.deviceSupportInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, size, _) in self.deviceSupportInfos! {
            self.deviceSupportInfos![index] = (path, name, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.deviceSupportInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, size, _) in self.deviceSupportInfos! {
            self.deviceSupportInfos![index] = (path, name, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
        for (path, _, _, state) in self.deviceSupportInfos! {
            if state == true {
                BAXCFileUtil.recycle(path)
            }
        }
    }
    
    public override func contentForCopy(at row: Int) -> String? {
        if row <= 0 || self.deviceSupportInfos == nil || row > self.deviceSupportInfos!.count {
            return nil
        }
        let (path, name, size, _) = self.deviceSupportInfos![row - 1]
        return String.init(format: "%@  %@  %@", name ?? "", path, String.init(fromSize: size))
    }
    
    public override func pathForOpen(at row: Int) -> String? {
        if row <= 0 || self.deviceSupportInfos == nil || row > self.deviceSupportInfos!.count {
            return nil
        }
        let (path, _, _, _) = self.deviceSupportInfos![row - 1]
        return path
    }
}

extension BAXCDeviceSupportSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.deviceSupportInfos == nil || realIndex >= self.deviceSupportInfos!.count {
            return
        }
        let (path, name, size, _) = self.deviceSupportInfos![realIndex]
        self.deviceSupportInfos![realIndex] = (path, name, size, cell.selected)
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
}
