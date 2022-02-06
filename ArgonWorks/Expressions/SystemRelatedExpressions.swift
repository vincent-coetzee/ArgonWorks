//
//  SystemRelatedExpressions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/12/21.
//

import Foundation

public class ClassExpression: Expression
    {
    public override var displayString: String
        {
        return("CLASS(\(self.expression.displayString),\(self.type.displayString)")
        }

    private let expression: Expression

    required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expression,forKey:"expression")
        }

    init(expression: Expression)
        {
        self.expression = expression
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.expression.visit(visitor: visitor)
        try self.type.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.expression.initializeType(inContext: context)
        self.type = ArgonModule.shared.classType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.expression.initializeTypeConstraints(inContext: context)
        self.type.initializeTypeConstraints(inContext: context)
        }
        
    public override func emitValueCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.expression.emitAddressCode(into: buffer, using: using)
        buffer.add(.CLASS,self.expression.place,.register(.RR))
        self._place = .register(.RR)
        }
    }
