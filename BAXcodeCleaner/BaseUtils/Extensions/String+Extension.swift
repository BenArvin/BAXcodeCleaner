//
//  String+Extension.swift
//  MorseCodec
//
//  Created by BenArvin on 2019/12/23.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

extension String {
    public func mc_sub(from: Int, to: Int) -> String? {
        if from >= to || from >= self.count {
            return nil
        }
        let fromTmp = from < 0 ? 0 : from
        let toTmp = to > self.count ? self.count : to
        let result = self[self.index(self.startIndex, offsetBy: fromTmp)..<self.index(self.startIndex, offsetBy: toTmp)]
        return String(result)
    }
    
    init(fromSize size: Int) {
        let size_d: Double = Double(size)
        if size_d < 1024.0 {
            self = String.init(format: "%ldByte", size)
        } else if size_d < 1024.0 * 1024.0 {
            self = String.init(format: "%.1fKB", size_d / 1024.0)
        } else if size_d < 1024.0 * 1024.0 * 1024.0 {
            self = String.init(format: "%.1fMB", size_d / 1024.0 / 1024.0)
        } else {
            self = String.init(format: "%.1fGB", size_d / 1024.0 / 1024.0 / 1024.0)
        }
    }
    
    public func mc_sizeThatFits(font: NSFont, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let attrStr: NSAttributedString = NSAttributedString.init(string: self, attributes: [NSAttributedString.Key.font: font])
        return attrStr.mc_sizeThatFits(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}
