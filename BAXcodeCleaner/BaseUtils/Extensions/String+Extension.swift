//
//  String+Extension.swift
//  MorseCodec
//
//  Created by BenArvin on 2019/12/23.
//  Copyright © 2019 BenArvin. All rights reserved.
//

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
}
