//
//  BAXCSectionFoldCellView.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/7.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public struct BAXCSectionFoldCellViewConstants {
    static let identifier: String = "BAXCSectionFoldCellView"
}

public protocol BAXCSectionFoldCellViewDelegate: class {
    func onFoldBtnSelected(cell: BAXCSectionFoldCellView)
}

public class BAXCSectionFoldCellView: BAXCTableViewCell {
    
    public var delegate: BAXCSectionFoldCellViewDelegate?
    
    public var isFolded: Bool = false
    
    private lazy var _foldBtn: NSButton = {
        let result: NSButton = NSButton.init(title: "", target: self, action: #selector(onFoldBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.imageScaling = NSImageScaling.scaleAxesIndependently
        result.imagePosition = NSControl.ImagePosition.imageOnly
        return result
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self._foldBtn)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.isFolded = false
        self._foldBtn.image = nil
    }
    
    public override func layout() {
        super.layout()
        self._foldBtn.frame = CGRect.init(x: floor((self.bounds.width - 25) / 2), y: 0, width: 25, height: 25)
        self._foldBtn.image = self.isFolded == true ? NSImage(named: NSImage.Name("triangle-right-white")) : NSImage(named: NSImage.Name("triangle-down-white"))
    }
}

extension BAXCSectionFoldCellView {
    @objc public func onFoldBtnSelected(_ sender: NSButton?) {
        if self.delegate != nil {
            self.delegate!.onFoldBtnSelected(cell: self)
        }
    }
}
