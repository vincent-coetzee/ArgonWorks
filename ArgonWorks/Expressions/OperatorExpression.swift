//
//  OperatorExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class OperatorExpression: Expression
    {
    internal let operation: Operator
    
    init(operation: Operator)
        {
        self.operation = operation
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR EXPRESSION")
        self.operation = coder.decodeObject(forKey: "operation") as! Operator
        super.init(coder: coder)
//        print("END DECODE OPERATOR EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.operation,forKey: "operation")
        super.encode(with: coder)
        }
    }
    
public class InfixExpression: OperatorExpression
    {
    private let lhs: Expression
    private let rhs: Expression
    
    init(operation: Operator,lhs: Expression,rhs:Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init(operation: operation)
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
        self.type = self.lhs.type.freshTypeVariable(inContext: context)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)INFIX EXPRESSION: \(self.operation.label)")
        print("\(indent)LHS:")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS:")
        self.rhs.display(indent: indent + "\t")
        }
    
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        var specificInstance:MethodInstance?
        guard !self.operation.isEmpty else
            {
            return
            }
        try context.extended(withContentsOf: [])
            {
            newContext in
            let substitution = newContext.unify()
            let leftType = substitution.substitute(self.lhs.type)
            let rightType = substitution.substitute(self.rhs.type)
            if !leftType.isTypeVariable && !rightType.isTypeVariable
                {
                if let specific = self.operation.mostSpecificInstance(forTypes: [leftType,rightType])
                    {
                    specificInstance = specific
                    context.append(TypeConstraint(left: self.lhs.type,right: specific.parameters[0].type,origin: .expression(self)))
                    context.append(TypeConstraint(left: self.rhs.type,right: specific.parameters[1].type,origin: .expression(self)))
                    self.type = substitution.substitute(specific.returnType)
                    }
                }
            }
        guard specificInstance.isNil else
            {
            return
            }
        var inferredInstances = MethodInstances()
        for instance in operation.instances
            {
            try context.extended(withContentsOf: TaggedTypes())
                {
                newContext in
                let freshInstance = instance.freshTypeVariable(inContext: context)
                try freshInstance.initializeType(inContext: context)
                try freshInstance.initializeTypeConstraints(inContext: newContext)
                for (argument,parameter) in zip([self.lhs,self.rhs],freshInstance.parameters)
                    {
                    newContext.append(TypeConstraint(left: parameter.type,right: argument.type,origin: .expression(self)))
                    }
                let substitution = newContext.unify()
                let newInstance = substitution.substitute(freshInstance)
                inferredInstances.append(newInstance)
                }
            }
        inferredInstances = inferredInstances.filter{$0.isConcreteInstance}
        let types = [self.lhs.type,self.rhs.type]
        if let mostSpecificInstance = inferredInstances.sorted(by: {$0.moreSpecific(than: $1, forTypes: types)}).first
            {
            specificInstance = mostSpecificInstance
            self.type = specificInstance!.returnType
            for (argument,parameter) in zip([self.lhs,self.rhs],specificInstance!.parameters)
                {
                context.append(SubTypeConstraint(subtype: argument.type,supertype: parameter.type,origin: .expression(self)))
                }
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The most specific operator for this invocation can not be resolved. Trying making it more specific.")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        InfixExpression(operation: self.operation,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs)) as! Self
        }
    }

public class PrefixExpression: OperatorExpression
    {
    private let rhs: Expression
    
    init(operation: Operator,rhs: Expression)
        {
        self.rhs = rhs
        super.init(operation: operation)
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
        print("\(indent)PREFIX EXPRESSION: \(self.operation.label)")
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
        self.type = self.operation.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        PrefixExpression(operation: self.operation,rhs: substitution.substitute(self.rhs)) as! Self
        }
    }

public class PostfixExpression: OperatorExpression
    {
    private let lhs: Expression
    
    init(operation: Operator,lhs: Expression)
        {
        self.lhs = lhs
        super.init(operation: operation)
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
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.operation.initializeType(inContext: context)
        try self.lhs.initializeType(inContext: context)
        self.type = self.operation.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)POSTFIX EXPRESSION: \(self.operation.label)")
        print("\(indent)LHS:")
        self.lhs.display(indent: indent + "\t")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        var specificInstance:MethodInstance?
        guard !self.operation.isEmpty else
            {
            return
            }
        try context.extended(withContentsOf: [])
            {
            newContext in
            let substitution = newContext.unify()
            let leftType = substitution.substitute(self.lhs.type)
            if !leftType.isTypeVariable
                {
                if let specific = self.operation.mostSpecificInstance(forTypes: [leftType])
                    {
                    specificInstance = specific
                    context.append(TypeConstraint(left: self.lhs.type,right: specific.parameters[0].type,origin: .expression(self)))
                    self.type = substitution.substitute(specific.returnType)
                    }
                }
            }
        guard specificInstance.isNil else
            {
            return
            }
        var inferredInstances = MethodInstances()
        for instance in operation.instances
            {
            try context.extended(withContentsOf: TaggedTypes())
                {
                newContext in
                let freshInstance = instance.freshTypeVariable(inContext: context)
                try freshInstance.initializeType(inContext: context)
                try freshInstance.initializeTypeConstraints(inContext: newContext)
                for (argument,parameter) in zip([self.lhs],freshInstance.parameters)
                    {
                    newContext.append(TypeConstraint(left: parameter.type,right: argument.type,origin: .expression(self)))
                    }
                let substitution = newContext.unify()
                let newInstance = substitution.substitute(freshInstance)
                inferredInstances.append(newInstance)
                }
            }
        inferredInstances = inferredInstances.filter{$0.isConcreteInstance}
        let types = [self.lhs.type]
        if let mostSpecificInstance = inferredInstances.sorted(by: {$0.moreSpecific(than: $1, forTypes: types)}).first
            {
            specificInstance = mostSpecificInstance
            self.type = specificInstance!.returnType
            for (argument,parameter) in zip([self.lhs],specificInstance!.parameters)
                {
                context.append(SubTypeConstraint(subtype: argument.type,supertype: parameter.type,origin: .expression(self)))
                }
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The most specific operator for this invocation can not be resolved. Trying making it more specific.")
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
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        PostfixExpression(operation: self.operation,lhs: substitution.substitute(self.lhs)) as! Self
        }
    }
