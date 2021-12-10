//
//  PrefixExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class PrefixExpression: OperatorExpression
    {
    private let rhs: Expression
    
    init(operatorLabel:Label,operators: MethodInstances,rhs: Expression)
        {
        self.rhs = rhs
        super.init(operatorLabel: operatorLabel,operators: operators)
        self.rhs.setParent(self)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE PREFIX EXPRESSION")
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE INFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)PREFIX EXPRESSION: \(self.operatorLabel)")
        print("\(indent)RHS:")
        self.rhs.display(indent: indent + "\t")
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.rhs.initializeType(inContext: context)
        self.type = self.operators.first!.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = PrefixExpression(operatorLabel: self.operatorLabel,operators: self.operators,rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        expression.selectedMethodInstance = self.selectedMethodInstance?.substitute(from: substitution)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.rhs.initializeTypeConstraints(inContext: context)
        let methodMatcher = MethodInstanceMatcher(methodInstances: self.operators, argumentExpressions: [self.rhs], reportErrors: true)
        methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
        methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
        methodMatcher.appendReturnType(self.type!)
        if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
            {
            self.selectedMethodInstance = specificInstance
            print("FOUND MOST SPECIFIC INSTANCE = \(specificInstance.displayString)")
            methodMatcher.appendTypeConstraints(to: context)
            }
        else
            {
            print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE")
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operatorLabel)' ) can not be resolved. Try making it more specific.")
            }
        }
    }

