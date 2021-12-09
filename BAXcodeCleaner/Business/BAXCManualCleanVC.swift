//
//  BAXCManualCleanVC.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/25.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

class BAXCManualCleanVC: BAViewController {
    private lazy var _tableView: BAXCTableView = {
        let result: BAXCTableView = BAXCTableView.init()
        result.enableKeyEvent = false
        result.delegate = self
        result.dataSource = self
        result.headerView = nil
        result.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        return result
    }()
    
    private lazy var _tableViewColumn0: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("0"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableContainerView: NSScrollView = {
        let result: NSScrollView = NSScrollView.init()
        result.documentView = self._tableView
        result.drawsBackground = false
        result.hasVerticalScroller = false
        result.hasHorizontalScroller = false
        result.autohidesScrollers = true
        return result
    }()
    
    private lazy var _topBar: NSView = {
        let result: NSView = NSView.init()
        return result
    }()
    
    private lazy var _backBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(_onBackBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.image = NSImage(named: NSImage.Name("arrow-left-white"))
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        return result
    }()
    
    private lazy var _refreshBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(_onRefreshBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.image = NSImage(named: NSImage.Name("refresh-white"))
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        return result
    }()
    
    private lazy var _selAllCheckBox: BAXCTPCheckBox = {
        let result: BAXCTPCheckBox = BAXCTPCheckBox.init(target: self, action: #selector(_onSelAllCheckBoxSelected(_:)))
        result.state = BAXCTPCheckBox.State.Uncheck
        return result
    }()
    
    private lazy var _sizeTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.center
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 16)
        return result
    }()
    
    private lazy var _cleanBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "Clean", target: self, action: #selector(_onCleanBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.font = NSFont.systemFont(ofSize: 20)
        return result
    }()
    
    private lazy var _loadingView: BAXCProgressIndicator = {
        let result: BAXCProgressIndicator = BAXCProgressIndicator.init()
        result.hide()
        return result
    }()
    
    private lazy var _dataSource: BAXCTableViewDataSource = {
        let result: BAXCTableViewDataSource = BAXCTableViewDataSource()
        result.delegate = self
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if self._tableContainerView.superview != self.view {
            self.view.addSubview(self._topBar)
            self._topBar.addSubview(self._backBtn)
            self._topBar.addSubview(self._refreshBtn)
            self._topBar.addSubview(self._selAllCheckBox)
            self._topBar.addSubview(self._sizeTextField)
            self.view.addSubview(self._tableContainerView)
            self.view.addSubview(self._cleanBtn)
            self.view.addSubview(self._loadingView)
            
            self._tableView.addTableColumn(self._tableViewColumn0)
            
            self._refresh()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self._setElementsFrame()
        self._tableView.reloadData()
    }
}

extension BAXCManualCleanVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self._dataSource.dataSourceForkind(row).totalHeight()
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}

extension BAXCManualCleanVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self._dataSource.numberOfKinds()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnID: String = tableColumn!.identifier.rawValue
        var cell: NSTableCellView? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(columnID), owner: self) as? NSTableCellView
        if cell == nil {
            let cellTmp: BAXCNestedTableCell = BAXCNestedTableCell.init()
            cellTmp.identifier = NSUserInterfaceItemIdentifier.init(BAXCNestedTableCell.identifier)
            cell = cellTmp
        }
        let cellTmp: BAXCNestedTableCell = cell as! BAXCNestedTableCell
        cellTmp.dataSource = self._dataSource.dataSourceForkind(row)
        cellTmp.delegate = cellTmp.dataSource
        return cell
    }
}

extension BAXCManualCleanVC: BAXCTableViewDataSourceProtocol {
    func onTipsBtnSelected(cell: NSTableCellView) {
        let row = self._tableView.row(for: cell)
        let subDS = self._dataSource.dataSourceForkind(row)
        let title = subDS.title()
        let content = subDS.description()
        DispatchQueue.main.async{
            let alert: NSAlert = NSAlert.init()
            alert.alertStyle = NSAlert.Style.informational
            alert.messageText = title
            alert.informativeText = content
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func onSectionCheckBtnSelected(cell: NSTableCellView) {
        let row = self._tableView.row(for: cell)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.onCheckEventForSection(row)
        }
    }
    
    func onDatasChanged() {
        var newState = BAXCTPCheckBox.State.Part
        if self._dataSource.isAllChecked() == true {
            newState = BAXCTPCheckBox.State.Check
        } else if self._dataSource.isNoneChecked() == true {
            newState = BAXCTPCheckBox.State.Uncheck
        }
        let (totalSize, selectedSize) = self._dataSource.size()
        DispatchQueue.main.async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._tableView.reloadData()
            strongSelf._selAllCheckBox.state = newState
            strongSelf._updateSizeTextField(total: totalSize, selected: selectedSize)
        }
    }

    func onRowCheckBtnSelected(cell: NSTableCellView, innerRow: Int) {
        let row = self._tableView.row(for: cell)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.onCheckEventForRow(row: row, innerRow: innerRow)
        }
    }

    func onFoldBtnSelected(cell: NSTableCellView) {
    }
    
    func onCopyMenuItemSelected(cell: NSTableCellView, innerRow: Int) {
        let row = self._tableView.row(for: cell)
        let subDS = self._dataSource.dataSourceForkind(row)
        let content: String? = subDS.contentForCopy(at: innerRow)
        if content == nil {
            return
        }
        DispatchQueue.main.async{
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([content! as NSString])
        }
    }
    
    func onShowInFinderMenuItemSelected(cell: NSTableCellView, innerRow: Int) {
        let row = self._tableView.row(for: cell)
        let subDS = self._dataSource.dataSourceForkind(row)
        let path: String? = subDS.pathForOpen(at: innerRow)
        if path == nil {
            return
        }
        DispatchQueue.main.async{
            NSWorkspace.shared.selectFile(path!, inFileViewerRootedAtPath: "")
        }
    }
}

// MARK: - UI setting
extension BAXCManualCleanVC {
    private func _setElementsFrame() {
        self._loadingView.frame = self.view.bounds
        
        let topMargin: CGFloat = 10
        let bottomMargin: CGFloat = 10
        let leftMargin: CGFloat = 15
        let rightMargin: CGFloat = 15
        
        let cleanBtnWidth: CGFloat = 100
        let cleanBtnHeight: CGFloat = floor(cleanBtnWidth * 0.618)
        
        self._cleanBtn.frame = CGRect.init(x: floor((self.view.bounds.width - cleanBtnWidth) / 2), y: topMargin, width: cleanBtnWidth, height: cleanBtnHeight)
        
        self._topBar.frame = CGRect.init(x: leftMargin, y: self.view.bounds.height - bottomMargin - 30, width: self.view.bounds.width - leftMargin - rightMargin, height: 30)
        
        self._tableContainerView.frame = CGRect.init(x: leftMargin, y: self._cleanBtn.frame.maxY + 10, width: self.view.bounds.width - leftMargin - rightMargin, height: self._topBar.frame.minY - self._cleanBtn.frame.maxY - 10 - 5)
        
        self._backBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        self._refreshBtn.frame = CGRect.init(x: self._backBtn.frame.maxX + 5, y: 0, width: 30, height: 30)
        self._selAllCheckBox.frame = CGRect.init(x: self._topBar.bounds.width - 16 - 10, y: 4, width: 16, height: 16)
        self._sizeTextField.frame = CGRect.init(x: self._refreshBtn.frame.maxX + 15, y: 3, width: self._selAllCheckBox.frame.minX - self._refreshBtn.frame.maxX - 30, height: 18)
        self._tableView.sizeLastColumnToFit()
    }
}

// MARK: - selector methods
extension BAXCManualCleanVC {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            if strongSelf._dataSource.isAllChecked() {
                strongSelf._dataSource.uncheckAll()
            } else {
                strongSelf._dataSource.checkAll()
            }
        }
    }
    
    @objc private func _onBackBtnSelected(_ sender: NSButton?) {
        self.navigationController!.popViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func _onCleanBtnSelected(_ sender: NSButton?) {
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            if strongSelf._dataSource.isNoneChecked() == true {
                return
            }
            let (_, selectedSize) = strongSelf._dataSource.size()
            DispatchQueue.main.async{[weak strongSelf] in
                guard let strongSelf2 = strongSelf else {
                    return
                }
                let alert: NSAlert = NSAlert.init()
                alert.alertStyle = NSAlert.Style.critical
                alert.messageText = "Are you sure to clean those files?"
                alert.informativeText = "Take it easy, you can find and retrive those files from Trash🗑 if you regret it. The world won't be destroyed."
                alert.addButton(withTitle: "YES")
                alert.addButton(withTitle: "NO")
                let res: NSApplication.ModalResponse = alert.runModal()
                if res != NSApplication.ModalResponse.alertFirstButtonReturn {
                    return
                }
                strongSelf2._loadingView.message = "Cleaning..."
                strongSelf2._loadingView.show()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) { [weak strongSelf2] in
                    guard let strongSelf3 = strongSelf2 else {
                        return
                    }
                    strongSelf3._dataSource.clean { [weak strongSelf3] (successed, errorMsg) in
                        guard let strongSelf4 = strongSelf3 else {
                            return
                        }
                        if successed == false {
                            DispatchQueue.main.async{ [weak strongSelf4] in
                                guard let strongSelf5 = strongSelf4 else {
                                    return
                                }
                                strongSelf5._loadingView.hide()
                                let alert: NSAlert = NSAlert.init()
                                alert.alertStyle = NSAlert.Style.critical
                                alert.messageText = "Clean failed!"
                                alert.informativeText = errorMsg == nil ? "unknown" : errorMsg!
                                alert.addButton(withTitle: "OK")
                                alert.runModal()
                            }
                            return
                        }
                        DispatchQueue.main.async{[weak strongSelf4] in
                            guard let strongSelf5 = strongSelf4 else {
                                return
                            }
                            strongSelf5._showCleanSuccessAlert(selectedSize)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func _onRefreshBtnSelected(_ sender: NSButton?) {
        self._refresh()
    }
}

// MARK - menuItem methods
extension BAXCManualCleanVC {
    @objc public override func onMenuCleanItemSelected(_ sender: NSButton?) {
        self._onCleanBtnSelected(sender)
    }
    
    @objc public override func onMenuRefreshItemSelected(_ sender: NSButton?) {
        self._onRefreshBtnSelected(sender)
    }
}

// MARK - private methods
extension BAXCManualCleanVC {
    private func _refresh() {
        self._loadingView.show()
        self._loadingView.message = "Searching..."
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.refresh {[weak strongSelf] in
                guard let strongSelf2 = strongSelf else {
                    return
                }
                DispatchQueue.main.async{[weak strongSelf2] in
                    guard let strongSelf3 = strongSelf2 else {
                        return
                    }
                    strongSelf3._loadingView.hide()
                }
            }
        }
    }
    
    private func _updateSizeTextField(total: Int, selected: Int) {
        if total == 0 && selected == 0 {
            self._sizeTextField.stringValue = ""
        } else if selected == 0 {
            self._sizeTextField.stringValue = String.init(format: "total: %@", String.init(fromSize: total))
        } else {
            self._sizeTextField.stringValue = String.init(format: "total: %@ / selected: %@", String.init(fromSize: total), String.init(fromSize: selected))
        }
    }
    
    private func _showCleanSuccessAlert(_ cleanedSize: Int) {
        DispatchQueue.main.async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let alert: NSAlert = NSAlert.init()
            alert.alertStyle = NSAlert.Style.critical
            alert.messageText = "Clean finished!"
            alert.addButton(withTitle: "👍")
            alert.informativeText = String.init(format: "%@ has been cleaned, bravo! 🎉", String.init(fromSize: cleanedSize))
            alert.addButton(withTitle: "Research")
            let res: NSApplication.ModalResponse = alert.runModal()
            if res == NSApplication.ModalResponse.alertFirstButtonReturn {
                strongSelf.navigationController?.popViewControllerAnimated(true, completion: nil)
            } else if res == NSApplication.ModalResponse.alertSecondButtonReturn {
                DispatchQueue.main.async{[weak strongSelf] in
                    guard let strongSelf2 = strongSelf else {
                        return
                    }
                    strongSelf2._refresh()
                }
            }
        }
    }
}
