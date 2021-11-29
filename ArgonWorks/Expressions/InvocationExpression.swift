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
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        }

    public override func deepCopy() -> Self
        {
        InvocationExpression(name: self.name,arguments: self.arguments,location: self.location) as! Self
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        self.appendIssue(at: self.declaration!, message: "Method '\(self.name.displayString)' is not defined.")
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
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





