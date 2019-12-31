//
//  BAXCApplicationsSubDataSource.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCApplicationsSubDataSource {
    var appInfos: [(String, String?, Bool)]? = nil
}

extension BAXCApplicationsSubDataSource: BAXCTableViewSubDataSourceProtocol {
    public func numberOfRows() -> Int {
        return self.appInfos == nil ? 1 : self.appInfos!.count + 1
    }
    
    public func height(for row: Int) -> CGFloat {
        if row == 0 {
            return 30
        } else {
            return 20
        }
    }
    
    public func cell(for row: Int, column: Int) -> NSTableCellView? {
        if row == 0 {
            if column == 0 {
                let result: BAXCSectionTitleCellView = BAXCSectionTitleCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionTitleCellViewConstants.identifier)
                return result
            } else {
                let result: BAXCSectionBlankCellView = BAXCSectionBlankCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCSectionBlankCellViewConstants.identifier)
                return result
            }
        } else {
            if column == 0 {
                let result: BAXCTitleCellView = BAXCTitleCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCTitleCellViewConstants.identifier)
                return result
            } else if column == 1 {
                let result: BAXCContentCellView = BAXCContentCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCContentCellViewConstants.identifier)
                return result
            } else if column == 2 {
                let result: BAXCCheckBoxCellView = BAXCCheckBoxCellView.init()
                result.identifier = NSUserInterfaceItemIdentifier.init(BAXCCheckBoxCellViewConstants.identifier)
                return result
            }
        }
        return nil
    }
    
    public func setContent(for cell: NSTableCellView, row: Int, column: Int) {
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
    
    public func refresh() {
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
    
    public func selectAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, _) in self.appInfos! {
            self.appInfos![index] = (path, version, true)
            index = index + 1
        }
    }
    
    public func unselectAll() {
        if self.appInfos == nil {
            return
        }
        var index: Int = 0
        for (path, version, _) in self.appInfos! {
            self.appInfos![index] = (path, version, false)
            index = index + 1
        }
    }
    
    public func clean() {
    }
}
