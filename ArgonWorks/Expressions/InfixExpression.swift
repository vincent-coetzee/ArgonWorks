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
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = self.operators.first!.returnType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {

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
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operators.first!.label)' ) can not be resolved. Try making it more specific.")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = InfixExpression(operatorLabel: self.operatorLabel,operators: self.operators,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        let types = [expression.lhs.type,expression.rhs.type]
        let newOperators = self.operators.map{substitution.substitute($0)}
        let sorted = newOperators.filter{$0.parameterTypesAreSupertypes(ofTypes: types)}.sorted{$0.moreSpecific(than: $1, forTypes: types)}
        expression.methodInstance = sorted.first
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitAddressCode(into: instance, using: generator)
        try self.rhs.emitAddressCode(into: instance, using: generator)
        instance.add(.PUSH,self.lhs.place)
        instance.add(.PUSH,self.rhs.place)
        if self.methodInstance.isNil
            {
            let label = "#" + self.operatorLabel
            let symbol = Argon.Integer(generator.payload.symbolRegistry.registerSymbol(label))
            instance.add(.SEND,.integer(symbol),.register(.RR))
            }
        else
            {
            assert(self.methodInstance!.memoryAddress != 0)
            instance.add(.CALL,.address(self.methodInstance!.memoryAddress))
            }
        self._place = .register(.RR)
        }
    }

