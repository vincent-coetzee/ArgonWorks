//
//  MemorySlotCellView.swift
//  MemorySlotCellView
//
//  Created by Vincent Coetzee on 20/8/21.
//

import Cocoa

class MemorySlotCellView: NSTableCellView
    {
    private static let cellFont = NSFont(name:"Menlo",size:12)!
    
    public var memorySlotItem: MemorySlotItem? = nil
        {
        didSet
            {
            self.update()
            }
        }
        
    private func update()
        {
        self.textField?.attributedStringValue = self.memorySlotItem!.line
        self.textField?.font = Self.cellFont
        }
    }
