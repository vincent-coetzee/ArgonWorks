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
        
    public override var type: Type
        {
        return(.unknown)
        }
        
    private let name: Name
    private let arguments: Arguments
    private let location: Location
    
    required init?(coder: NSCoder)
        {
        self.name = Name()
        self.arguments = []
        self.location = coder.decodeLocation(forKey: "location")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encodeLocation(location,forKey: "location")
        }
        
    init(name:Name,arguments:Arguments,location:Location)
        {
        self.name = name
        self.location = location
        self.arguments = arguments
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
        if self.name == Name("append")
            {
            print("halt")
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        analyzer.cancelCompletion()
        analyzer.dispatchError(at: self.location, message: "The invocation '\(self.name)' can not be resolved, it can not be dispatched.")
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
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        using.cancelCompletion()
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
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.method = coder.decodeObject(forKey: "method") as! Method
        self.arguments = []
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.method,forKey: "method")
        }
        
    public override var type: Type
        {
        return(self.method.returnType)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if !self.method.validateInvocation(location: self.declaration!,arguments: self.arguments,reportingContext: analyzer.compiler.reportingContext)
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
        
    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
        if self.method.label == "format"
            {
            print("halt")
            }
        guard let location = self.declaration else
            {
            print("ERROR: not not locate expression")
            return
            }
        instance.append(lineNumber: location.line)
        let types = self.arguments.map{$0.value.type}
        let methodInstance = self.method.mostSpecificMethodInstance(forTypes: types)
        guard methodInstance.isNotNil else
            {
            generator.cancelCompletion()
            generator.dispatchError(at: location, message: "Can not find a matching instance for this method, it can not be dispatched.")
            instance.append(comment: "METHOD \(self.method.label) TYPES \(types.map{$0.label})")
            return
            }
        var count:Argon.Integer = 0
        for argument in self.arguments.reversed()
            {
            try argument.value.emitCode(into: instance, using: generator)
            if argument.value.place.isNone
                {
                print("ERROR")
                }
            instance.append(nil,"PUSH",argument.value.place,.none,.none)
            count += 1
            }
        instance.append(nil,"CALL",.relocatable(.methodInstance(methodInstance!)),.none,.none)
        instance.append("ADD",.stackPointer,.literal(.integer(count * 8)),.stackPointer)
        self._place = .returnRegister
        }
    }

public class FunctionInvocationExpression: Expression
    {
    public override var displayString: String
        {
        let values = "(" + self.arguments.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.function.label)\(values)")
        }
        
    private let function: Function
    private let arguments: Arguments

    
    init(function:Function,arguments:Arguments)
        {
        self.function = function
        self.arguments = arguments
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.function = coder.decodeObject(forKey: "function") as! Function
        self.arguments = []
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.function,forKey: "function")
        }
        
    public override var type: Type
        {
        return(self.function.returnType)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
//        if !self.function.validateInvocation(location: self.declaration!,arguments: self.arguments,reportingContext: analyzer.compiler.reportingContext)
//            {
//            return
//            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        }
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
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
