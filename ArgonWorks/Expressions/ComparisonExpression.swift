//
//  ComparisonExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 3/12/21.
//

import Foundation

public class ComparisonExpression: BinaryExpression
    {
    public override func display(indent: String)
        {
        print("\(indent)COMPARISON EXPRESSION: \(self.operation)")
        print("\(indent)LHS: \(self.lhs.type.displayString)")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS: \(self.rhs.type.displayString)")
        self.rhs.display(indent: indent + "\t")
        if self.selectedMethodInstance.isNil
            {
            print("\(indent)SELECTED INSTANCE - NONE")
            }
        else
            {
            print("\(indent)SELECTED INSTANCE \(self.selectedMethodInstance!.displayString)")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ComparisonExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        expression.selectedMethodInstance = self.selectedMethodInstance
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try super.initializeType(inContext: context)
        self.type = context.booleanType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        if !self.methodInstances.isEmpty
            {
            let methodMatcher = MethodInstanceMatcher(methodInstances: self.methodInstances, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
            methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
            methodMatcher.appendTypeConstraint(lhs: self.lhs.type,rhs: self.rhs.type)
            methodMatcher.appendTypeConstraint(lhs: self.type,rhs: context.booleanType)
            methodMatcher.appendReturnType(context.booleanType)
            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
                {
                self.selectedMethodInstance = specificInstance
                print("FOUND MOST SPECIFIC INSTANCE = \(specificInstance.displayString)")
                }
            else
                {
                print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE")
                self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operation.rawValue)' ) can not be resolved. Try making it more specific.")
                }
            }
        }
        
    public override func defineLocalSymbols(inContext: TypeContext)
        {
        self.lhs.defineLocalSymbols(inContext:inContext)
        self.rhs.defineLocalSymbols(inContext:inContext)
        }
    }
