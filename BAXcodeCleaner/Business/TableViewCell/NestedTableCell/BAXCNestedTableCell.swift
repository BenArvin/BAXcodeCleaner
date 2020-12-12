//
//  BAXCNestedTableCell.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

fileprivate class BAXCNestedTableHeaderCell: NSTableHeaderCell {
    override var font: NSFont? {
        get {
            return super.font
        }
        set {
            super.font = NSFont.systemFont(ofSize: 16)
        }
    }
    
    override var textColor: NSColor? {
        get {
            return super.textColor
        }
        set {
            super.textColor = NSColor.lightGray
        }
    }
}

public class BAXCNestedTableCell: BAXCTableViewCell {
    public static let identifier: String = "BAXCNestedTableCell"
    
    public var dataSource: BAXCTableViewSubDataSource_new? = nil
    public var delegate: BAXCNestedTableCellDelegate?
    
    private lazy var _tableView: BAXCTableView = {
        let result: BAXCTableView = BAXCTableView.init()
        result.enableKeyEvent = false
        result.backgroundColor = NSColor.black
        result.delegate = self
        result.dataSource = self
        result.menu = self._tableViewMenu
//        result.headerView = nil
        result.gridStyleMask = [NSTableView.GridLineStyle.solidHorizontalGridLineMask, NSTableView.GridLineStyle.solidVerticalGridLineMask]
        result.intercellSpacing = NSSize.init(width: 0, height: 1)
        if #available(OSX 11.0, *) {
            result.style = .fullWidth
        }
        return result
    }()
    
    private lazy var _tableViewMenu: NSMenu = {
        let result: NSMenu = NSMenu.init()
        result.addItem(NSMenuItem.init(title: "Copy", action: #selector(_onCopyMenuItemSelected), keyEquivalent: ""))
        result.addItem(NSMenuItem.init(title: "Show in Finder", action: #selector(_onShowInFinderMenuItemSelected), keyEquivalent: ""))
        return result
    }()
    
    private var _columnsSetted: Bool = false
    private var _columns: [NSTableColumn] = []
    
    private lazy var _tableContainerView: BAScrollView = {
        let result: BAScrollView = BAScrollView.init()
        result.documentView = self._tableView
        result.hasVerticalScroller = false
        result.hasHorizontalScroller = true
        result.autohidesScrollers = false
        result.enableXScroll = true
        result.enableYScroll = false
        return result
    }()
    
    private lazy var _topBar: NSView = {
        let result: NSView = NSView.init()
        return result
    }()
    
    private lazy var _titleTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.bold)
        return result
    }()
    
    private lazy var _sizeTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byClipping
        result.font = NSFont.systemFont(ofSize: 16)
        return result
    }()
    
    private lazy var _selAllCheckBox: BAXCTPCheckBox = {
        let result: BAXCTPCheckBox = BAXCTPCheckBox.init(target: self, action: #selector(_onSelAllCheckBoxSelected(_:)))
        result.state = BAXCTPCheckBox.State.Uncheck
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._topBar)
        self._topBar.addSubview(self._titleTextField)
        self._topBar.addSubview(self._sizeTextField)
        self._topBar.addSubview(self._selAllCheckBox)
        self.addSubview(self._tableContainerView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.dataSource = nil
        for item in self._columns {
            self._tableView.removeTableColumn(item)
        }
        self._columns.removeAll()
    }
    
    public override func layout() {
        super.layout()
        
        // set value
        self._titleTextField.stringValue = self.dataSource!.title()
        
        var newState = BAXCTPCheckBox.State.Part
        if self.dataSource!.isAllChecked() == true {
            newState = BAXCTPCheckBox.State.Check
        } else if self.dataSource!.isNoneChecked() == true {
            newState = BAXCTPCheckBox.State.Uncheck
        }
        self._selAllCheckBox.state = newState
        
        let (totalSize, selectedSize) = self.dataSource!.size()
        self._updateSizeTextField(total: totalSize, selected: selectedSize)
        
        // set frame
        let titleStrSize: CGSize = self._titleTextField.attributedStringValue.mc_sizeThatFits(maxWidth: CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat.greatestFiniteMagnitude)
        let sizeStrSize: CGSize = self._sizeTextField.attributedStringValue.mc_sizeThatFits(maxWidth: CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat.greatestFiniteMagnitude)
        let topBarHeight: CGFloat = 70
        self._tableContainerView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - topBarHeight)
        self._topBar.frame = CGRect.init(x: 0, y: self._tableContainerView.frame.maxY, width: self.bounds.width, height: topBarHeight)
        self._titleTextField.frame = CGRect.init(x: 0, y: 5, width: titleStrSize.width, height: 28)
        self._selAllCheckBox.frame = CGRect.init(x: self.bounds.width - 16, y: 7, width: 16, height: 16)
        self._sizeTextField.frame = CGRect.init(x: self._titleTextField.frame.maxX, y: 9, width: ceil(sizeStrSize.width) + 2, height: 16)
        
        // set tableview
        for column in 0..<self.dataSource!.numberOfColumns() {
            let item: NSTableColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init(String.init(format: "%d", column)))
            item.minWidth = self.dataSource!.minWidthFor(column: column)
            item.maxWidth = self.dataSource!.maxWidthFor(column: column)
            if self.dataSource!.columnEverSetted == false {
                let width = self.dataSource!.defaultWidthFor(column: column, totalWidth: self.bounds.width)
                item.width = width
                self.dataSource!.update(width: width, for: column)
            } else {
                item.width = self.dataSource!.widthFor(column: column)
            }
            self._columns.append(item)
            item.headerCell = BAXCNestedTableHeaderCell.init()
            item.headerCell.title = self.dataSource!.titleFor(column: column)
            self._tableView.addTableColumn(item)
        }
        self.dataSource!.columnEverSetted = true
        self._tableView.reloadData()
    }
}

extension BAXCNestedTableCell {
    public class func minHeight() -> CGFloat {
        return 70 + 45
    }
}

// MARK: - selector methods
extension BAXCNestedTableCell {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
    }
    
    @objc private func _onCopyMenuItemSelected() {
//        let row = self._tableView.clickedRow
//        DispatchQueue.global().async{[weak self] in
//            guard let strongSelf = self else {
//                return
//            }
//            let content: String? = strongSelf._dataSource.contentForCopy(at: row)
//            if content == nil {
//                return
//            }
//            DispatchQueue.main.async{
//                NSPasteboard.general.clearContents()
//                NSPasteboard.general.writeObjects([content! as NSString])
//            }
//        }
    }
    
    @objc private func _onShowInFinderMenuItemSelected() {
//        let row = self._tableView.clickedRow
//        DispatchQueue.global().async{[weak self] in
//            guard let strongSelf = self else {
//                return
//            }
//            let path: String? = strongSelf._dataSource.pathForOpen(at: row)
//            if path == nil {
//                return
//            }
//            DispatchQueue.main.async{
//                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
//            }
//        }
    }
}

extension BAXCNestedTableCell: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if self.dataSource == nil {
            return 0
        } else {
            return self.dataSource!.height(for: row)
        }
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

extension BAXCNestedTableCell: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        if self.dataSource == nil {
            return 0
        } else {
            return self.dataSource!.numberOfRows()
        }
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnID: String = tableColumn!.identifier.rawValue
        let column: Int = Int(columnID) ?? 0
        var cell: NSTableCellView? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(columnID), owner: self) as? NSTableCellView
        if cell == nil {
            cell = self.dataSource!.cell(for: row, column: column, delegate: self)
        }
        self.dataSource!.setContent(for: cell!, row: row, column: column)
        return cell
    }
}

extension BAXCNestedTableCell: BAXCCheckBoxCellDelegate {
    public func onCheckBoxSelected(cell: BAXCCheckBoxCell) {
        let row = self._tableView.row(for: cell)
        if self.delegate != nil {
            self.delegate!.onCheckBoxSelected(cell: self, innerRow: row)
        }
    }
}

extension BAXCNestedTableCell {
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
