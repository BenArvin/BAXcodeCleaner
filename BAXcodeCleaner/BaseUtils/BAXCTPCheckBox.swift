//
//  BAXCTPCheckBox.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/9.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCTPCheckBox: NSView {
    
    public enum State: Int {
        case Check = 0
        case Part = 1
        case Uncheck = 2
    }
    
    private lazy var _btn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(_onBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        (result.cell as! NSButtonCell).isBordered = false
        result.wantsLayer = true
        result.layer!.cornerRadius = 4
        return result
    }()
    
    private var _state: State = State.Uncheck
    public var state: State {
        set {
            _state = newValue
            self.needsLayout = true
        }
        get {
            return _state
        }
    }
    
    private weak var _target: NSObject? = nil
    private var _action: Selector? = nil
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self._btn)
    }
    
    public convenience init(target: NSObject?, action: Selector?) {
        self.init()
        self._target = target
        self._action = action
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layout() {
        super.layout()
        self._btn.frame = self.bounds
        switch self.state {
        case State.Check:
            self._btn.image = NSImage(named: NSImage.Name("check-white"))
            (self._btn.cell as! NSButtonCell).backgroundColor = NSColor.init(calibratedRed: 0, green: 0.3, blue: 0.9, alpha: 1)
            break
        case State.Part:
            self._btn.image = NSImage(named: NSImage.Name("minus-white"))
            (self._btn.cell as! NSButtonCell).backgroundColor = NSColor.init(calibratedRed: 0, green: 0.2, blue: 0.9, alpha: 1)
            break
        default:
            self._btn.image = nil
            (self._btn.cell as! NSButtonCell).backgroundColor = NSColor.init(calibratedRed: 0.373, green: 0.376, blue: 0.38, alpha: 1)
            break
        }
    }
}

extension BAXCTPCheckBox {
    @objc private func _onBtnSelected(_ sender: NSButton?) {
        if self._target != nil && self._action != nil && self._target!.responds(to: self._action!) {
            self._target!.perform(self._action!, with: self)
        }
    }
}
