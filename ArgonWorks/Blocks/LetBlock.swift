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
        "LET " + self.lhs.displayString + " " + self.rhs.displayString
        }
        
    private let lhs: Tuple
    private let rhs: Tuple
    private var location:Location
    
    public init(location:Location,lhs: Tuple,rhs: Tuple)
        {
        self.location = location
        self.lhs = lhs
        self.rhs = rhs
        super.init()
        self.lhs.parent = .block(self)
        self.rhs.parent = .block(self)
        if self.lhs.isEmpty || self.rhs.isEmpty
            {
            print("halt")
            }
        }
        
    public required init?(coder: NSCoder)
        {
        self.location = coder.decodeLocation(forKey: "location")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Tuple
        self.rhs = coder.decodeObject(forKey: "rhs") as! Tuple
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.lhs = Tuple()
        self.rhs = Tuple()
        self.location = .zero
        super.init()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeLocation(self.location,forKey: "location")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self))")
        self.lhs.display(indent: indent + "\t")
        self.rhs.display(indent: indent + "\t")
        if self.lhs.isEmpty || self.rhs.isEmpty
            {
            print("halt")
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        self.type = context.voidType
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
//        let block = LetBlock(location: self.location,lhs: self.lhs.freshTypeVariable(inContext: context),rhs: self.rhs.freshTypeVariable(inContext: context))
//        block.type = self.type!.freshTypeVariable(inContext: context)
//        return(block as! Self)
        return(self)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = LetBlock(location: self.location,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        block.type = substitution.substitute(self.type!)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        for (left,right) in zip(self.lhs.elements,self.rhs.elements)
            {
            context.append(TypeConstraint(left: left.type,right: right.type,origin: .block(self)))
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
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
        for (left,right) in zip(self.lhs.elements,self.rhs.elements)
            {
            if case let TupleElement.expression(expression) = right
                {
                try left.assign(from: expression,into: buffer,using: generator)
                }
            else
                {
                fatalError("Can not assign to a tuple from anything other than an expression.")
                }
            }
        }
    }
