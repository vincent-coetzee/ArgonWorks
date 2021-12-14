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
        
    public var value: Expression = Expression()
        
    public init(expression: Expression)
        {
        self.value = expression
        super.init()
        self.value.setParent(self)
        }
    
    public required init?(coder: NSCoder)
        {
        self.value = coder.decodeObject(forKey: "value") as! Expression
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
        self.value.display(indent: indent + "\t")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.value.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = ReturnBlock(expression: substitution.substitute(self.value))
        block.type = substitution.substitute(self.type!)
        return(block as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.value.initializeType(inContext: context)
        assert(self.value.type.isNotNil)
        self.type = self.value.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.value.initializeTypeConstraints(inContext: context)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        try self.value.emitCode(into: buffer,using: generator)
        buffer.append(nil,"MOV",self.value.place,.none,.returnRegister)
        }
    }
