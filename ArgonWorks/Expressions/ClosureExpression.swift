//
//  ClosureExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class ClosureExpression: Expression
    {
    public var closure: Closure?
    public var closureSlot: Slot?
    public var arguments: Arguments
    
    public init(closure:Closure)
        {
        self.closure = closure
        self.closureSlot = nil
        self.arguments = []
        super.init()
        }
        
    public init(slot:Slot,arguments: Arguments)
        {
        self.closure = nil
        self.closureSlot = slot
        self.arguments = arguments
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.closure = coder.decodeObject(forKey: "closure") as? Closure
        self.closureSlot = coder.decodeObject(forKey: "closureSlot") as? Slot
        self.arguments = coder.decodeArguments(forKey: "arguments")
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.closure,forKey: "closure")
        coder.encode(self.closureSlot,forKey: "closureSlot")
        coder.encodeArguments(self.arguments,forKey: "arguments")
        super.encode(with: coder)
        }

    public override func visit(visitor: Visitor) throws
        {
        try self.closure?.visit(visitor: visitor)
        try self.closureSlot?.visit(visitor: visitor)
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        self.closure?.allocateAddresses(using: allocator)
        self.closureSlot?.allocateAddresses(using: allocator)
        self.arguments.allocateAddresses(using: allocator)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        self.closure?.analyzeSemantics(using: analyzer)
        self.closureSlot?.analyzeSemantics(using: analyzer)
        self.arguments.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        try self.closure?.emitCode(into: instance,using: using)
        try self.closureSlot?.emitCode(into: instance,using: using)
        }
    }
