//
//  Elseblock.swift
//  Elseblock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ElseBlock: Block
    {
    public override var displayString: String
        {
        "Else\n" + self.blocks.displayString
        }
        
    public override func display(indent: String)
        {
        print("\(indent)ELSE \(Swift.type(of: self))")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        }
    }

public class ElseIfBlock: IfBlock
    {
    public override func display(indent: String)
        {
        print("\(indent)ELSEIF \(Swift.type(of: self))")
        print("\(indent)CONDITION: \(self.condition.type.displayString)")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.condition.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        context.append(TypeConstraint(left: self.condition.type,right: context.booleanType,origin: .block(self)))
        }
    }
