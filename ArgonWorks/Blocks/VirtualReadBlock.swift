//
//  VirtualReadBlock.swift
//  VirtualReadBlock
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class VirtualReadBlock: Block,Scope
    {
    public var isMethodInstanceScope: Bool
        {
        false
        }
        
    public var isClosureScope: Bool
        {
        false
        }
        
    public var isInitializerScope: Bool
        {
        false
        }
        
    public var isSlotScope: Bool
        {
        true
        }
        
    public func addSymbol(_ symbol: Symbol)
        {
        self.addLocalSlot(symbol as! LocalSlot)
        }
    
    public func appendIssue(at: Location, message: String)
        {
        self.issues.append(CompilerIssue(location: at,message: message))
        }
    
    public func appendWarningIssue(at: Location, message: String)
        {
        self.issues.append(CompilerIssue(location: at,message: message,isWarning: true))
        }
    
    public override var enclosingScope: Scope
        {
        self.parent.enclosingScope
        }
        
    internal var slot: Slot!
    
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = VirtualWriteBlock()
        block.slot = self.slot.deepCopy()
        block.slot.type = substitution.substitute(self.slot.type)
        return(block as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.slot.initializeType(inContext: context)
        self.type = self.slot.type
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        let returnBlocks = self.returnBlocks.filter{$0.enclosingScope.isSlotScope}
        if returnBlocks.isEmpty
            {
            self.appendIssue(at: self.declaration!,message: "A virtual read block must have at least one RETURN block.")
            }
        else
            {
            for block in returnBlocks
                {
                context.append(TypeConstraint(left: self.type,right: block.type,origin: .block(self)))
                }
            }
        }
    }

public class VirtualWriteBlock: VirtualReadBlock
    {
    internal var newValueSlot: Slot!
    
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.slot.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = self.slot.type
        }

    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = VirtualWriteBlock()
        block.slot = self.slot.deepCopy()
        block.slot.type = substitution.substitute(self.slot.type)
        block.newValueSlot = self.newValueSlot.deepCopy()
        block.newValueSlot.type = substitution.substitute(self.newValueSlot.type)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        context.append(TypeConstraint(left: type,right: self.type,origin: .block(self)))
        }
    }
