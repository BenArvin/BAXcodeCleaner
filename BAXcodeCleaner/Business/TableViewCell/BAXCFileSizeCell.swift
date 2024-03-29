//
//  BAXCFileSizeCell.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/2.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCFileSizeCell: BAXCTableViewCell {
    public static let identifier: String = "BAXCFileSizeCell"
    private var _size: Int = 0
    public var size: Int {
        set {
            _size = newValue
            self._sizeTextField.stringValue = String.init(fromSize: _size)
        }
        get {
            return _size
        }
    }
    
    private lazy var _sizeTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 18)
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._sizeTextField)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.size = 0
        self._sizeTextField.stringValue = ""
    }
    
    public override func layout() {
        super.layout()
        self._sizeTextField.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}
