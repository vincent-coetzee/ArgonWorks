//
//  InvocationExpression.swift
//  InvocationExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InvocationExpression: Expression
    {
    public override var displayString: String
        {
        let values = "(" + self.arguments.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.name)\(values)")
        }
        
    public override var resultType: TypeResult
        {
        if self.method.isNil
            {
            return(.undefined)
            }
        return(.class(self.method!.returnType))
        }
        
    private let name: Name
    private let context: Context
    private let reportingContext: ReportingContext
    private let arguments: Arguments
    private var method: Method?
    private let location: Location
    private var methodInstance: MethodInstance?
    
    init(name:Name,arguments:Arguments,location:Location,context:Context,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.arguments = arguments
        self.context = context
        self.reportingContext = reportingContext
        super.init()
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        if self.name == Name("print")
            {
            print("halt")
            }
        self.method = self.context.lookup(name: self.name) as? Method
        if self.method.isNil
            {
            realizer.cancelCompletion()
            realizer.dispatchError(at: self.location, message: "Unable to resolve a method named '\(self.name).")
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if self.method.isNil
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.location, message: "Can not resolve method '\(self.name)', invocation can not be dispatched.")
            return
            }
        if self.arguments.count != self.method!.proxyParameters.count
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.location, message: "Invocation of '\(self.name)' uses \(arguments.count) arguments but the method requires \(self.method!.proxyParameters.count).")
            }
        let classes = self.arguments.map{$0.value.resultType.class}
        if classes.hasNils()
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.location, message: "The types of the arguments to the method '\(self.name)' can not be ascertained so the method can not be dispatched.")
            }
        self.methodInstance = method?.dispatch(with: classes.map{$0!})
        if self.methodInstance.isNil
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.location, message: "Can not resolve a specific instance of method '\(self.name)', this invocation can not be dispatched.")
            }
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)INVOCATION EXPRESSION()")
        print("\(padding)\t \(self.name)")
        for argument in self.arguments
            {
            argument.value.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        if self.method.isNil
            {
            return
            }
        for argument in self.arguments.reversed()
            {
            try argument.value.emitCode(into: instance,using: using)
            instance.append(.PUSH,argument.value.place, .none, .none)
            }
        let localCount = instance.localSlots.count
        instance.append(.PUSH,.register(.bp))
        instance.append(.MOV,.register(.sp),.none,.register(.bp))
        if localCount > 0
            {
            let size = localCount * MemoryLayout<Word>.size
            instance.append(.ISUB,.register(.sp),.integer(Argon.Integer(size)),.register(.sp))
            }
        instance.append(.DISP,.absolute(self.method!.memoryAddress))
        }
    }

public class MethodInvocationExpression: Expression
    {
    public override var displayString: String
        {
        let values = "(" + self.arguments.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.method.label)\(values)")
        }
        
    private let method: Method
    private let arguments: Arguments

    
    init(method:Method,arguments:Arguments)
        {
        self.method = method
        self.arguments = arguments
        }

    public override var resultType: TypeResult
        {
        return(.class(self.method.returnType))
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if !self.method.validateInvocation(location: self.declaration,arguments: self.arguments,reportingContext: analyzer.compiler.reportingContext)
            {
            return
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator)
        {
        
        }
    }

extension Sequence 
    {
    public func hasNils<T>() -> Bool where Element == Optional<T>
        {
        for element in self
            {
            switch(element)
                {
                case .some:
                    break
                case .none:
                    return(true)
                }
            }
        return(false)
        }
    }
