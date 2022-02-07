//
//  ReturnBlock.swift
//  ReturnBlock
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class ReturnBlock: Block
    {
    public override var returnBlocks: Array<ReturnBlock>
        {
        [self]
        }
        
    public override var hasInlineReturnBlock: Bool
        {
        return(true)
        }
        
    public override var isReturnBlock: Bool
        {
        return(true)
        }
        
    public var value: Expression?
        
    public init(expression: Expression?)
        {
        self.value = expression
        super.init()
        }
    
    public required init?(coder: NSCoder)
        {
        self.value = coder.decodeObject(forKey: "value") as? Expression
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.value = Expression()
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.value,forKey: "value")
        super.encode(with:coder)
        }
    
    public override func display(indent: String)
        {
        print("\(indent)RETURN: \(Swift.type(of: self))")
        if self.value.isNotNil
            {
            self.value!.display(indent: indent + "\t")
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.value?.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = super.substitute(from: substitution)
        newBlock.value = self.value.isNil ? nil : substitution.substitute(self.value!)
        newBlock.type = substitution.substitute(self.type)
        return(newBlock)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.value?.initializeType(inContext: context)
        self.type = self.value.isNotNil ? self.value!.type : ArgonModule.shared.void
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.value?.initializeTypeConstraints(inContext: context)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = ReturnBlock(expression: self.value?.freshTypeVariable(inContext: context))
        block.type = self.type.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.value?.emitValueCode(into: buffer,using: generator)
        if self.value.isNotNil
            {
            buffer.add(.MOVE,self.value!.place,.register(.RR))
            }
        buffer.add(.RET)
        }
    }
