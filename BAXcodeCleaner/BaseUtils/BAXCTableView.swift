//
//  BAXCTableView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/13.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCTableView: NSTableView {
    private var _enableKeyEvent: Bool = true
    public var enableKeyEvent: Bool {
        set {
            self._enableKeyEvent = newValue
        }
        get {
            return self._enableKeyEvent
        }
    }
    
    override public func keyDown(with event: NSEvent) {
        if self._enableKeyEvent == true {
            super.keyDown(with: event)
        }
    }
    
    override public func keyUp(with event: NSEvent) {
        if self._enableKeyEvent == true {
            super.keyUp(with: event)
        }
    }
}
