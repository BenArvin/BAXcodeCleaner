//
//  BAXCContentCell.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCContentCellConstants {
    static let identifier: String = "BAXCContentCell"
}

public class BAXCContentCell: BAXCTableViewCell {
    public var text: String? {
        set {
            self._contentTextField.stringValue = newValue == nil ? "" : newValue!
        }
        get {
            return self._contentTextField.stringValue
        }
    }
    
    private lazy var _contentTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = true
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
        self.addSubview(self._contentTextField)
        
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
        self._contentTextField.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}
