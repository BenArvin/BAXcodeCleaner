//
//  ViewController.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/25.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
      self.view = NSView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
//        self.view.wantsLayer = true
    }
}

