//
//  SlotInvocationExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/12/21.
//

import Foundation

public class SlotInvocationExpression: Expression
    {
    public override var displayString: String
        {
        return("SLOT(\(self.slot.displayString))")
        }

    private let slot: Slot
    private let arguments: Arguments

    required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        self.arguments = coder.decodeArguments(forKey: "arguments")
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        coder.encodeArguments(self.arguments,forKey:"arguments")
        coder.encode(self.slot,forKey:"slot")
        super.encode(with: coder)
        }

    init(slot: Slot,arguments: Arguments)
        {
        self.slot = slot
        self.arguments = arguments
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.slot.visit(visitor: visitor)
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.slot.initializeType(inContext: context)
        for argument in self.arguments
            {
            argument.initializeType(inContext: context)
            }
        self.type = self.slot.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.slot.initializeTypeConstraints(inContext: context)
        for argument in self.arguments
            {
            argument.initializeTypeConstraints(inContext: context)
            }
        }
    }
