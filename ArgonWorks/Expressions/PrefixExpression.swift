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
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = PrefixExpression(operatorLabel: self.operatorLabel,operators: self.operators,rhs: self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.methodInstance = self.methodInstance?.freshTypeVariable(inContext: context)
        return(expression as! Self)
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
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.rhs.initializeType(inContext: context)
        self.type = self.operators.first!.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = PrefixExpression(operatorLabel: self.operatorLabel,operators: self.operators,rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        let types = [expression.rhs.type,expression.rhs.type]
        let newOperators = self.operators.map{substitution.substitute($0)}
        let sorted = newOperators.filter{$0.parameterTypesAreSupertypes(ofTypes: types)}.sorted{$0.moreSpecific(than: $1, forTypes: types)}
        expression.methodInstance = sorted.first
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .expression(self)))
        }
        
    public override func emitCode(into buffer: InstructionBuffer, using generator: CodeGenerator) throws
        {
        try self.rhs.emitPointerCode(into: buffer, using: generator)
        buffer.add(.PUSH,self.rhs.place)
        if let instance = self.methodInstance
            {
            generator.registerMethodInstanceIfNeeded(instance)
            assert(instance.memoryAddress != 0)
            buffer.add(.CALL,.address(instance.memoryAddress))
            }
        else
            {
            let symbol = Argon.Integer(generator.payload.symbolRegistry.registerSymbol("#" + self.operatorLabel))
            buffer.add(.SEND,.integer(symbol),.register(.RR))
            }
        buffer.add(.POPN,.integer(Argon.Integer(Argon.kWordSizeInBytesWord)))
        self._place = .register(.RR)
        }
    }

