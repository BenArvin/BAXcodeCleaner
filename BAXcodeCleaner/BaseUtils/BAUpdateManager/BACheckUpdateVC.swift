//
//  BACheckUpdateVC.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/16.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

public class BACheckUpdateVC: NSViewController {
    private var _datas: [(String, String, Date)]? = nil
    
    private lazy var _contentView: NSView = {
        let result: NSView = NSView.init()
        return result
    }()
    
    private lazy var _newVersionTitleTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 20, weight: NSFont.Weight.bold)
        result.stringValue = "A new version is avaliable!"
        result.isHidden = true
        return result
    }()
    
    private lazy var _newVersionContentTextView: NSTextView = {
        let result: NSTextView = NSTextView.init()
        result.isEditable = false
        result.isSelectable = true
        result.backgroundColor = NSColor.clear
        result.alignment = NSTextAlignment.left
        result.isHidden = true
        return result
    }()
    
    private lazy var _withoutNewTipsTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 18, weight: NSFont.Weight.regular)
        result.stringValue = "There are currently no updates available."
        result.isHidden = true
        return result
    }()
    
    private lazy var _errorTipsTextField: NSTextField = {
        let result: NSTextField = NSTextField.init()
        result.isEditable = false
        result.isBordered = false
        result.isSelectable = false
        result.backgroundColor = NSColor.clear
        result.textColor = NSColor.white
        result.alignment = NSTextAlignment.left
        result.maximumNumberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping
        result.font = NSFont.systemFont(ofSize: 18, weight: NSFont.Weight.regular)
        result.stringValue = "Check for updates failed, please try later."
        result.isHidden = true
        return result
    }()
    
    private lazy var _indicator: NSProgressIndicator = {
        let result: NSProgressIndicator = NSProgressIndicator()
        result.style = NSProgressIndicator.Style.spinning
        result.isHidden = true
        return result
    }()
    
    public enum State: Int {
        case Normal = 0
        case Loading = 1
        case Error = 2
    }
    
    deinit {
        self._indicator.stopAnimation(self)
    }
    
    override public func loadView() {
      self.view = NSView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        if self._indicator.superview != self.view {
            self.view.addSubview(self._contentView)
            self._contentView.addSubview(self._newVersionTitleTextField)
            self._contentView.addSubview(self._newVersionContentTextView)
            self._contentView.addSubview(self._withoutNewTipsTextField)
            self._contentView.addSubview(self._errorTipsTextField)
            self.view.addSubview(self._indicator)
        }
    }
    
    override public func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        self._setElementsFrame()
    }
}

extension BACheckUpdateVC {
    public func showLoading() {
        self._indicator.startAnimation(self)
        self._indicator.isHidden = false
        self._contentView.isHidden = true
    }
    
    public func hideLoading() {
        self._contentView.isHidden = false
        self._indicator.isHidden = true
        self._indicator.stopAnimation(self)
    }
    
    public func setState(_ state: State, newVersion: String?, currentVersion: String?) {
        if state == .Loading {
            self._indicator.startAnimation(self)
            self._indicator.isHidden = false
            self._contentView.isHidden = true
        } else {
            self._contentView.isHidden = false
            self._indicator.isHidden = true
            self._indicator.stopAnimation(self)
            
            if state == .Error || newVersion == nil || currentVersion == nil || newVersion!.isEmpty || currentVersion!.isEmpty {
                self._newVersionTitleTextField.isHidden = true
                self._newVersionContentTextView.isHidden = true
                self._withoutNewTipsTextField.isHidden = true
                self._errorTipsTextField.isHidden = false
            } else {
                self._errorTipsTextField.isHidden = true
                if newVersion! == currentVersion! {
                    self._newVersionTitleTextField.isHidden = true
                    self._newVersionContentTextView.isHidden = true
                    self._withoutNewTipsTextField.isHidden = false
                } else {
                    self._newVersionTitleTextField.isHidden = false
                    self._newVersionContentTextView.isHidden = false
                    self._withoutNewTipsTextField.isHidden = true
                    let attrStr: NSMutableAttributedString = NSMutableAttributedString.init()
                    attrStr.append(NSAttributedString.init(string: String.init(format: "%@ is now avaliable, you can download form here:\n", newVersion!), attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18, weight: NSFont.Weight.regular)]))
                    attrStr.append(NSAttributedString.init(string: BAUpdateManager.Constants.Repo.DownloadLink, attributes: [NSAttributedString.Key.link : BAUpdateManager.Constants.Repo.DownloadLink, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18, weight: NSFont.Weight.regular)]))
                    self._newVersionContentTextView.textStorage?.setAttributedString(attrStr)
                }
            }
        }
        self._setElementsFrame()
    }
}

extension BACheckUpdateVC {
    private func _setElementsFrame() {
        let bounds = self.view.bounds
        self._indicator.sizeToFit()
        let size: CGFloat = self._indicator.frame.width
        self._indicator.frame = CGRect.init(x: floor((bounds.width - size) / 2),
                                            y: floor((bounds.height - size) / 2),
                                            width: size,
                                            height: size)
        
        self._contentView.frame = bounds
        
        let leftMargin: CGFloat = 15
        let maxWidth: CGFloat = self._contentView.bounds.width - leftMargin * 2
        
        let withoutNewTipsIdealSize: CGSize = self._withoutNewTipsTextField.sizeThatFits(CGSize.init(width: maxWidth, height: 0))
        self._withoutNewTipsTextField.frame = CGRect.init(x: leftMargin, y: floor((self._contentView.bounds.height - withoutNewTipsIdealSize.height) / 2), width: maxWidth, height: withoutNewTipsIdealSize.height)
        
        let errorTipsIdealSize: CGSize = self._errorTipsTextField.sizeThatFits(CGSize.init(width: maxWidth, height: 0))
        self._errorTipsTextField.frame = CGRect.init(x: leftMargin, y: floor((self._contentView.bounds.height - errorTipsIdealSize.height) / 2), width: maxWidth, height: errorTipsIdealSize.height)
        
        let newVersionTitleIdealSize: CGSize = self._newVersionTitleTextField.sizeThatFits(CGSize.init(width: maxWidth, height: 0))
        let newVersionContentIdealSize: CGRect = self._newVersionContentTextView.attributedString().boundingRect(with: CGSize.init(width: maxWidth, height: 0), options: [NSString.DrawingOptions.usesLineFragmentOrigin, NSString.DrawingOptions.usesFontLeading])
        let marginBetween: CGFloat = 10
        let marginTop: CGFloat = floor((self._contentView.bounds.height - newVersionTitleIdealSize.height - newVersionContentIdealSize.height - marginBetween) / 2)
        
        self._newVersionContentTextView.frame = CGRect.init(x: leftMargin, y: marginTop, width: maxWidth, height: newVersionContentIdealSize.height)
        self._newVersionTitleTextField.frame = CGRect.init(x: leftMargin + 4, y: self._newVersionContentTextView.frame.maxY + marginBetween, width: maxWidth, height: newVersionTitleIdealSize.height)
    }
}
