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
        self.closure!.setParent(self)
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
        
   public override func display(indent: String)
        {
        print("\(indent)CLOSURE EXPRESSION: \(self.type.displayString)")
        self.closure!.display(indent: indent + "\t")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ClosureExpression(closure: substitution.substitute(self.closure!))
        expression.type = substitution.substitute(self.type!)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.closure!.initializeType(inContext: context)
        let label = self.closure!.parameters.map{$0.type!.displayString}.joined(separator: "x") + "->" + self.closure!.returnType.displayString
        self.type = TypeFunction(label: label, types: self.closure!.parameters.map{$0.type!}, returnType: self.closure!.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.closure!.initializeTypeConstraints(inContext: context)
        }
        
    public override func allocateAddresses(using allocator:AddressAllocator) throws
        {
        try self.closure?.allocateAddresses(using: allocator)
        try self.closureSlot?.allocateAddresses(using: allocator)
        try self.arguments.allocateAddresses(using: allocator)
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
