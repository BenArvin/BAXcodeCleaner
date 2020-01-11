//
//  BAXCSectionTitleCell.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCSectionTitleCellConstants {
    static let identifier: String = "BAXCSectionTitleCell"
}

public protocol BAXCSectionTitleCellDelegate: class {
    func onSectionTitleCellFoldBtnSelected(cell: BAXCSectionTitleCell)
    func onSectionTitleCellTipsBtnSelected(cell: BAXCSectionTitleCell)
}

public class BAXCSectionTitleCell: BAXCTableViewCell {
    
    public var delegate: BAXCSectionTitleCellDelegate?
    
    public var isFolded: Bool = false
    
    public var text: String? {
        set {
            self._titleTextField.stringValue = newValue == nil ? "" : newValue!
        }
        get {
            return self._titleTextField.stringValue
        }
    }
    
    private lazy var _foldBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(onFoldBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
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
    
    private lazy var _tipsBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(onTipsBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.helpButton
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._foldBtn)
        self.addSubview(self._titleTextField)
        self.addSubview(self._tipsBtn)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.text = nil
        self.isFolded = false
        self._foldBtn.image = nil
    }
    
    public override func layout() {
        super.layout()
        self._foldBtn.frame = CGRect.init(x: 5, y: 7, width: 25, height: 25)
        self._foldBtn.image = self.isFolded == true ? NSImage(named: NSImage.Name("triangle-right-white")) : NSImage(named: NSImage.Name("triangle-down-white"))
        
        let tipsBtnSize: CGFloat = 25
        
        let maxWidth: CGFloat = self.bounds.width - self._foldBtn.frame.maxX - tipsBtnSize - 5 - 10
        let idealWidth: CGFloat = ceil(self._titleTextField.sizeThatFits(NSSize.init(width: 0, height: 0)).width)
        self._titleTextField.frame = CGRect.init(x: self._foldBtn.frame.maxX + 5, y: 5, width: idealWidth > maxWidth ? maxWidth : idealWidth, height: 30)
        
        self._tipsBtn.frame = CGRect.init(x: self._titleTextField.frame.maxX + 5, y: 5, width: tipsBtnSize, height: tipsBtnSize)
    }
}

extension BAXCSectionTitleCell {
    @objc public func onFoldBtnSelected(_ sender: NSButton?) {
        if self.delegate != nil {
            self.delegate!.onSectionTitleCellFoldBtnSelected(cell: self)
        }
    }
    
    @objc public func onTipsBtnSelected(_ sender: NSButton?) {
        if self.delegate != nil {
            self.delegate!.onSectionTitleCellTipsBtnSelected(cell: self)
        }
    }
}
