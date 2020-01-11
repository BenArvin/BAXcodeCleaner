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
    
    func isAllSelected() -> Bool
    func isNoneSelected() -> Bool
    func selectAll()
    func unselectAll()
    func onSelected(closure: @escaping () -> ())
    func onSectionSelected(closure: @escaping () -> ())
    
    func cleanCheck() -> String?
    func clean()
    
    func contentForCopy(at row: Int) -> String?
    func pathForOpen(at row: Int) -> String?
    
    func totalSize() -> Int
    func selectedSize() -> Int
}
