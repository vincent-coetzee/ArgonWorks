//
//  SystemRelatedExpressions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/12/21.
//

import Foundation

public class ClassExpression: Expression
    {
    public override var displayString: String
        {
        return("CLASS(\(self.expression.displayString),\(self.type!.displayString)")
        }

    private let expression: Expression

    required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expression,forKey:"expression")
        }

    init(expression: Expression)
        {
        self.expression = expression
        super.init()
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type!.lookup(label: label))
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.expression.visit(visitor: visitor)
        try self.type!.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.expression.initializeType(inContext: context)
        self.type = self.enclosingScope.topModule.argonModule.class
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.expression.initializeTypeConstraints(inContext: context)
        try self.type!.initializeTypeConstraints(inContext: context)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        }

    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
        }
    }
