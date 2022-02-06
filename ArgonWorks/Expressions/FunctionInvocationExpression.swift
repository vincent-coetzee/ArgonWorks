//
//  FunctionInvocationExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

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
        
    public override func visit(visitor: Visitor) throws
        {
        try self.function.visit(visitor: visitor)
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.function,forKey: "function")
        }

    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
//        if !self.function.validateInvocation(location: self.declaration!,arguments: self.arguments,reportingContext: analyzer.compiler.reportingContext)
//            {
//            return
//            }
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
        }
    }
