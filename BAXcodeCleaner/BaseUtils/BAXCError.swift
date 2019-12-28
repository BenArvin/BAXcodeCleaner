//
//  BAXCError.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/28.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Foundation

public enum BAXCError: Error {
    public enum RemovePathFailedReason {
        case unknown(path: String?)
    }
    case removePathFailed(reason: RemovePathFailedReason)
}

extension BAXCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .removePathFailed:
            return "Request explicitly cancelled."
        }
    }
}
