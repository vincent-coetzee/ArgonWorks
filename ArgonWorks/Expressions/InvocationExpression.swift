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
        if self.method.isNil
            {
            return(.unknown)
            }
        return(self.method!.returnType)
        }
        
    private let name: Name
    private let reportingContext: ReportingContext
    private let arguments: Arguments
    private var method: Method?
    private let location: Location
    private var methodInstance: MethodInstance?
    
    required init?(coder: NSCoder)
        {
        self.name = Name()
        self.reportingContext = NullReportingContext()
        self.arguments = []
        self.method = coder.decodeObject(forKey: "method") as? Method
        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        self.location = coder.decodeLocation(forKey: "location")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.method,forKey: "method")
        coder.encode(self.methodInstance,forKey: "methodInstance")
        coder.encodeLocation(location,forKey: "location")
        }
        
    init(name:Name,arguments:Arguments,location:Location,context:Context,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.arguments = arguments
        self.reportingContext = reportingContext
        super.init()
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        self.setContext(context)
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
        let classes = self.arguments.map{$0.value.type}
        self.methodInstance = method?.dispatch(with: classes.map{$0})
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
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        if self.methodInstance.isNil
            {
            return
            }
        for argument in self.arguments.reversed()
            {
            try argument.value.emitCode(into: instance,using: using)
            instance.append(nil,"PUSH",argument.value.place, .none, .none)
            }
        let localCount = self.methodInstance!.localSlots.count
        instance.append(nil,"SAVESTACKFRAME",.none,.none,.none)
        if localCount > 0
            {
            let size = localCount * MemoryLayout<Word>.size
            instance.append(nil,"ENTER",.literal(.integer(Argon.Integer(size))),.none,.none)
            }
        instance.append(nil,"DISPATCH",.relocatable(.method(self.method!)),.none,.none)
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
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator)
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
