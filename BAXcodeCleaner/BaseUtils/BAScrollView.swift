//
//  BAScrollView.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/11.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

class BAScrollView: NSScrollView {
    public var enableXScroll: Bool = true
    public var enableYScroll: Bool = true
    
    override func scrollWheel(with event: NSEvent) {
        if self.enableXScroll == false && event.deltaX != 0 {
            self.nextResponder?.scrollWheel(with: event)
        } else if self.enableYScroll == false && event.deltaY != 0 {
            self.nextResponder?.scrollWheel(with: event)
        } else {
            super.scrollWheel(with: event)
        }
    }
}
