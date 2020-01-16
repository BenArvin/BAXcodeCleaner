//
//  AppDelegate.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/25.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    public var rootVC: BAXCMainDeskVC?
    public var rootNavi: BANavigationController?
    public var window: NSWindow?
    public var rootWC: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.rootVC = BAXCMainDeskVC()
        self.rootNavi = BANavigationController.init(rootViewController: self.rootVC!)
        self.window = NSWindow.init(contentViewController: self.rootNavi!)
        
        let width: CGFloat = floor(NSScreen.main!.frame.width * 0.618)
        let height: CGFloat = floor(NSScreen.main!.frame.height * 0.618)
        self.window!.setFrame(NSRect.init(x: floor((NSScreen.main!.frame.width - width) / 2),
                                          y: floor((NSScreen.main!.frame.height - height) / 2),
                                          width: width,
                                          height: height),
                              display: true)
        self.window!.styleMask = [NSWindow.StyleMask.closable, NSWindow.StyleMask.miniaturizable, NSWindow.StyleMask.resizable, NSWindow.StyleMask.titled]
        self.window!.backingType = NSWindow.BackingStoreType.buffered
        self.window!.title = BAXCDefines.Repo.Name
        self.window!.delegate = self

        self.rootWC = NSWindowController.init(window: self.window!)
        self.rootWC!.showWindow(self)
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5) {
            BAUpdateManager.checkUpdate(true)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        exit(0)
    }
}

// MARK: - main menu actions
extension AppDelegate {
    @objc func introductionAction() {
        BAXCSelfIntroduction.show()
    }
    
    @objc func quitAction() {
        exit(0)
    }
    
    @objc func minimizeAction() {
        self.window!.miniaturize(self)
    }
    
    @objc func refreshAction() {
        self.rootVC!.onMenuRefreshItemSelected(nil)
    }
    
    @objc func deleteAction() {
        self.rootVC!.onMenuCleanItemSelected(nil)
    }
    
    @objc func bugReportAction() {
        BABugReporter.show()
    }
    
    @objc func checkForUpdatesAction() {
        BAUpdateManager.checkUpdate(false)
    }
}
