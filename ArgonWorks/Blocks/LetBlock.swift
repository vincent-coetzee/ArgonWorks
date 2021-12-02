//
//  LetBlock.swift
//  LetBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation



public class LetBlock: Block
    {
    public override var displayString: String
        {
        "LET " + self.pairs.displayString
        }
        
    private var pairs: TupleElementPairs
    private var location:Location
    
    public init(location:Location,pairs: TupleElementPairs)
        {
        self.location = location
        self.pairs = pairs
        super.init()
        for pair in self.pairs
            {
            pair.setParent(self)
            }
        }
        
    public required init?(coder: NSCoder)
        {
        self.location = coder.decodeLocation(forKey: "location")
        self.pairs = coder.decodeObject(forKey: "pairs") as! TupleElementPairs
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.pairs = TupleElementPairs()
        self.location = .zero
        super.init()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeLocation(self.location,forKey: "location")
        coder.encode(self.pairs,forKey: "pairs")
        super.encode(with: coder)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self))")
        for pair in self.pairs
            {
            pair.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for element in self.pairs
            {
            try element.lhs.initializeType(inContext: context)
            try element.rhs.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        LetBlock(location: self.location,pairs: self.pairs.map{$0.substitute(from: substitution)}) as! Self
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for element in self.pairs
            {
            try element.lhs.initializeTypeConstraints(inContext: context)
            try element.rhs.initializeTypeConstraints(inContext: context)
            context.append(TypeConstraint(left: element.lhs.type,right: element.rhs.type,origin: .block(self)))
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for pair in self.pairs
            {
            try pair.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
//        let valueType = self.rhs.type
//        if !valueType.isSubtype(of: slotType)
//            {
//            analyzer.compiler.reportingContext.dispatchError(at: self.location, message: "An instance of class \(valueType) can not be assigned to an instance of \(slotType).")
//            }
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
//        try self.expression.emitCode(into: buffer,using: generator)
        }
    }
