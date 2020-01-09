//
//  BAXCSectionCheckBoxCellView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCSectionCheckBoxCellViewConstants {
    static let identifier: String = "BAXCSectionCheckBoxCellView"
}

public protocol BAXCSectionCheckBoxCellViewDelegate: class {
    func onSectionCheckBoxSelected(cell: BAXCSectionCheckBoxCellView)
}

public class BAXCSectionCheckBoxCellView: BAXCTableViewCell {
    public var delegate: BAXCSectionCheckBoxCellViewDelegate?
    
    public var state: BAXCTPCheckBox.State {
        set {
            self._checkBox.state = newValue
        }
        get {
            return self._checkBox.state
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
        self.state = BAXCTPCheckBox.State.Uncheck
    }
    
    public override func layout() {
        super.layout()
        self._checkBox.frame = CGRect.init(x: floor((self.bounds.width - 16) / 2),
                                           y: 5,
                                           width: 16,
                                           height: 16)
    }
}

extension BAXCSectionCheckBoxCellView {
    @objc private func _onSelAllCheckBoxSelected(_ sender: NSButton?) {
        if self._checkBox.state == BAXCTPCheckBox.State.Uncheck {
            self._checkBox.state = BAXCTPCheckBox.State.Check
        } else {
            self._checkBox.state = BAXCTPCheckBox.State.Uncheck
        }
        if self.delegate != nil {
            self.delegate!.onSectionCheckBoxSelected(cell: self)
        }
    }
}
