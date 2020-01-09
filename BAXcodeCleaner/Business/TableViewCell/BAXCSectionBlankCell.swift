//
//  BAXCSectionBlankCell.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCSectionBlankCellConstants {
    static let identifier: String = "BAXCSectionBlankCell"
}

public class BAXCSectionBlankCell: BAXCTableViewCell {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
