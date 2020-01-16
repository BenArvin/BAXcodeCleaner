//
//  BAXCSelfIntroductionManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

private class BAXCSelfIntroductionVC: NSViewController, NSTextViewDelegate {
    private lazy var _titleTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.center
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.bold)
        result.stringValue = BAXCDefines.Repo.Name
        return result
    }()
    
    private lazy var _versionTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.center
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 18)
        result.stringValue = String.init(format: "%@(%@)", Bundle.main.mc_releaseVersion(), Bundle.main.mc_buildVersion())
        return result
    }()
    
    private lazy var _introTextView: NSTextView = {
        let result: NSTextView = NSTextView.init()
        result.isEditable = false
        result.isSelectable = true
        result.backgroundColor = NSColor.clear
        result.alignment = NSTextAlignment.center
        let attrStr: NSMutableAttributedString = NSMutableAttributedString.init()
        attrStr.append(NSAttributedString.init(string: "GitHub: ", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)]))
        attrStr.append(NSAttributedString.init(string: BAXCDefines.Repo.Address, attributes: [NSAttributedString.Key.link : BAXCDefines.Repo.Address, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)]))
        result.textStorage?.setAttributedString(attrStr)
        return result
    }()
    
    private lazy var _licenseTextView: NSTextView = {
        let result: NSTextView = NSTextView.init()
        result.isEditable = false
        result.isSelectable = true
        result.backgroundColor = NSColor.clear
        result.alignment = NSTextAlignment.center
        let attrStr: NSMutableAttributedString = NSMutableAttributedString.init()
        attrStr.append(NSAttributedString.init(string: "License: ", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)]))
        attrStr.append(NSAttributedString.init(string: "GNU GPL", attributes: [NSAttributedString.Key.link : BAXCDefines.Repo.License, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)]))
        result.textStorage?.setAttributedString(attrStr)
        return result
    }()
    
    override func loadView() {
      self.view = NSView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if self._titleTextField.superview != self.view {
            self.view.addSubview(self._titleTextField)
            self.view.addSubview(self._versionTextField)
            self.view.addSubview(self._introTextView)
            self.view.addSubview(self._licenseTextView)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self._titleTextField.frame = CGRect.init(x: 15, y: self.view.bounds.height - 30, width: self.view.bounds.width - 30, height: 30)
        self._versionTextField.frame = CGRect.init(x: 15, y: self._titleTextField.frame.minY - 20 - 5, width: self.view.bounds.width - 30, height: 20)
        self._licenseTextView.frame = CGRect.init(x: 15, y: 10, width: self.view.bounds.width - 30, height: 20)
        self._introTextView.frame = CGRect.init(x: 15, y: self._licenseTextView.frame.maxY + 10, width: self.view.bounds.width - 30, height: self._versionTextField.frame.minY - 15 - self._licenseTextView.frame.maxY - 10)
    }
}

public class BAXCSelfIntroduction: NSObject{

    private var _displaying: Bool = false
    private var _rootVC: BAXCSelfIntroductionVC?
    private var _window: NSWindow?
    private var _rootWC: NSWindowController?
    
    private static let shared: BAXCSelfIntroduction = {
        let instance = BAXCSelfIntroduction()
        return instance
    }()
    
    public class func show() {
        self.shared._show()
    }
}

extension BAXCSelfIntroduction: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
        self._rootVC = nil
        self._window = nil
        self._rootWC = nil
        self._displaying = false
    }
}

// MARK: - private methods
extension BAXCSelfIntroduction {
    private func _show() {
        if self._displaying == true {
            return
        }
        self._displaying = true
        if self._rootVC == nil {
            self._rootVC = BAXCSelfIntroductionVC()
        }
        
        let width: CGFloat = 300
        let height: CGFloat = floor(width * 0.618)
        if self._window == nil {
            self._window = NSWindow.init(contentViewController: self._rootVC!)
        }
        self._window!.setFrame(NSRect.init(x: floor((NSScreen.main!.frame.width - width) / 2),
                                           y: floor((NSScreen.main!.frame.height - height) / 2),
                                           width: width,
                                           height: height),
                               display: true)
        self._window!.styleMask = [NSWindow.StyleMask.closable, NSWindow.StyleMask.titled]
        self._window!.backingType = NSWindow.BackingStoreType.buffered
        self._window!.title = "About"
        self._window!.delegate = self
        
        if self._rootWC == nil {
            self._rootWC = NSWindowController.init(window: self._window!)
        }
        self._rootWC!.showWindow(self)
        NSApplication.shared.runModal(for: self._window!)
    }
}
