//
//  BAXCSectionTitleCellView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCSectionTitleCellViewConstants {
    static let identifier: String = "BAXCSectionTitleCellView"
}

public class BAXCSectionTitleCellView: BAXCTableViewCell {
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
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.bold)
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
        self._titleTextField.frame = CGRect.init(x: 0, y: 5, width: self.bounds.width, height: 30)
    }
}
