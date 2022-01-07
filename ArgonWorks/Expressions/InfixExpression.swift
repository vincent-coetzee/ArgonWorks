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
    
    public init(operatorLabel: Label,operators: MethodInstances,lhs: Expression,rhs: Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init(operatorLabel: operatorLabel,operators:  operators)
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operatorLabel) \(self.rhs.displayString)")
        }
        
    required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = InfixExpression(operatorLabel: self.operatorLabel,operators: self.operators,lhs: self.lhs.freshTypeVariable(inContext: context),rhs: self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.methodInstance = self.methodInstance?.freshTypeVariable(inContext: context)
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = self.operators.first!.returnType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        print("INFIX EXPRESSION")
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        let newArguments = [self.lhs,self.rhs]
        let methodMatcher = MethodInstanceMatcher(typeContext: context,methodInstances: self.operators, argumentExpressions: newArguments, reportErrors: true)
        methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
        methodMatcher.appendReturnType(self.type)
        if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
            {
            self.methodInstance = specificInstance
            assert(self.methodInstance.isNotNil,"Original method instance is nil and should not be.")
            print("FOUND MOST SPECIFIC INSTANCE FOR \(self.operators.first!.label) = \(specificInstance.displayString)")
            }
        else
            {
            print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE FOR \(self.operators.first!.label)")
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operators.first!.label)' ) can not be resolved. Try making it more specific.")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = InfixExpression(operatorLabel: self.operatorLabel,operators: self.operators,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitPointerCode(into: instance, using: generator)
        try self.rhs.emitPointerCode(into: instance, using: generator)
        instance.append(.PUSH,self.lhs.place)
        instance.append(.PUSH,self.rhs.place)
        if self.methodInstance.isNil
            {
            let address = generator.emitStaticString(self.operatorLabel)
            instance.append(.CALLD,.address(address))
            }
        else
            {
            instance.append(.CALL,.address(self.methodInstance!.memoryAddress))
            }
        }
    }

