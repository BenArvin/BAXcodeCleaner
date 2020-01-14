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
        result.menu = self._tableViewMenu
        return result
    }()
    
    private lazy var _tableViewMenu: NSMenu = {
        let result: NSMenu = NSMenu.init()
        result.addItem(NSMenuItem.init(title: "Copy", action: #selector(_onCopyMenuItemSelected), keyEquivalent: ""))
        result.addItem(NSMenuItem.init(title: "Show in Finder", action: #selector(_onShowInFinderMenuItemSelected), keyEquivalent: ""))
        return result
    }()
    
    private var _columnsSetted: Bool = false
    
    private lazy var _tableViewColumn0: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("0"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn1: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("1"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn2: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("2"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn3: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("3"))
        result.title = " "
        result.minWidth = 30
        result.maxWidth = 30
        return result
    }()
    
    private lazy var _tableContainerView: NSScrollView = {
        let result: NSScrollView = NSScrollView.init()
        result.documentView = self._tableView
        result.drawsBackground = false
        result.hasVerticalScroller = true
        result.hasHorizontalScroller = true
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
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
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
            
            self._settingTableView()
            
            self._refresh()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self._setElementsFrame()
    }
}

extension BAXCManualCleanVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self._dataSource.height(for: row)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return !self._dataSource.isSectionRow(row)
    }
}

extension BAXCManualCleanVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self._dataSource.numberOfRows()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnID: String = tableColumn!.identifier.rawValue
        var cell: NSTableCellView? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("123"), owner: self) as? NSTableCellView
        if cell == nil {
            cell = self._dataSource.cell(for: row, column: Int(columnID) ?? 0)
        }
        self._dataSource.setContent(for: cell!, row: row, column: Int(columnID) ?? 0)
        return cell
    }
}

extension BAXCManualCleanVC: BAXCTableViewDataSourceProtocol {
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
    
    func onRowCheckBtnSelected(cell: NSTableCellView) {
        let row = self._tableView.row(for: cell)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.onCheckEventForRow(row)
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
    
    func onFoldBtnSelected(cell: NSTableCellView) {
        let row = self._tableView.row(for: cell)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.onFoldEvent(row)
        }
    }
    
    func onTipsBtnSelected(cell: NSTableCellView) {
        let row = self._tableView.row(for: cell)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let (title, content): (String?, String?) = strongSelf._dataSource.tipsForHelp(row)
            DispatchQueue.main.async{
                let alert: NSAlert = NSAlert.init()
                alert.alertStyle = NSAlert.Style.informational
                alert.messageText = title == nil ? "Unknown" : title!
                alert.informativeText = content == nil ? "Unknown" : content!
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
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
        self._sizeTextField.frame = CGRect.init(x: self._backBtn.frame.maxX + 15, y: 3, width: self._topBar.frame.width - self._backBtn.frame.maxX * 2 - 30, height: 18)
        
        if self._columnsSetted == false && self.view.bounds.width > 10 {
            self._columnsSetted = true
            let width: CGFloat = self._tableContainerView.bounds.width
            self._tableViewColumn2.width = 100
            self._tableViewColumn3.width = 30
            self._tableViewColumn0.width = floor(width / 3)
            self._tableViewColumn1.width = floor(width / 3 * 2) - self._tableViewColumn2.width - self._tableViewColumn3.width - 12
        }
    }
    
    private func _settingTableView() {
        self._tableView.addTableColumn(self._tableViewColumn0)
        self._tableView.addTableColumn(self._tableViewColumn1)
        self._tableView.addTableColumn(self._tableViewColumn2)
        self._tableView.addTableColumn(self._tableViewColumn3)
        self._tableView.gridStyleMask = [NSTableView.GridLineStyle.solidHorizontalGridLineMask]
    }
}

// MARK: - selector methods
extension BAXCManualCleanVC {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        if self._selAllCheckBox.state == BAXCTPCheckBox.State.Uncheck {
            self._selAllCheckBox.state = BAXCTPCheckBox.State.Check
            DispatchQueue.global().async{[weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf._dataSource.checkAll()
            }
        } else {
            self._selAllCheckBox.state = BAXCTPCheckBox.State.Uncheck
            DispatchQueue.global().async{[weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf._dataSource.uncheckAll()
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
                DispatchQueue.global().async{[weak strongSelf2] in
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
                            strongSelf5._loadingView.message = "Searching..."
                        }
                        strongSelf4._dataSource.refresh {[weak strongSelf4] in
                            guard let strongSelf5 = strongSelf4 else {
                                return
                            }
                            DispatchQueue.main.async{[weak strongSelf5] in
                                guard let strongSelf6 = strongSelf5 else {
                                    return
                                }
                                strongSelf6._loadingView.hide()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func _onRefreshBtnSelected(_ sender: NSButton?) {
        self._refresh()
    }
    
    @objc private func _onCopyMenuItemSelected() {
        let row = self._tableView.clickedRow
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let content: String? = strongSelf._dataSource.contentForCopy(at: row)
            if content == nil {
                return
            }
            DispatchQueue.main.async{
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([content! as NSString])
            }
        }
    }
    
    @objc private func _onShowInFinderMenuItemSelected() {
        let row = self._tableView.clickedRow
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let path: String? = strongSelf._dataSource.pathForOpen(at: row)
            if path == nil {
                return
            }
            DispatchQueue.main.async{
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            }
        }
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
}
