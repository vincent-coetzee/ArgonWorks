//
//  TupleExpression.swift
//  TupleExpression
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Foundation

public class TupleExpression: Expression
    {
    public override var displayString: String
        {
        let string = "(" + self.expressions.map{$0.displayString}.joined(separator: ",") + ")"
        return("TUPLE\(string)")
        }

    private var expressions = Expressions()
    public var isArrayDestructure: Bool = false
    internal var tuple: Tuple
    
    public override init()
        {
        self.tuple = Tuple()
        super.init()
        }
        
    public init(_ expressions: Expression...)
        {
        self.expressions = expressions
        self.tuple = Tuple(expressions)
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        let expressions = coder.decodeObject(forKey: "expressions") as! Expressions
        self.isArrayDestructure = coder.decodeBool(forKey: "isArrayDestructure")
        self.tuple = Tuple(expressions)
        self.expressions = expressions
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expressions,forKey: "expressions")
        coder.encode(self.isArrayDestructure,forKey: "isArrayDestructure")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for expression in self.expressions
            {
            try expression.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.tuple.initializeType(inContext: context)
        self.type = self.tuple.type!
        }
        
    public func append(_ expression: Expression)
        {
        self.expressions.append(expression)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        print("TupleExpression NEEDS TO GENERATE CODE")
        }
    }
