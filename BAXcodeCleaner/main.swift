//
//  main.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

autoreleasepool {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    
    let firstMenu: NSMenu = NSMenu.init()
    firstMenu.addItem(NSMenuItem.init(title: "About", action: #selector(AppDelegate.introductionAction), keyEquivalent: ""))
    firstMenu.addItem(NSMenuItem.separator())
    firstMenu.addItem(NSMenuItem.init(title: "Quit", action: #selector(AppDelegate.quitAction), keyEquivalent: "q"))

    let firstMenuItem: NSMenuItem = NSMenuItem.init()
    firstMenuItem.submenu = firstMenu
    
    let windowMenu: NSMenu = NSMenu.init(title: "Window")
    windowMenu.addItem(NSMenuItem.init(title: "Minimize", action: #selector(AppDelegate.minimizeAction), keyEquivalent: "m"))

    let windowMenuItem: NSMenuItem = NSMenuItem.init()
    windowMenuItem.submenu = windowMenu
    
    app.mainMenu = NSMenu.init()
    app.mainMenu!.addItem(firstMenuItem)
    app.mainMenu!.addItem(windowMenuItem)
    
    app.run()
}
