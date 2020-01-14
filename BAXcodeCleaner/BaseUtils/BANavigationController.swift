//
//  BAXCNavigationController.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/13.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAViewController: NSViewController {
    public weak var navigation: BANavigationController? = nil
    
    override public func loadView() {
        self.view = NSView()
    }
    
    public override var title: String? {
        set {
            super.title = newValue
            if self.navigation == nil {
                return
            }
            self.navigation!._updateTitle(self)
        }
        get {
            return super.title
        }
    }
}

public class BANavigationController: BAViewController {
    private weak var _window: NSWindow? = nil
    public weak var window: NSWindow? {
        get {
            return self._window
        }
        set {
            self._window = newValue
            if self.rootViewController != nil {
                self._updateTitle(self.rootViewController!)
            }
        }
    }
    
    public var viewControllers: [BAViewController]? = nil
    
    public var rootViewController: BAViewController? {
        get {
            if self.viewControllers == nil || self.viewControllers!.isEmpty {
                return nil
            }
            return self.viewControllers![0]
        }
    }
    
    public var topViewController: BAViewController? {
        get {
            if self.viewControllers == nil || self.viewControllers!.isEmpty {
                return nil
            }
            return self.viewControllers!.last
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if self.rootViewController != nil {
            self.view.addSubview(self.rootViewController!.view)
        }
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        if self.topViewController != nil {
            self._updateTitle(self.topViewController!)
        }
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
    public override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    public override func viewWillLayout() {
        super.viewWillLayout()
        for subView in self.view.subviews {
            subView.frame = self.view.bounds
        }
    }
    
    public override func viewDidLayout() {
        super.viewDidLayout()
    }
}

extension BANavigationController {
    convenience init(rootViewController: BAViewController) {
        self.init()
        rootViewController.navigation = self
        self.addChild(rootViewController)
        self.viewControllers = [rootViewController]
    }
}

extension BANavigationController {
    public func presentViewController(_ viewController: BAViewController?, animated: Bool, completion: (() -> Void)?) {
        if viewController == nil {
            if completion != nil {
                completion!()
            }
            return
        }
        viewController!.navigation = self
        self.viewControllers!.append(viewController!)
        self.addChild(viewController!)
        let count: Int = self.viewControllers!.count
        let fromVC: BAViewController = self.viewControllers![count - 2]
        let toVC: BAViewController = self.viewControllers![count - 1]
        
        self._transitionVCs(fromVC: fromVC, toVC: toVC, animated: animated) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf._updateTitle(toVC)
            if completion != nil {
                completion!()
            }
        }
    }
    
    public func popViewControllerAnimated(_ animated: Bool, completion: (() -> Void)?) {
        let count: Int = self.viewControllers!.count
        if count <= 1 {
            if completion != nil {
                completion!()
            }
            return
        }
        let fromVC: BAViewController = self.viewControllers![count - 1]
        let toVC: BAViewController = self.viewControllers![count - 2]
        self._updateTitle(toVC)
        
        self._transitionVCs(fromVC: fromVC, toVC: toVC, animated: animated) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            fromVC.removeFromParent()
            let _ = strongSelf.viewControllers!.popLast()
            if completion != nil {
                completion!()
            }
        }
    }
    
    private func _transitionVCs(fromVC: BAViewController, toVC: BAViewController, animated: Bool, completion: @escaping (() -> Void)) {
        if animated {
            self.transition(from: fromVC, to: toVC, options: NSViewController.TransitionOptions.crossfade, completionHandler: {
                completion()
            })
        } else {
            self.view.addSubview(toVC.view)
            fromVC.view.removeFromSuperview()
            completion()
        }
    }
}

extension BANavigationController {
    fileprivate func _updateTitle(_ viewController: BAViewController) {
        if self.window != nil {
            self.window!.title = (viewController.title == nil ? "" : viewController.title!)
        }
    }
}
