//
//  MethodInvocationExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

public class MethodInvocationExpression: Expression
    {
    public override var displayString: String
        {
        let values = "(" + self.arguments.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.methodInstances.first!.label)\(values)")
        }
        
    private let methodInstances: ArgonWorks.MethodInstances
    private var arguments: Arguments
    private var methodInstance: MethodInstance?
    
    init(methodInstances: MethodInstances,arguments:Arguments)
        {
        self.methodInstances = methodInstances
        self.arguments = arguments
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.methodInstances = coder.decodeObject(forKey: "methodInstances") as! MethodInstances
        self.arguments = coder.decodeArguments(forKey: "arguments")
        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.methodInstances,forKey: "methodInstances")
        coder.encodeArguments(self.arguments,forKey: "arguments")
        coder.encode(self.methodInstance,forKey: "methodInstance")
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.arguments = try self.arguments.map{try $0.initializeType(inContext: context)}
        self.type = self.methodInstances.first!.returnType
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = MethodInvocationExpression(methodInstances: self.methodInstances,arguments: self.arguments.map{substitution.substitute($0)})
        if let instance = self.methodInstance
            {
            expression.methodInstance = substitution.substitute(instance)
            }
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)METHOD INVOCATION EXPRESSION: \(self.methodInstances.first!.label)")
        print("\(indent)ARGUMENTS:")
        for argument in self.arguments
            {
            print("\(indent)\t\(argument.tag ?? "") \(argument.value.type!.displayString)")
            }
        if let instance = self.methodInstance
            {
            print("\(indent)\tSELECTED METHOD INSTANCE: \(instance.displayString)")
            }
        else
            {
            print("\(indent)\tNO SELECTED METHOD INSTANCE")
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        print("METHOD INVOCATION EXPRESSION")
        try self.arguments.forEach{try $0.initializeTypeConstraints(inContext: context)}
        let methodMatcher = MethodInstanceMatcher(methodInstances: self.methodInstances, argumentExpressions: self.arguments.map{$0.value}, reportErrors: true)
        methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
        methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
        methodMatcher.appendReturnType(self.type!)
        if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
            {
            self.methodInstance = specificInstance
            assert(self.methodInstance.isNotNil,"Original method instance is nil and should not be.")
            print("FOUND MOST SPECIFIC INSTANCE FOR \(self.methodInstances.first!.label) = \(specificInstance.displayString)")
            }
        else
            {
            print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE FOR \(self.methodInstances.first!.label)")
            self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.methodInstances.first!.label)' ) can not be resolved. Try making it more specific.")
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    private func mapLabels(from: Array<Label>,to: TaggedTypes) -> TaggedTypes
        {
        var index = 0
        var types = TaggedTypes()
        for argument in to
            {
            types.append(TaggedType(tag: argument.tag.isNil ? from[index] : argument.tag!,type: argument.type))
            index += 1
            }
        return(types)
        }
        
    public override func emitCode(into buffer: T3ABuffer, using generator: CodeGenerator) throws
        {
        guard let instance = self.methodInstance else
            {
            fatalError("Can not emit code for nil method instance")
            }
        for argument in self.arguments.reversed()
            {
            try argument.value.emitRValue(into: buffer, using: generator)
            buffer.append("PUSH",argument.value.place,.none,.none)
            }
        buffer.append("CALL",.relocatable(.methodInstance(instance)),.none,.none)
        buffer.append("ADD",.stackPointer,.literal(.integer(self.arguments.count * Argon.kArgumentSizeInBytes)),.none)
        }
    }
