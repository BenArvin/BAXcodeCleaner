//
//  BAXCFileSizeCellView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/2.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCFileSizeCellViewConstants {
    static let identifier: String = "BAXCFileSizeCellView"
}

public class BAXCFileSizeCellView: BAXCTableViewCell {
    private var _size: Int = 0
    public var size: Int {
        set {
            _size = newValue
            self._sizeTextField.stringValue = self._convertToStr(_size)
        }
        get {
            return _size
        }
    }
    
    private lazy var _sizeTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 18)
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._sizeTextField)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.size = 0
        self._sizeTextField.stringValue = ""
    }
    
    public override func layout() {
        super.layout()
        self._sizeTextField.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}

extension BAXCFileSizeCellView {
    private func _convertToStr(_ size: Int) -> String {
        let size_d: Double = Double(size)
        if size_d < 1024.0 {
            return String.init(format: "%ldByte", size)
        } else if size_d < 1024.0 * 1024.0 {
            return String.init(format: "%.1fKB", size_d / 1024.0)
        } else if size_d < 1024.0 * 1024.0 * 1024.0 {
            return String.init(format: "%.1fMB", size_d / 1024.0 / 1024.0)
        } else {
            return String.init(format: "%.1fGB", size_d / 1024.0 / 1024.0 / 1024.0)
        }
    }
}
