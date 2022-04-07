//
//  TypeTestingExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/2/22.
//

import Foundation

public class TypeTestingExpression: Expression
    {
    private let lhs: Expression
    private let rhs: Type
    
    init(lhs: Expression,rhs: Type)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init()
        self.lhs.container = .expression(self)
        self.rhs.container = .expression(self)
        }
        
    public required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.rhs = coder.decodeObject(forKey: "rhs") as! Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let new = TypeTestingExpression(lhs: self.lhs.freshTypeVariable(inContext: context),rhs: self.rhs.freshTypeVariable(inContext: context))
        new.type = self.type.freshTypeVariable(inContext: context)
        new.locations = self.locations
        return(new as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = context.booleanType
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = TypeTestingExpression(lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)TYPE TESTING EXPRESSION")
        print("\(indent)ARGUMENTS:")
        self.lhs.display(indent: indent + "\t")
        self.rhs.display(indent: indent + "\t")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: context.booleanType,right: self.type,origin: .expression(self)))
        context.append(TypeConstraint(left: self.rhs.type.type,right: context.metaclassType,origin: .expression(self)))
        }
        
    public override func assign(from expression: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.emitCode(into: into,using: using)
        }
        
    public override func emitCode(into buffer: InstructionBuffer, using generator: CodeGenerator) throws
        {
        try self.lhs.emitValueCode(into: buffer,using: generator)
        let temporary = buffer.nextTemporary
        buffer.add(.LOADP,self.lhs.place,.integer(Argon.kWordSizeInBytesInt),temporary)
        
        }
    }
