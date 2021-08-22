//
//  VirtualSlot.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation
import AppKit

public class VirtualSlot:Slot
    {
    public var readBlock: VirtualReadBlock?
    public var writeBlock: VirtualWriteBlock?
    
    public override var typeCode:TypeCode
        {
        .virtualSlot
        }
        
    public override var cloned: Slot
        {
        let newSlot = VirtualSlot(label: self.label,type:self.type)
        newSlot.setOffset(self.offset)
        newSlot.setParent(self.parent)
        newSlot.getter = self.getter
        newSlot.setter = self.setter
        return(newSlot)
        }
        
    public override var symbolColor: NSColor
        {
        .argonPurple
        }
        
    public override var isVirtual: Bool
        {
        return(true)
        }
        
    public override var size:Int
        {
        return(MemoryLayout<Word>.size * 2)
        }
        
    private var getter:InnerFunctionPointer?
    private var setter:InnerFunctionPointer?
    }
