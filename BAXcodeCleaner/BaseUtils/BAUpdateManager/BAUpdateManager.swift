//
//  BAUpdateManager.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/15.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAUpdateManager: NSObject{
    
    public struct Constants {
        public struct Repo {
            static let Name: String = BAXCDefines.Repo.Name
            static let DownloadLink: String = BAXCDefines.Repo.DownloadLink
            static let LatestRelase: String = BAXCDefines.Repo.LatestRelase
        }
    }

    private var _lock: NSRecursiveLock = NSRecursiveLock.init()
    private var __checking: Bool = false
    private var _checking: Bool {
        set {
            self._lock.lock()
            self.__checking = newValue
            self._lock.unlock()
        }
        get {
            var result: Bool = false
            self._lock.lock()
            result = self.__checking
            self._lock.unlock()
            return result
        }
    }
    private var _displaying: Bool = false
    private var _rootVC: BACheckUpdateVC?
    private var _window: NSWindow?
    private var _rootWC: NSWindowController?
    
    private static let shared: BAUpdateManager = {
        let instance = BAUpdateManager()
        return instance
    }()
}

extension BAUpdateManager {
    public func queryLatestVersion(_ completion: ((_ : Bool, _: String?) -> ())?) {
        BAVersionCheck.queryLatestVersion(completion)
    }
    
    public class func checkUpdate(_ silence: Bool) {
        self.shared._checkUpdate(silence)
    }
}

extension BAUpdateManager: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
//        NSApplication.shared.stopModal()
        self._rootVC = nil
        self._window = nil
        self._rootWC = nil
        self._checking = false
    }
}

// MARK: - private methods
extension BAUpdateManager {
    private func _checkUpdate(_ silence: Bool) {
        if self._checking == true {
            return
        }
        self._checking = true
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if silence == true {
                BAVersionCheck.queryLatestVersion { [weak strongSelf] (successed: Bool, newVersion: String?) in
                    guard let strongSelf2 = strongSelf else {
                        return
                    }
                    if successed == false {
                        strongSelf2._checking = false
                        return
                    }
                    let currentVersion: String? = BAVersionCheck.currentVersion()
                    if currentVersion == nil || currentVersion!.isEmpty || newVersion == nil || newVersion!.isEmpty {
                        strongSelf2._checking = false
                        return
                    }
                    if currentVersion! == newVersion! {
                        strongSelf2._checking = false
                        return
                    }
                    DispatchQueue.main.async { [weak strongSelf2] in
                        guard let strongSelf3 = strongSelf2 else {
                            return
                        }
                        strongSelf3._show()
                        strongSelf3._setState(BACheckUpdateVC.State.Normal, newVersion: newVersion, currentVersion: currentVersion)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak strongSelf] in
                    guard let strongSelf2 = strongSelf else {
                        return
                    }
                    strongSelf2._show()
                    strongSelf2._setState(BACheckUpdateVC.State.Loading, newVersion: nil, currentVersion: nil)
                }
                let currentVersion: String? = BAVersionCheck.currentVersion()
                BAVersionCheck.queryLatestVersion { [weak strongSelf] (successed: Bool, newVersion: String?) in
                    guard let strongSelf2 = strongSelf else {
                        return
                    }
                    DispatchQueue.main.async { [weak strongSelf2] in
                        guard let strongSelf3 = strongSelf2 else {
                            return
                        }
                        strongSelf3._setState(BACheckUpdateVC.State.Normal, newVersion: newVersion, currentVersion: currentVersion)
                    }
                }
            }
        }
    }
    
    private func _show() {
        if self._rootVC == nil {
            self._rootVC = BACheckUpdateVC()
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
        self._window!.title = "Check for Updates"
        self._window!.delegate = self
        
        if self._rootWC == nil {
            self._rootWC = NSWindowController.init(window: self._window!)
        }
        self._rootWC!.showWindow(self)
//        NSApplication.shared.runModal(for: self._window!)
    }
    
    private func _setState(_ state: BACheckUpdateVC.State, newVersion: String?, currentVersion: String?) {
//        NSApplication.shared.stopModal()
        self._rootVC?.setState(state, newVersion: newVersion, currentVersion: currentVersion)
//        NSApplication.shared.runModal(for: self._window!)
    }
}
