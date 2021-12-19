//
//  PostfixExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class PostfixExpression: OperatorExpression
    {
    private let lhs: Expression
    
    init(operatorLabel: Label,operators: MethodInstances,lhs: Expression)
        {
        self.lhs = lhs
        super.init(operatorLabel: operatorLabel,operators: operators)
        self.lhs.setParent(self)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE POSTFX EXPRESSION")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE POSTFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        super.encode(with: coder)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = PostfixExpression(operatorLabel: self.operatorLabel,operators: self.operators, lhs: substitution.substitute(self.lhs))
        expression.type = substitution.substitute(self.type!)
        expression.methodInstance = substitution.substitute(self.methodInstance)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = PostfixExpression(operatorLabel: self.operatorLabel,operators: self.operators,lhs: self.lhs.freshTypeVariable(inContext: context))
        expression.type = self.type?.freshTypeVariable(inContext: context)
        expression.methodInstance = self.methodInstance?.freshTypeVariable(inContext: context)
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.type = self.lhs.type
        }

    public override func display(indent: String)
        {
        print("\(indent)POSTFIX EXPRESSION: \(self.operatorLabel)")
        print("\(indent)LHS:")
        self.lhs.display(indent: indent + "\t")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        context.append(SubTypeConstraint(subtype: self.lhs.type,supertype: context.integerType,origin:.expression(self)))
        let methodMatcher = MethodInstanceMatcher(methodInstances: self.operators, argumentExpressions: [self.lhs], reportErrors: true)
        methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
        methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
        methodMatcher.appendReturnType(context.voidType)
        if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
            {
            self.methodInstance = specificInstance
            print("FOUND MOST SPECIFIC INSTANCE = \(specificInstance.displayString)")
            methodMatcher.appendTypeConstraints(to: context)
            }
        else
            {
            print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE")
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operatorLabel)' ) can not be resolved. Try making it more specific.")
            }
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }
