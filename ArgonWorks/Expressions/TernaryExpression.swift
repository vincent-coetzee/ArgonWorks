//
//  TernaryExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/2/22.
//

import Foundation

public class TernaryExpression: Expression
    {
    private let lhs: Expression
    private let rhs: Expression
    private let mhs: Expression
    
    init(lhs: Expression,mhs: Expression,rhs: Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        self.mhs = mhs
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        self.mhs = coder.decodeObject(forKey: "mhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.mhs,forKey: "mhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let new = TernaryExpression(lhs: self.lhs.freshTypeVariable(inContext: context),mhs: self.mhs.freshTypeVariable(inContext: context),rhs: self.rhs.freshTypeVariable(inContext: context))
        new.type = self.type.freshTypeVariable(inContext: context)
        new.locations = self.locations
        return(new as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.mhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = self.mhs.type
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = TernaryExpression(lhs: substitution.substitute(self.lhs),mhs: substitution.substitute(self.mhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)TERNARY EXPRESSION")
        print("\(indent)ARGUMENTS:")
        self.lhs.display(indent: indent + "\t")
        self.mhs.display(indent: indent + "\t")
        self.rhs.display(indent: indent + "\t")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.mhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: ArgonModule.shared.boolean,right: self.lhs.type,origin: .expression(self)))
        context.append(TypeConstraint(left: self.mhs.type,right: self.rhs.type,origin: .expression(self)))
        }
        
    public override func assign(from expression: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.mhs.visit(visitor: visitor)
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
        let label = buffer.nextLabel
        let endLabel = buffer.nextLabel
        let temporary = buffer.nextTemporary
        buffer.add(.BRF,self.lhs.place,label.operand)
        try self.mhs.emitValueCode(into: buffer,using: generator)
        buffer.add(.MOVE,self.mhs.place,temporary)
        buffer.add(.BR,endLabel.operand)
        buffer.pendingLabel = label
        try self.rhs.emitValueCode(into: buffer,using: generator)
        buffer.add(.MOVE,self.rhs.place,temporary)
        buffer.pendingLabel = endLabel
        self._place = temporary
        }
    }
