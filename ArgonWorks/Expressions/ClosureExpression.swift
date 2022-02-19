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
    
    public init(closure:Closure)
        {
        self.closure = closure
        self.closureSlot = nil
        super.init()
        }
        
    public init(slot:Slot,arguments: Arguments)
        {
        self.closure = nil
        self.closureSlot = slot
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.closure = coder.decodeObject(forKey: "closure") as? Closure
        self.closureSlot = coder.decodeObject(forKey: "closureSlot") as? Slot
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.closure,forKey: "closure")
        coder.encode(self.closureSlot,forKey: "closureSlot")
        super.encode(with: coder)
        }

    public override func visit(visitor: Visitor) throws
        {
        try self.closure?.visit(visitor: visitor)
        try self.closureSlot?.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func emitPointerCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        guard let closure = self.closure else
            {
            fatalError("Closure in closure expression is nil.")
            }
        try closure.emitCode(into: buffer,using: generator)
        self._place = .address(closure.memoryAddress)
        }
        
    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.emitPointerCode(into: into,using: using)
        }
        
   public override func display(indent: String)
        {
        print("\(indent)CLOSURE EXPRESSION: \(self.type.displayString)")
        self.closure!.display(indent: indent + "\t")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ClosureExpression(closure: substitution.substitute(self.closure!))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.closure!.initializeType(inContext: context)
        self.type = self.closure!.returnType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.closure!.initializeTypeConstraints(inContext: context)
        }
        
    public override func allocateAddresses(using allocator:AddressAllocator) throws
        {
        self.closure?.allocateAddresses(using: allocator)
        self.closureSlot?.allocateAddresses(using: allocator)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        self.closure?.analyzeSemantics(using: analyzer)
        self.closureSlot?.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.closure?.emitCode(into: instance,using: using)
        try self.closureSlot?.emitCode(into: instance,using: using)
        }
    }
