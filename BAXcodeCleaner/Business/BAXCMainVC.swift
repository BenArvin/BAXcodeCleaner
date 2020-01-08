//
//  BAXCMainVC.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/25.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

private struct BAXCMainVCConstants {
    static let titleCellID: String = "titleCell"
    static let contentCellID: String = "contentCell"
    static let checkBoxCellID: String = "checkBoxCell"
    static let sectionCellID: String = "sectionCell"
    static let sectionBlankCellID: String = "sectionBlankCell"
}

class BAXCMainVC: NSViewController {
    private lazy var _tableView: NSTableView = {
        let result: NSTableView = NSTableView.init()
        result.delegate = self
        result.dataSource = self
        return result
    }()
    
    private var _columnsSetted: Bool = false
    
    private lazy var _tableViewColumn1: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("0"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn2: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("1"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn3: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("2"))
        result.title = " "
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn4: NSTableColumn = {
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
    
    private lazy var _refreshBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(onRefreshBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.image = NSImage(named: NSImage.Name("refresh-white"))
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        return result
    }()
    
    private lazy var _selAllCheckBox: NSButton = {
        let result: NSButton = NSButton.init(checkboxWithTitle: "", target: self, action: #selector(_onSelAllCheckBoxSelected(_:)))
        result.state = NSControl.StateValue.off
        return result
    }()
    
    private lazy var _cleanBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "Clean", target: self, action: #selector(onCleanBtnSelected(_:)))
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
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if self._tableContainerView.superview != self.view {
            self.view.addSubview(self._refreshBtn)
            self.view.addSubview(self._selAllCheckBox)
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

extension BAXCMainVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self._dataSource.height(for: row)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}

extension BAXCMainVC: NSTableViewDataSource {
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

extension BAXCMainVC: BAXCTableViewDataSourceProtocol {
    func onDatasChanged() {
        DispatchQueue.main.async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._tableView.reloadData()
        }
    }
    
    func onSelectStateChanged(isAllSelected: Bool) {
        DispatchQueue.main.async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._selAllCheckBox.state = isAllSelected == true ? NSControl.StateValue.on : NSControl.StateValue.off
        }
    }
    
    func onFoldStateChanged() {
        DispatchQueue.main.async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._tableView.reloadData()
        }
    }
}

// MARK: - UI setting
extension BAXCMainVC {
    private func _setElementsFrame() {
        self._loadingView.frame = self.view.bounds
        
        let topMargin: CGFloat = 10
        let bottomMargin: CGFloat = 10
        let leftMargin: CGFloat = 15
        let rightMargin: CGFloat = 15
        
        let cleanBtnWidth: CGFloat = 100
        let cleanBtnHeight: CGFloat = floor(cleanBtnWidth * 0.618)
        
        self._cleanBtn.frame = CGRect.init(x: floor((self.view.bounds.width - cleanBtnWidth) / 2), y: topMargin, width: cleanBtnWidth, height: cleanBtnHeight)
        
        self._refreshBtn.frame = CGRect.init(x: leftMargin, y: self.view.bounds.height - bottomMargin - 30, width: 30, height: 30)
        
        self._tableContainerView.frame = CGRect.init(x: leftMargin, y: self._cleanBtn.frame.maxY + 10, width: self.view.bounds.width - leftMargin - rightMargin, height: self._refreshBtn.frame.minY - self._cleanBtn.frame.maxY - 10 - 5)
        
        self._selAllCheckBox.sizeToFit()
        self._selAllCheckBox.frame = CGRect.init(x: self.view.bounds.width - rightMargin - self._selAllCheckBox.bounds.width + 2, y: self._tableContainerView.frame.maxY + 5, width: self._selAllCheckBox.bounds.width, height: self._selAllCheckBox.bounds.height)
        
        if self._columnsSetted == false && self.view.bounds.width > 10 {
            self._columnsSetted = true
            let width: CGFloat = self.view.bounds.width - leftMargin - rightMargin
            self._tableViewColumn3.width = 100
            self._tableViewColumn1.width = floor(width / 3)
            self._tableViewColumn2.width = floor(width / 3 * 2) - self._tableViewColumn3.width - self._tableViewColumn4.width
        }
    }
    
    private func _settingTableView() {
        self._tableView.addTableColumn(self._tableViewColumn1)
        self._tableView.addTableColumn(self._tableViewColumn2)
        self._tableView.addTableColumn(self._tableViewColumn3)
        self._tableView.addTableColumn(self._tableViewColumn4)
        self._tableView.gridStyleMask = [NSTableView.GridLineStyle.solidHorizontalGridLineMask]
    }
}

// MARK: - selector methods
extension BAXCMainVC {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        if self._selAllCheckBox.state == NSControl.StateValue.on {
            self._dataSource.selectAll()
        } else {
            self._dataSource.unselectAll()
        }
    }
    
    @objc public func onCleanBtnSelected(_ sender: NSButton?) {
        self._loadingView.show()
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._dataSource.clean {[weak strongSelf] in
                guard let strongSelf2 = strongSelf else {
                    return
                }
                strongSelf2._dataSource.refresh {[weak strongSelf2] in
                    guard let strongSelf3 = strongSelf2 else {
                        return
                    }
                    DispatchQueue.main.async{[weak strongSelf3] in
                        guard let strongSelf4 = strongSelf3 else {
                            return
                        }
                        strongSelf4._loadingView.hide()
                    }
                }
            }
        }
    }
    
    @objc public func onRefreshBtnSelected(_ sender: NSButton?) {
        self._refresh()
    }
}

// MARK - private methods
extension BAXCMainVC {
    private func _refresh() {
        self._loadingView.show()
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
}
