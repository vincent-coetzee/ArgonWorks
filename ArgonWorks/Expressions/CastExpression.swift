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

    init(lhs: Expression,rhs: Type)
        {
        self.expression = lhs
        super.init()
        self.type = rhs
        }
        
    public override func display(indent: String)
        {
        print("\(indent)TYPE CAST EXPRESSION")
        print("\(indent)ARGUMENTS:")
        self.expression.display(indent: indent + "\t")
        self.type.display(indent: indent + "\t")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = CastExpression(lhs: substitution.substitute(self.expression),rhs: substitution.substitute(self.type))
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
        context.append(TypeConstraint(left: self.expression.type,right: self.type,origin:.expression(self)))
        if !self.expression.type.isSubtype(of: self.type)
            {
            self.appendIssue(at: self.declaration!, message: "'\(self.expression.type.userString)' does not inherit from '\(self.type.userString)' so the cast will fail.")
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.expression.emitValueCode(into: into,using: using)
        let leftType = self.expression.type
        let temporary = into.nextTemporary
        if !leftType.isClass
            {
            into.add(.DYNCAST,self.expression.place,.address(self.type.memoryAddress))
            }
        else if (leftType as! TypeClass).isSubclass(of: self.type as! TypeClass)
            {
            let classes = (leftType as! TypeClass).allSuperclasses
            let lowerIndex = classes.firstIndex(of: leftType as! TypeClass)!
            let upperIndex = classes.firstIndex(of: self.type as! TypeClass)!
            let delta = (upperIndex - lowerIndex) * 4 * Argon.kWordSizeInBytesInt
            into.add(.SUB,self.expression.place,.integer(delta),temporary)
            }
        else if (self.type as! TypeClass).isSubclass(of: leftType as! TypeClass)
            {
            let classes = (leftType as! TypeClass).allSuperclasses
            let upperIndex = classes.firstIndex(of: leftType as! TypeClass)!
            let lowerIndex = classes.firstIndex(of: self.type as! TypeClass)!
            let delta = (upperIndex - lowerIndex) * 4 * Argon.kWordSizeInBytesInt
            into.add(.ADD,self.expression.place,.integer(delta),temporary)
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "It is not valid to cast from \(leftType.label) to \(self.type.label).")
            }
        self._place = temporary
        }
        
    public override func emitCode(into instance: InstructionBuffer, using generator: CodeGenerator) throws
        {
        try self.emitValueCode(into: instance,using: generator)
        }
    }
