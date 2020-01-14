//
//  BAXCAutoDismissAlert.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/14.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

fileprivate class BAXCAutoDismissAlertView: NSView {
    private lazy var _bgView: BAXCBlockView = {
        let result: BAXCBlockView = BAXCBlockView()
        result.wantsLayer = true
        result.layer!.backgroundColor = NSColor.clear.cgColor
        result.isEnabled = false
        return result
    }()
    
    private lazy var _contentView: NSView = {
        let result: NSView = NSView()
        result.wantsLayer = true
        result.layer!.backgroundColor = NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        result.layer!.cornerRadius = 8
        return result
    }()
    
    public lazy var msgTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.center
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byCharWrapping
        result.font = NSFont.systemFont(ofSize: 16)
        return result
    }()
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self._bgView)
        self.addSubview(self._contentView)
        self._contentView.addSubview(self.msgTextField)
    }
    
    public override func layout() {
        super.layout()
        let bounds: CGRect = self.bounds
        self._bgView.frame = bounds
        
        let maxWidth: CGFloat = 200
        let minWidth: CGFloat = 20
        let maxHeight: CGFloat = 200
        let minHeight: CGFloat = 20
        
        let msgIdealSize: CGSize = self.msgTextField.sizeThatFits(NSSize.init(width: maxWidth, height: maxHeight))
        var textFieldWidth: CGFloat = msgIdealSize.width > maxWidth ? maxWidth : msgIdealSize.width
        textFieldWidth = textFieldWidth < minWidth ? minWidth : textFieldWidth
        var textFieldHeight: CGFloat = msgIdealSize.height > maxHeight ? maxHeight : msgIdealSize.height
        textFieldHeight = textFieldHeight < minHeight ? minHeight : textFieldHeight
        
        let contentViewWidth: CGFloat = textFieldWidth + 20
        let contentViewHeight: CGFloat = textFieldHeight + 20
        
        self._contentView.frame = CGRect.init(x: floor((bounds.size.width - contentViewWidth) / 2),
                                              y: floor((bounds.size.height - contentViewHeight) / 2),
                                              width: contentViewWidth, height: contentViewHeight)
        self.msgTextField.frame = CGRect.init(x: 10, y: 10, width: textFieldWidth, height: textFieldHeight)
    }
}

public class BAXCAutoDismissAlert {
    public class func show(_ message: String?, inView: NSView?, aliveTime: Double = 5) {
        if message == nil || message!.isEmpty {
            return
        }
        if inView == nil {
            return
        }
        let alertView: BAXCAutoDismissAlertView = BAXCAutoDismissAlertView.init()
        alertView.msgTextField.stringValue = message!
        alertView.frame = inView!.bounds
        alertView.alphaValue = 0.0
        inView!.addSubview(alertView)
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) in
            context.duration = 0.2
            alertView.animator().alphaValue = 1.0
        }) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + aliveTime) {
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) in
                    context.duration = 0.2
                    alertView.animator().alphaValue = 0
                }) {
                    alertView.removeFromSuperview()
                }
            }
        }
    }
}
