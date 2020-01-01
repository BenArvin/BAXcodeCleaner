//
//  BAXCCheckBoxCellView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCCheckBoxCellViewConstants {
    static let identifier: String = "BAXCCheckBoxCellView"
}

public protocol BAXCCheckBoxCellViewDelegate: class {
    func onCheckBoxSelected(cell: BAXCCheckBoxCellView)
}

public class BAXCCheckBoxCellView: BAXCTableViewCell {
    
    public var delegate: BAXCCheckBoxCellViewDelegate?
    
    public var selected: Bool {
        set {
            self._checkBox.state = newValue == true ? NSControl.StateValue.on : NSControl.StateValue.off
        }
        get {
            return self._checkBox.state == NSControl.StateValue.on ? true : false
        }
    }
    
    private lazy var _checkBox: NSButton = {
        let result: NSButton = NSButton.init(checkboxWithTitle: "", target: self, action: #selector(_onSelAllCheckBoxSelected(_:)))
        result.state = NSControl.StateValue.off
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._checkBox)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.selected = false
    }
    
    public override func layout() {
        super.layout()
        self._checkBox.sizeToFit()
        self._checkBox.frame = CGRect.init(x: floor((self.bounds.width - self._checkBox.bounds.width) / 2),
                                           y: floor((self.bounds.height - self._checkBox.bounds.height) / 2),
                                           width: self._checkBox.bounds.width,
                                           height: self._checkBox.bounds.height)
    }
}

extension BAXCCheckBoxCellView {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        if self.delegate != nil {
            self.delegate!.onCheckBoxSelected(cell: self)
        }
    }
}
