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
        result.isEnabled = true
        result.layer!.backgroundColor = NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5).cgColor
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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self._bgView)
        self.addSubview(self._indicator)
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
