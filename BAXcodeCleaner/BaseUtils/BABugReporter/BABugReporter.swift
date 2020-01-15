//
//  BABugReporter.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/15.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BABugReporter: NSObject{

    private var _displaying: Bool = false
    private var _rootVC: BABugReporterVC?
    private var _window: NSWindow?
    private var _rootWC: NSWindowController?
    
    private static let shared: BABugReporter = {
        let instance = BABugReporter()
        return instance
    }()
    
    public class func show() {
        self.shared._show()
    }
}

extension BABugReporter: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
        self._rootVC = nil
        self._window = nil
        self._rootWC = nil
        self._displaying = false
    }
}

// MARK: - private methods
extension BABugReporter {
    private func _show() {
        if self._displaying == true {
            return
        }
        self._displaying = true
        if self._rootVC == nil {
            self._rootVC = BABugReporterVC()
        }
        
        let width: CGFloat = 600
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
        self._window!.title = "Bug report"
        self._window!.delegate = self
        
        if self._rootWC == nil {
            self._rootWC = NSWindowController.init(window: self._window!)
        }
        self._rootWC!.showWindow(self)
        NSApplication.shared.runModal(for: self._window!)
    }
}
