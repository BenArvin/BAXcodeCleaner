//
//  BAXCMainDeskVC.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/14.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BAXCMainDeskVC: BAViewController {
    private lazy var _cleanBtn: NSButton = {
        let result = NSButton.init(title: "Just clean it!", target: self, action: #selector(_onCleanBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.font = NSFont.systemFont(ofSize: 20)
        return result
    }()
    
    private lazy var _cleanBtnTips: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 16)
        result.stringValue = "Lazy mode, clean derived data and device support files only for safety."
        return result
    }()
    
    private lazy var _manualBtn: NSButton = {
        let result = NSButton.init(title: "Manual mode", target: self, action: #selector(_onManualBtnSelected(_:)))
        result.bezelStyle = NSButton.BezelStyle.regularSquare
        result.font = NSFont.systemFont(ofSize: 20)
        return result
    }()
    
    private lazy var _manualBtnTips: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.lightGray
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 16)
        result.stringValue = "Search many more kinds of temporary files, you can clean it accurately."
        return result
    }()
    
    private lazy var _loadingView: BAXCProgressIndicator = {
        let result: BAXCProgressIndicator = BAXCProgressIndicator.init()
        result.hide()
        return result
    }()
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        if self._cleanBtn.superview != self.view {
            self.view.addSubview(self._cleanBtn)
            self.view.addSubview(self._cleanBtnTips)
            self.view.addSubview(self._manualBtn)
            self.view.addSubview(self._manualBtnTips)
            self.view.addSubview(self._loadingView)
        }
    }
    
    public override func viewWillLayout() {
        super.viewWillLayout()
        self._setElementsFrame()
    }
}

// MARK: - UI setting
extension BAXCMainDeskVC {
    private func _setElementsFrame() {
        let bounds: CGRect = self.view.bounds
        let marginLeft: CGFloat = floor(bounds.width / 3.5)
        let marginTop: CGFloat = floor(bounds.height / 2.7)
        
        let cleanBtnWidth: CGFloat = 140
        let cleanBtnHeight: CGFloat = 75
        self._manualBtn.frame = CGRect.init(x: marginLeft, y: marginTop, width: cleanBtnWidth, height: cleanBtnHeight)
        
        self._cleanBtn.frame = CGRect.init(x: self._manualBtn.frame.minX, y: bounds.height - marginTop, width: self._manualBtn.bounds.width, height: self._manualBtn.bounds.height)

        let tipsWidth: CGFloat = bounds.width - marginLeft * 2 - self._cleanBtn.bounds.width - 20
        
        let _cleanBtnTipsIdealSize: CGSize = self._cleanBtnTips.sizeThatFits(NSSize.init(width: tipsWidth, height: 0))
        self._cleanBtnTips.frame = CGRect.init(x: self._cleanBtn.frame.maxX + 20, y: self._cleanBtn.frame.minY + floor((self._cleanBtn.bounds.height - _cleanBtnTipsIdealSize.height) / 2), width: bounds.width - marginLeft * 2 - self._cleanBtn.bounds.width - 20, height: _cleanBtnTipsIdealSize.height)

        let _manualBtnTipsIdealSize: CGSize = self._manualBtnTips.sizeThatFits(NSSize.init(width: tipsWidth, height: 0))
        self._manualBtnTips.frame = CGRect.init(x: self._cleanBtnTips.frame.minX, y: self._manualBtn.frame.minY + floor((self._manualBtn.bounds.height - _manualBtnTipsIdealSize.height) / 2), width: self._cleanBtnTips.bounds.width, height: _manualBtnTipsIdealSize.height)
        
        self._loadingView.frame = bounds
    }
}

// MARK: - selector methods
extension BAXCMainDeskVC {
    @objc private func _onCleanBtnSelected(_ sender: NSButton?) {
        let alert: NSAlert = NSAlert.init()
        alert.alertStyle = NSAlert.Style.critical
        alert.messageText = "Are you sure?"
        alert.informativeText = "Derived data and device support files will be cleaned."
        alert.addButton(withTitle: "YES")
        alert.addButton(withTitle: "NO")
        let res: NSApplication.ModalResponse = alert.runModal()
        if res != NSApplication.ModalResponse.alertFirstButtonReturn {
            return
        }
        self._loadingView.message = "Cleaning..."
        self._loadingView.show()
        self._simplyClean { [weak self] in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async { [weak strongSelf] in
                guard let strongSelf2 = strongSelf else {
                    return
                }
                strongSelf2._loadingView.hide()
                BAXCAutoDismissAlert.show("Successed!", inView: strongSelf2.view, aliveTime: 5)
            }
        }
    }
    
    @objc private func _onManualBtnSelected(_ sender: NSButton?) {
//        let manualCleanVC: BAXCManualCleanVC = BAXCManualCleanVC.init()
        let manualCleanVC: BAXCManualCleanVC = BAXCManualCleanVC.init()
        self.navigationController!.presentViewController(manualCleanVC, animated: true, completion: nil)
    }
}

// MARK - menuItem methods
extension BAXCMainDeskVC {
    @objc public override func onMenuCleanItemSelected(_ sender: NSButton?) {
        self._onCleanBtnSelected(sender)
    }
}

// MARK - private methods
extension BAXCMainDeskVC {
    private func _simplyClean(_ completion: (() -> ())?) {
        let group = DispatchGroup.init()
        group.enter()
        DispatchQueue.global().async{
            BAXCDerivedDataTrashManager.simplyClean()
            group.leave()
        }
        group.enter()
        DispatchQueue.global().async{
            BAXCDeviceSupportTrashManager.simplyClean()
            group.leave()
        }
        group.notify(queue: DispatchQueue.global()) {
            if completion != nil {
                completion!()
            }
        }
    }
}
