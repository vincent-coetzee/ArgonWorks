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
        
    private var lhs: Tuple
    private var rhs: Tuple
    private var location:Location
    
    public init(location:Location,lhs: Tuple,rhs: Tuple)
        {
        self.location = location
        self.lhs = lhs
        self.rhs = rhs
        super.init()
        assert(!self.lhs.isEmpty)
        assert(!self.rhs.isEmpty)
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
        assert(!self.lhs.isEmpty)
        assert(!self.rhs.isEmpty)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .block(self)))
        self.type = self.lhs.type
        context.append(TypeConstraint(left: self.type,right: self.lhs.type,origin: .block(self)))
        context.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .block(self)))
        let slotLabels = (self.lhs as! TupleExpression).slots.map{$0.label}
        let rightTypes = (self.rhs as! TupleExpression).types
        context.extended(with: <#T##Type#>, boundTo: <#T##Label#>)
        }
        
    public override func inferType(inContext context: TypeContext)
        {
        self.lhs.inferType(inContext: context)
        self.rhs.inferType(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .block(self)))
        self.type = self.lhs.type
        context.append(TypeConstraint(left: self.type,right: self.lhs.type,origin: .block(self)))
        context.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .block(self)))
        let slotLabels = (self.lhs as! TupleExpression).slots.map{$0.label}
        let rightTypes = (self.rhs as! TupleExpression).types
        var values = Array<(Label,Type)>()
        for (label,type) in zip(slotLabels,rightTypes)
            {
            values.append((label,type))
            }
        context.extended(with: values)
            {
            newContext in
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = LetBlock(location: self.location,lhs: self.lhs.freshTypeVariable(inContext: context),rhs: self.rhs.freshTypeVariable(inContext: context))
        block.type = self.type.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = super.substitute(from: substitution)
        newBlock.lhs = substitution.substitute(self.lhs)
        newBlock.rhs = substitution.substitute(self.rhs)
        newBlock.type = substitution.substitute(self.type)
        return(newBlock)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
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
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
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
