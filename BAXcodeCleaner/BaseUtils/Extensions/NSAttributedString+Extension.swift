//
//  NSAttributedString+Extension.swift
//  BAXcodeCleaner
//
//  Created by arvinnie on 2020/12/12.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Cocoa

extension NSAttributedString {
    public func mc_sizeThatFits(maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        return self.boundingRect(with: CGSize.init(width: maxWidth, height: maxHeight), options: [NSString.DrawingOptions.usesLineFragmentOrigin, NSString.DrawingOptions.usesFontLeading], context: nil).size
    }
}
