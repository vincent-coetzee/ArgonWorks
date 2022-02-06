//
//  RoleExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import Foundation

public class CastExpression: Expression
    {
    public override var displayString: String
        {
        return("CAST(\(self.expression.displayString),\(self.type.displayString)")
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

    init(expression: Expression,type: Type)
        {
        self.expression = expression
        super.init()
        self.type = type
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = CastExpression(expression: substitution.substitute(self.expression),type: substitution.substitute(self.type))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        return(expression as! Self)
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
        self.type.initializeType(inContext: context)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.expression.initializeTypeConstraints(inContext: context)
        self.type.initializeTypeConstraints(inContext: context)
        context.append(SubTypeConstraint(subtype: self.expression.type,supertype: self.type,origin:.expression(self)))
        if !self.expression.type.isSubtype(of: self.type)
            {
            self.appendIssue(at: self.declaration!, message: "'\(self.expression.type.userString)' does not inherit from '\(self.type.userString)' so the cast will fail.")
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public override func emitCode(into instance: InstructionBuffer, using generator: CodeGenerator) throws
        {
        try self.expression.emitCode(into: instance,using: generator)
        let temp = instance.nextTemporary
        let typeClass = self.type as! TypeClass
        instance.add(.CAST,self.expression.place,.address(typeClass.memoryAddress),temp)
        self._place = temp
        }
    }
