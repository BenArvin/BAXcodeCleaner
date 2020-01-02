//
//  BAXCDerivedDataSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/1.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCDerivedDataSubDataSource: BAXCTableViewSubDataSource {
    var derivedDataInfos: [(String, String?, String?, Int, Bool)]? = nil
}

extension BAXCDerivedDataSubDataSource {
    public override func numberOfRows() -> Int {
        return self.derivedDataInfos == nil ? 1 : self.derivedDataInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Derived Data"
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (_, name, targetPath, size, state) = self.derivedDataInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = name
                    }
                } else if column == 1 {
                    let contentCell: BAXCContentCellView? = cell as? BAXCContentCellView
                    if contentCell != nil {
                        if targetPath != nil {
                            let (isExisted, _) = BAXCFileUtil.isPathExisted(targetPath!)
                            contentCell!.text = String.init(format: "%@%@", isExisted == true ? "" : "⚠️", targetPath!)
                        }
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
        let derivedDatas: [(String, String?, String?)]? = BAXCDerivedDataManager.items()
        if derivedDatas == nil {
            self.derivedDataInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, Int, Bool)] = []
            for (path, name, targetPath) in derivedDatas! {
                let size: Int = BAXCFileUtil.size(path)
                var finded: Bool = false
                if self.derivedDataInfos != nil {
                    for (oldPath, _, _, _, oldState) in self.derivedDataInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, targetPath, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, targetPath, size, false))
                }
            }
            self.derivedDataInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.derivedDataInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func selectAll() {
        if self.derivedDataInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, targetPath, size, _) in self.derivedDataInfos! {
            self.derivedDataInfos![index] = (path, name, targetPath, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.derivedDataInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, targetPath, size, _) in self.derivedDataInfos! {
            self.derivedDataInfos![index] = (path, name, targetPath, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
    }
}

extension BAXCDerivedDataSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.derivedDataInfos == nil || realIndex >= self.derivedDataInfos!.count {
            return
        }
        let (path, name, targetPath, size, _) = self.derivedDataInfos![realIndex]
        self.derivedDataInfos![realIndex] = (path, name, targetPath, size, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
}
