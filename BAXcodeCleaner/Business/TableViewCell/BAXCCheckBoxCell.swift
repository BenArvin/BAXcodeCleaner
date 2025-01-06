//
//  BAXCCheckBoxCell.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCCheckBoxCellDelegate: AnyObject {
    func onCheckBoxSelected(cell: BAXCCheckBoxCell) -> BAXCTPCheckBox.State
}

public class BAXCCheckBoxCell: BAXCTableViewCell {
    public static let identifier: String = "BAXCCheckBoxCell"
    public var delegate: BAXCCheckBoxCellDelegate?
    
    private var _state: BAXCTPCheckBox.State = BAXCTPCheckBox.State.Uncheck
    public var state: BAXCTPCheckBox.State {
        set {
            self._state = newValue
            self._checkBox.state = newValue
        }
        get {
            return self._state
        }
    }
    
    private lazy var _checkBox: BAXCTPCheckBox = {
        let result: BAXCTPCheckBox = BAXCTPCheckBox.init(target: self, action: #selector(_onSelAllCheckBoxSelected(_:)))
        result.state = BAXCTPCheckBox.State.Uncheck
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
        self._state = BAXCTPCheckBox.State.Uncheck
    }
    
    public override func layout() {
        super.layout()
        self._checkBox.frame = CGRect.init(x: floor((self.bounds.width - 16) / 2),
                                           y: floor((self.bounds.height - 16) / 2),
                                           width: 16,
                                           height: 16)
    }
}

extension BAXCCheckBoxCell {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        if self.delegate != nil {
            self.state = self.delegate!.onCheckBoxSelected(cell: self)
        }
    }
}
