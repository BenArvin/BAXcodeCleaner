//
//  BABugReporterVC.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/15.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public struct BABugReporterTableCellConstants {
    static let identifier: String = "BABugReporterTableCell"
}

public class BABugReporterTableCell: NSTableCellView {
    public var text: String? {
        set {
            self._titleTextField.stringValue = newValue == nil ? "" : newValue!
        }
        get {
            return self._titleTextField.stringValue
        }
    }
    
    private lazy var _titleTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 14)
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._titleTextField)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.text = nil
    }
    
    public override func layout() {
        super.layout()
        self._titleTextField.frame = CGRect.init(x: 5, y: 0, width: self.bounds.width - 5, height: self.bounds.height)
    }
}

private class BABugReporterTableView: NSTableView {
    override public func keyDown(with event: NSEvent) {}
    override public func keyUp(with event: NSEvent) {}
}

public class BABugReporterVC: NSViewController, NSTextViewDelegate {
    private var _datas: [(String, String, Date)]? = nil
    
    private lazy var _introTextView: NSTextView = {
        let result: NSTextView = NSTextView.init()
        result.isEditable = false
        result.isSelectable = true
        result.backgroundColor = NSColor.clear
        result.alignment = NSTextAlignment.left
        let attrStr: NSMutableAttributedString = NSMutableAttributedString.init()
        attrStr.append(NSAttributedString.init(string: "Please creat an issue of this repository on github, and paste the content of crash log would be greatly helpful.", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14)]))
        result.textStorage?.setAttributedString(attrStr)
        return result
    }()
    
    private lazy var _tableTipsTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 14)
        result.stringValue = "Here's all crash logs:"
        return result
    }()
    
    private lazy var _tableView: BABugReporterTableView = {
        let result: BABugReporterTableView = BABugReporterTableView.init()
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
        result.title = "  Crash time"
        result.minWidth = 50
        return result
    }()
    
    private lazy var _tableViewColumn1: NSTableColumn = {
        let result: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("1"))
        result.title = "  Log file path"
        result.minWidth = 50
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
    
    private lazy var _indicator: NSProgressIndicator = {
        let result: NSProgressIndicator = NSProgressIndicator()
        result.style = NSProgressIndicator.Style.spinning
        return result
    }()
    
    deinit {
        self._indicator.stopAnimation(self)
    }
    
    override public func loadView() {
      self.view = NSView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        if self._tableContainerView.superview != self.view {
            self.view.addSubview(self._introTextView)
            self.view.addSubview(self._tableTipsTextField)
            self.view.addSubview(self._tableContainerView)
            self.view.addSubview(self._indicator)
            
            self._settingTableView()
            
            self._refresh()
        }
    }
    
    override public func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        self._setElementsFrame()
    }
}

extension BABugReporterVC: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 18
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

extension BABugReporterVC: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        if self._datas == nil {
            return 0
        }
        return self._datas!.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnID: String = tableColumn!.identifier.rawValue
        var cell: NSTableCellView? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(columnID), owner: self) as? NSTableCellView
        if cell == nil {
            cell = BABugReporterTableCell.init()
            (cell as! BABugReporterTableCell).identifier = NSUserInterfaceItemIdentifier.init(BABugReporterTableCellConstants.identifier)
        }
        let cellTmp: BABugReporterTableCell? = cell as? BABugReporterTableCell ?? nil
        if cellTmp != nil {
            let dataItem = self._dataAtIndex(row)
            if dataItem != nil {
                let (path, _, date) = dataItem!
                if columnID == "0" {
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat="yyyy-MM-dd HH:mm:ss"
                    cellTmp!.text = dateformatter.string(from: date)
                } else if columnID == "1" {
                    cellTmp!.text = path
                }
            }
        }
        return cell
    }
}

extension BABugReporterVC {
    private func _setElementsFrame() {
        let bounds = self.view.bounds
        self._introTextView.frame = CGRect.init(x: 5, y: bounds.height - 10 - 52, width: bounds.width - 10, height: 52)
        self._tableTipsTextField.frame = CGRect.init(x: 5, y: self._introTextView.frame.minY - 3 - 18, width: bounds.width - 10, height: 18)
        self._tableContainerView.frame = CGRect.init(x: 0, y: 0, width: bounds.width, height: self._tableTipsTextField.frame.minY - 5)
        self._indicator.sizeToFit()
        let size: CGFloat = self._indicator.frame.width
        self._indicator.frame = CGRect.init(x: floor((bounds.width - size) / 2),
                                            y: floor((bounds.height - size) / 2),
                                            width: size,
                                            height: size)
        if self._columnsSetted == false && bounds.width > 10 {
            self._columnsSetted = true
            self._tableViewColumn0.width = floor(self._tableContainerView.bounds.width / 3)
            self._tableViewColumn1.width = 1000
        }
    }
    
    private func _settingTableView() {
        self._tableView.addTableColumn(self._tableViewColumn0)
        self._tableView.addTableColumn(self._tableViewColumn1)
        self._tableView.gridStyleMask = [NSTableView.GridLineStyle.solidHorizontalGridLineMask]
    }
}

extension BABugReporterVC {
    @objc private func _onCopyMenuItemSelected() {
        let row = self._tableView.clickedRow
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let path: String? = strongSelf._pathOfDataAtIndex(row)
            if path == nil {
                return
            }
            DispatchQueue.main.async{
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([path! as NSString])
            }
        }
    }
    
    @objc private func _onShowInFinderMenuItemSelected() {
        let row = self._tableView.clickedRow
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            let path: String? = strongSelf._pathOfDataAtIndex(row)
            if path == nil {
                return
            }
            DispatchQueue.main.async{
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            }
        }
    }
}

extension BABugReporterVC {
    private func _refresh() {
        self._tableContainerView.isHidden = true
        self._indicator.isHidden = false
        self._indicator.startAnimation(self)
        DispatchQueue.global().async{[weak self] in
            guard let strongSelf = self else {
                return
            }
            var newDatas = BACrashLogAnalyzer.searchCrashLogs()
            if newDatas != nil {
                newDatas!.sort { (arg0, arg1) -> Bool in
                    let (_, _, date0) = arg0
                    let (_, _, date1) = arg1
                    let compareResult: ComparisonResult = date0.compare(date1)
                    if compareResult == ComparisonResult.orderedAscending {
                        return false
                    } else if compareResult == ComparisonResult.orderedDescending {
                        return true
                    } else {
                        return true
                    }
                }
            }
            strongSelf._datas = newDatas
            DispatchQueue.main.async{[weak strongSelf] in
                guard let strongSelf2 = strongSelf else {
                    return
                }
                strongSelf2._tableContainerView.isHidden = false
                strongSelf2._indicator.isHidden = true
                strongSelf2._indicator.stopAnimation(self)
                strongSelf2._tableView.reloadData()
            }
        }
    }
    
    private func _dataAtIndex(_ index: Int) -> (String, String, Date)? {
        if self._datas == nil {
            return nil
        }
        if index < 0 || index >= self._datas!.count {
            return nil
        }
        return self._datas![index]
    }
    
    private func _pathOfDataAtIndex(_ index: Int) -> String? {
        let dataItem = self._dataAtIndex(index)
        if dataItem == nil {
            return nil
        }
        let (path, _, _) = dataItem!
        return path
    }
}
