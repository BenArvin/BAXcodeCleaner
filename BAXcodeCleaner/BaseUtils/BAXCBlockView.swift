//
//  BAXCBlockView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCBlockView: NSView {
    private var _isEnabled: Bool = false
    public var isEnabled: Bool {
        set {
            self._isEnabled = newValue
            self.needsLayout = true
        }
        get {
            return self._isEnabled
        }
    }
    
    private lazy var _scrollView: NSScrollView = {
        let result = NSScrollView.init()
        result.drawsBackground = false
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self._scrollView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layout() {
        super.layout()
        self._scrollView.frame = self.bounds
        self._scrollView.isHidden = self.isEnabled
    }
}
