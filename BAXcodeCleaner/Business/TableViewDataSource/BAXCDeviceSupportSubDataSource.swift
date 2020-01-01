//
//  BAXCDeviceSupportSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCDeviceSupportSubDataSource: BAXCTableViewSubDataSource {
    var deviceSupportInfos: [(String, String?, Bool)]? = nil
}

extension BAXCDeviceSupportSubDataSource {
    public override func numberOfRows() -> Int {
        return self.deviceSupportInfos == nil ? 1 : self.deviceSupportInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Device Support"
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (path, name, state) = self.deviceSupportInfos![realRow]
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
            var newAppInfos: [(String, String?, Bool)] = []
            for (path, name) in devices! {
                var finded: Bool = false
                if self.deviceSupportInfos != nil {
                    for (oldPath, _, oldState) in self.deviceSupportInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, false))
                }
            }
            self.deviceSupportInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, state) in self.deviceSupportInfos! {
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
        for (path, name, _) in self.deviceSupportInfos! {
            self.deviceSupportInfos![index] = (path, name, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.deviceSupportInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, _) in self.deviceSupportInfos! {
            self.deviceSupportInfos![index] = (path, name, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
    }
}

extension BAXCDeviceSupportSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.deviceSupportInfos == nil || realIndex >= self.deviceSupportInfos!.count {
            return
        }
        let (path, name, _) = self.deviceSupportInfos![realIndex]
        self.deviceSupportInfos![realIndex] = (path, name, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
}
