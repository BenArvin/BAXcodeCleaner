//
//  BAXCProgressIndicator.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCProgressIndicator: NSView {
    
    public var bgColor: CGColor? {
        set {
            self._bgView.layer!.backgroundColor = newValue
        }
        get {
            return self._bgView.layer!.backgroundColor
        }
    }
    
    private lazy var _bgView: BAXCBlockView = {
        let result: BAXCBlockView = BAXCBlockView()
        result.wantsLayer = true
        result.isEnabled = false
        result.layer!.backgroundColor = NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        return result
    }()
    
    private lazy var _indicator: NSProgressIndicator = {
        let result: NSProgressIndicator = NSProgressIndicator()
        result.style = NSProgressIndicator.Style.spinning
        return result
    }()
    
    private var _message: String? = nil
    public var message: String? {
        set {
            self._message = newValue
            self._msgTextField.stringValue = newValue == nil ? "" : newValue!
        }
        get {
            return self._message
        }
    }
    
    private lazy var _msgTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.center
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 14)
        return result
    }()
    
    deinit {
        self._indicator.stopAnimation(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self._bgView)
        self.addSubview(self._indicator)
        self.addSubview(self._msgTextField)
    }
    
    public override func layout() {
        super.layout()
        self._bgView.frame = self.bounds
        self._indicator.sizeToFit()
        let size: CGFloat = self._indicator.frame.width
        self._indicator.frame = CGRect.init(x: floor((self.frame.width - size) / 2),
                                            y: floor((self.frame.height - size) / 2),
                                            width: size,
                                            height: size)
        self._msgTextField.frame = CGRect.init(x: 0, y: self._indicator.frame.minY - 18 - 5, width: self.bounds.width, height: 18)
    }
}

extension BAXCProgressIndicator {
    public func show() {
        self._indicator.startAnimation(self)
        self.isHidden = false
    }
    
    public func hide() {
        self.isHidden = true
        self._indicator.stopAnimation(self)
    }
}
