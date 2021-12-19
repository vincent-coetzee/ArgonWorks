//
//  VirtualReadBlock.swift
//  VirtualReadBlock
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class VirtualReadBlock: Block,Scope,BlockContext
    {
    public override var hasInlineReturnBlock: Bool
        {
        return(false)
        }
        
    internal var slot: Slot!
    
    required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as? Slot
        super.init(coder: coder)
        }
    
    required init()
        {
        super.init()
        }
    
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.slot,forKey:"slot")
        super.encode(with: coder)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = VirtualReadBlock()
        block.slot = substitution.substitute(self.slot)
        block.slot.type = substitution.substitute(self.slot.type!)
        for aBlock in self.blocks
            {
            block.addBlock(substitution.substitute(aBlock))
            }
        block.type = substitution.substitute(self.type!)
        return(block as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = VirtualReadBlock()
        block.slot = self.slot.freshTypeVariable(inContext: context)
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type?.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.slot.initializeType(inContext: context)
        self.type = self.slot.type
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
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
    
    required init?(coder: NSCoder)
        {
        self.newValueSlot = coder.decodeObject(forKey: "newValueSlot") as? Slot
        super.init(coder: coder)
        }
    
    required init()
        {
        super.init()
        }
    
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.newValueSlot,forKey:"newValueSlot")
        super.encode(with: coder)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.slot.initializeType(inContext: context)
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        self.newValueSlot.initializeType(inContext: context)
        self.type = self.slot.type
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = VirtualWriteBlock()
        block.slot = self.slot.freshTypeVariable(inContext: context)
        block.newValueSlot = self.newValueSlot.freshTypeVariable(inContext: context)
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type?.freshTypeVariable(inContext: context)
        return(block as! Self)
        }

    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = VirtualWriteBlock()
        block.slot = substitution.substitute(self.slot)
        block.slot.type = substitution.substitute(self.slot.type!)
        for aBlock in self.blocks
            {
            block.addBlock(substitution.substitute(aBlock))
            }
        block.type = substitution.substitute(self.type!)
        block.newValueSlot = substitution.substitute(self.newValueSlot)
        block.newValueSlot.type = substitution.substitute(self.newValueSlot.type!)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.slot.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        self.newValueSlot.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.type,right: self.slot.type,origin: .block(self)))
        }
    }
