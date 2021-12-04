//
//  InfixExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class InfixExpression: OperatorExpression
    {
    private let lhs: Expression
    private let rhs: Expression
    private var methodInstance: MethodInstance?
    
    init(operation: Operator,lhs: Expression,rhs:Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init(operation: operation)
        self.lhs.setParent(self)
        self.rhs.setParent(self)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE INFIX EXPRESSION")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE INFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        self.type = self.operation.returnType
        }
        
    public override func display(indent: String)
        {
        print("\(indent)INFIX EXPRESSION: \(self.operation.label)")
        print("\(indent)LHS:")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS:")
        self.rhs.display(indent: indent + "\t")
        if self.methodInstance.isNil
            {
            print("\(indent)SELECTED INSTANCE - NONE")
            }
        else
            {
            print("\(indent)SELECTED INSTANCE \(self.methodInstance.displayString)")
            }
        }
    
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        print("INFIX EXPRESSION")
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        let methodMatcher = MethodInstanceMatcher(method: self.operation, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
        methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
        methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
        methodMatcher.appendReturnType(self.type!)
        if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
            {
            self.methodInstance = specificInstance
            print("FOUND MOST SPECIFIC INSTANCE FOR \(self.operation.label) = \(specificInstance.displayString)")
            methodMatcher.appendTypeConstraints(for: specificInstance, argumentTypes: [self.lhs.type!], returnType: self.type!, to: context)
            }
        else
            {
            print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE FOR \(self.operation.label)")
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operation.label)' ) can not be resolved. Try making it more specific.")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = InfixExpression(operation: self.operation,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        return(expression as! Self)
        }
    }

