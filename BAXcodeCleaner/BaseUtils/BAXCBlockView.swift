//
//  BAXCBlockView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCBlockView: NSView {
    public var isEnabled: Bool = false
    
    public override func mouseDown(with event: NSEvent) {
        if self.isEnabled {
            super.mouseDown(with: event)
        }
    }
}
