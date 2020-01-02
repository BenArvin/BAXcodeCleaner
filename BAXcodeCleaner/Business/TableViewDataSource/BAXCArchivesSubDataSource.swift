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
}

extension BAXCArchivesSubDataSource {
    public override func numberOfRows() -> Int {
        return self.archiveInfos == nil ? 1 : self.archiveInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Archives"
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (_, name, inners, size, state) = self.archiveInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = name
                    }
                } else if column == 1 {
                    let contentCell: BAXCContentCellView? = cell as? BAXCContentCellView
                    if contentCell != nil {
                        contentCell!.text = inners
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
        let devices: [(String, String?, String?)]? = BAXCArchivesManager.archives()
        if devices == nil {
            self.archiveInfos = nil
        } else {
            var newAppInfos: [(String, String?, String?, Int, Bool)] = []
            for (path, name, inners) in devices! {
                let size: Int = BAXCFileUtil.size(path)
                var finded: Bool = false
                if self.archiveInfos != nil {
                    for (oldPath, _, _, _, oldState) in self.archiveInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, name, inners, size, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, name, inners, size, false))
                }
            }
            self.archiveInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, _, _, state) in self.archiveInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func selectAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, inners, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (path, name, inners, size, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.archiveInfos == nil {
            return
        }
        var index: Int = 0
        for (path, name, inners, size, _) in self.archiveInfos! {
            self.archiveInfos![index] = (path, name, inners, size, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        return nil
    }
    
    public override func clean() {
    }
}

extension BAXCArchivesSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.archiveInfos == nil || realIndex >= self.archiveInfos!.count {
            return
        }
        let (path, name, inners, size, _) = self.archiveInfos![realIndex]
        self.archiveInfos![realIndex] = (path, name, inners, size, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
}

