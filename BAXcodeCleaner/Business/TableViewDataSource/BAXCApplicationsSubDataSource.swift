//
//  BAXCApplicationsSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCApplicationsSubDataSource: BAXCTableViewSubDataSource {
    var appInfos: [(String, String?, Bool)]? = nil
}

extension BAXCApplicationsSubDataSource {
    public override func numberOfRows() -> Int {
        return self.appInfos == nil ? 1 : self.appInfos!.count + 1
    }
    
    public override func setContent(for cell: NSTableCellView, row: Int, column: Int) {
        if row >= 0 || row < self.numberOfRows() {
            if row == 0 {
                if column == 0 {
                    let sectiontitleCell: BAXCSectionTitleCellView? = cell as? BAXCSectionTitleCellView
                    if sectiontitleCell != nil {
                        sectiontitleCell!.text = "Xcode Applications"
                    }
                }
            } else {
                let realRow: Int = row - 1
                let (path, version, state) = self.appInfos![realRow]
                if column == 0 {
                    let titleCell: BAXCTitleCellView? = cell as? BAXCTitleCellView
                    if titleCell != nil {
                        titleCell!.text = version
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
        let apps: [(String, String?)]? = BAXCXcodeAppManager.xcodes()
        if apps == nil {
            self.appInfos = nil
        } else {
            var newAppInfos: [(String, String?, Bool)] = []
            for (path, version) in apps! {
                var finded: Bool = false
                if self.appInfos != nil {
                    for (oldPath, _, oldState) in self.appInfos! {
                        if oldPath == path {
                            newAppInfos.append((path, version, oldState))
                            finded = true
                            break
                        }
                    }
                }
                if finded == false {
                    newAppInfos.append((path, version, false))
                }
            }
            self.appInfos = newAppInfos
        }
    }
    
    public override func isAllSelected() -> Bool {
        var allSelected: Bool = true
        for (_, _, state) in self.appInfos! {
            if state == false {
                allSelected = false
            }
        }
        return allSelected
    }
    
    public override func selectAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, _) in self.appInfos! {
            self.appInfos![index] = (path, version, true)
            index = index + 1
        }
    }
    
    public override func unselectAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, _) in self.appInfos! {
            self.appInfos![index] = (path, version, false)
            index = index + 1
        }
    }
    
    public override func cleanCheck() -> String? {
        if self.isAllSelected() == true {
            return "Can't delete all Xcode applications, please keep one at least."
        } else {
            return nil
        }
    }
    
    public override func clean() {
    }
}

extension BAXCApplicationsSubDataSource {
    public override func onCheckBoxSelected(cell: BAXCCheckBoxCellView) {
        let realIndex = cell.index - 1
        if realIndex < 0 || self.appInfos == nil || realIndex >= self.appInfos!.count {
            return
        }
        let (path, version, _) = self.appInfos![realIndex]
        self.appInfos![realIndex] = (path, version, cell.selected)
        if self.onSelected != nil {
            self.onSelected!()
        }
    }
}
