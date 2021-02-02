//
//  BADarkView.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2021/2/2.
//  Copyright © 2021 BenArvin. All rights reserved.
//

import Cocoa

public class BADarkView: NSView {
    public override func layout() {
        super.layout()
        self.appearance = NSAppearance.init(named: .darkAqua)
    }
}
