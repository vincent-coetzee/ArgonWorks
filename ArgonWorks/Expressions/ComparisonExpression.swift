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
        if self.methodInstance.isNil
            {
            print("\(indent)SELECTED INSTANCE - NONE")
            }
        else
            {
            print("\(indent)SELECTED INSTANCE \(self.methodInstance!.displayString)")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ComparisonExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        if let methods = self.enclosingScope.lookupN(label: operation.rawValue)
            {
            if let selectedMethod = methods.filter({$0 is InfixOperator}).first as? InfixOperator
                {
                self.method = selectedMethod
                }
            else
                {
                self.appendIssue(at: self.declaration!, message: "The operator \(self.operation) of the correct type can not be resolved.")
                }
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The operator \(self.operation) can not be resolved.")
            }
        self.type = context.booleanType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        if let method = self.method
            {
            context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
            context.append(TypeConstraint(left: self.type,right: context.booleanType,origin: .expression(self)))
            let methodMatcher = MethodInstanceMatcher(method: method, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
            methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
            methodMatcher.appendTypeConstraint(lhs: self.lhs.type,rhs: self.rhs.type)
            methodMatcher.appendTypeConstraint(lhs: self.type,rhs: context.booleanType)
            methodMatcher.appendReturnType(context.booleanType)
            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
                {
                self.methodInstance = specificInstance
                print("FOUND MOST SPECIFIC INSTANCE = \(specificInstance.displayString)")
                context.append(TypeConstraint(left: self.type,right: self.methodInstance!.returnType,origin: .expression(self)))
                for (argument,parameter) in zip([self.lhs,self.rhs],self.methodInstance!.parameters)
                    {
                    context.append(TypeConstraint(left: argument.type,right: parameter.type,origin: .expression(self)))
                    }
                context.append(TypeConstraint(left: self.methodInstance!.returnType,right: context.booleanType,origin: .expression(self)))
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
