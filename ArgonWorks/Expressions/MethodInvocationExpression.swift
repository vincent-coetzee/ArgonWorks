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
        self.arguments = []
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.methodInstances,forKey: "methodInstances")
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
        
    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
//        guard let location = self.declaration else
//            {
//            print("ERROR: can not locate expression")
//            return
//            }
//        instance.append(lineNumber: location.line)
//        if self.methodInstance.isNil
//            {
//            generator.cancelCompletion()
//            generator.dispatchError(at: location, message: "Can not find a matching instance for this method, it can not be dispatched.")
//            instance.append(comment: "UNABLE TO MATCH METHOD \(self.method.label) WITH TYPES \(self.arguments.map{$0.value.type!.displayString})")
//            return
//            }
//        var count:Argon.Integer = 0
//        for argument in self.arguments.reversed()
//            {
//            try argument.value.emitCode(into: instance, using: generator)
//            if argument.value.place.isNone
//                {
//                print("ERROR")
//                }
//            instance.append(nil,"PUSH",argument.value.place,.none,.none)
//            count += 1
//            }
//        instance.append(nil,"CALL",.relocatable(.methodInstance(methodInstance!)),.none,.none)
//        instance.append("ADD",.stackPointer,.literal(.integer(count * 8)),.stackPointer)
//        self._place = .returnRegister
        }
    }
