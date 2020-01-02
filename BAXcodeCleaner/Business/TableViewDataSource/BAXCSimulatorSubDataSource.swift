//
//  BAXCSimulatorSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCSimulatorSubDataSource: BAXCTableViewSubDataSource {
    var simulatoInfos: [(String, String?, String?, String?, Int, Bool)]? = nil
}

extension BAXCSimulatorSubDataSource {
    public override func numberOfRows() -> Int {
        return self.simulatoInfos == nil ? 1 : self.simulatoInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Simulator Devices"
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (path, name, model, version, size, state) = self.simulatoInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = (model != nil && version != nil) ? (String.init(format: "%@(%@)", model!, version!)) : name
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
        let devices: [(String, String?, String?, String?)]? = BAXCSimulatorManager.simulators()
        if devices == nil {
            self.simulatoInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, String?, Int, Bool)] = []
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
            }
            self.simulatoInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, _, _, state) in self.simulatoInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func selectAll() {
        if self.simulatoInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, model, version, size, _) in self.simulatoInfos! {
            self.simulatoInfos![index] = (path, name, model, version, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
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
    }
}

extension BAXCSimulatorSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.simulatoInfos == nil || realIndex >= self.simulatoInfos!.count {
            return
        }
        let (path, name, model, version, size, _) = self.simulatoInfos![realIndex]
        self.simulatoInfos![realIndex] = (path, name, model, version, size, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
}


