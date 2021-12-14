//
//  Initializer.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Initializer:Function,Scope
    {
    public var enclosingBlockContext: BlockContext
        {
        self
        }
        
    public var isBlockContextScope: Bool
        {
        false
        }
        
    public var isSlotScope: Bool
        {
        false
        }
        
    public override var enclosingScope: Scope
        {
        return(self)
        }
        
    public var isMethodInstanceScope: Bool
        {
        return(false)
        }
        
    public var isClosureScope: Bool
        {
        return(false)
        }
        
    public var isInitializerScope: Bool
        {
        return(true)
        }
        
    public override var instructions: Array<T3AInstruction>
        {
        self.buffer.instructions
        }
        
    internal private(set) var block = Block()
    internal var declaringType: Type
        {
        didSet
            {
            self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!},returnType: self.declaringType)
            }
        }
    private let buffer = T3ABuffer()
    private var symbols = Symbols()
    
    public override var typeCode:TypeCode
        {
        .initializer
        }

    public required init(label: Label)
        {
        self.declaringType = Type()
        super.init(label: label)
        self.block = InitializerBlock(initializer: self)
        self.block.setParent(self)
        }
            
    public required init?(coder: NSCoder)
        {
        self.symbols = coder.decodeObject(forKey: "symbols") as! Symbols
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.declaringType = coder.decodeObject(forKey: "declaringType") as! Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.symbols,forKey:"symbols")
        coder.encode(self.block,forKey: "block")
        coder.encode(self.declaringType,forKey: "declaringType")
        super.encode(with: coder)
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        self.symbols.append(symbol)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func typeCheck() throws
        {
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.parameters.forEach{try $0.initializeType(inContext: context)}
        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!.freshTypeVariable(inContext: context)},returnType: self.declaringType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.parameters.forEach{try $0.initializeTypeConstraints(inContext: context)}
        context.append(TypeConstraint(left: self.type,right: self.declaringType,origin: .symbol(self)))
        }
        
    public func moreSpecific(than instance:Initializer,forTypes types: Types) -> Bool
        {
        var orderings = Array<SpecificOrdering>()
        for index in 0..<types.count
            {
            let argumentType = types[index]
            let typeA = self.parameters[index].type!
            let typeB = instance.parameters[index].type!
            if typeA.isSubtype(of: typeB)
                {
                orderings.append(.more)
                }
            else if typeA.isClass && typeB.isClass && argumentType.isClass
                {
                let argumentClassList = argumentType.classValue.precedenceList
                if let typeAIndex = argumentClassList.firstIndex(of: typeA.classValue),let typeBIndex = argumentClassList.firstIndex(of: typeB.classValue)
                    {
                    orderings.append(typeAIndex > typeBIndex ? .more : .less)
                    }
                else
                    {
                    orderings.append(.unordered)
                    }
                }
            else
                {
                orderings.append(.unordered)
                }
            }
        for ordering in orderings
            {
            if ordering == .more
                {
                return(true)
                }
            }
        return(false)
        }
        
    public override func emitCode(using: CodeGenerator) throws
        {
        try self.emitCode(into: self.buffer,using: using)
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        buffer.appendEntry(temporaryCount: 0)
        try self.block.emitCode(into: buffer, using: using)
        buffer.appendExit()
        buffer.append("RET",.none,.none,.none)
        }
        
    public func parameterTypesAreSupertypes(ofTypes types: Types) -> Bool
        {
        for (inType,myType) in zip(types,self.parameters.map{$0.type!})
            {
            if !inType.isSubtype(of: myType)
                {
                return(false)
                }
            }
        return(true)
        }
    }
