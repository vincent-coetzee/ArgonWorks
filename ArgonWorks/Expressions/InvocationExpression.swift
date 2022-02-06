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
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.appendIssue(at: self.declaration!, message: "Method '\(self.name.displayString)' is not defined.")
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        analyzer.cancelCompletion()
        analyzer.dispatchError(at: self.location, message: "The invocation '\(self.name)' can not be resolved, it can not be dispatched.")
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        using.cancelCompletion()
        }
    }





