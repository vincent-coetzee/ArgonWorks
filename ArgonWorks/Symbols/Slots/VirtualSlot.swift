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
//        newSlot.getter = self.getter
//        newSlot.setter = self.setter
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
        
//    private var getter:InnerFunctionPointer?
//    private var setter:InnerFunctionPointer?
    
    public override func initializeType(inContext context: TypeContext)
        {
        super.initializeType(inContext: context)
        self.readBlock?.initializeType(inContext: context)
        self.writeBlock?.initializeType(inContext: context)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        super.initializeTypeConstraints(inContext: context)
        self.readBlock?.initializeTypeConstraints(inContext: context)
        self.writeBlock?.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.type,right: self.readBlock!.type,origin: .symbol(self)))
        if self.writeBlock.isNotNil
            {
            context.append(TypeConstraint(left: self.type,right: self.writeBlock!.type,origin: .symbol(self)))
            context.append(TypeConstraint(left: self.readBlock!.type,right: self.writeBlock!.type,origin: .symbol(self)))
            }
        }
        
    public override func analyzeSemantics(using: SemanticAnalyzer)
        {
        self.readBlock?.analyzeSemantics(using: using)
        self.writeBlock?.analyzeSemantics(using: using)
        }
        
        
    public override func visit(visitor: Visitor) throws
        {
        try self.readBlock?.visit(visitor: visitor)
        try self.writeBlock?.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }
