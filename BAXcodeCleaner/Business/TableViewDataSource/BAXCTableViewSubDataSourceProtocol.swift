//
//  BAXCTableViewSubDataSourceProtocol.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2019/12/31.
//  Copyright © 2019 BenArvin. All rights reserved.
//

import Cocoa

public protocol BAXCTableViewSubDataSourceProtocol: class {
    func numberOfRows() -> Int
    func height(for row: Int) -> CGFloat
    func cell(for row: Int, column: Int) -> NSTableCellView?
    func setContent(for cell: NSTableCellView, row: Int, column: Int)
    func refresh()
    func selectAll()
    func unselectAll()
    func clean()
}
