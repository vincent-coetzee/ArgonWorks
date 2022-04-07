//
//  Block.swift
//  Block
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class Block:NSObject,NSCoding,Displayable,VisitorReceiver,Scope,StackFrame
    {
//    public var asContainer: Container
//        {
//        .block(self)
//        }
//
    public var parentScope: Scope?
        {
        get
            {
            self.parentBlock
            }
        set
            {
            fatalError()
            }
        }
        
    public var enclosingMethodInstance: MethodInstance
        {
        self.parentBlock!.enclosingMethodInstance
        }
        
//    public var moduleScope: Module?
//        {
//        self.parentBlock?.module
//        }
        
    public var argonHash: Int
        {
        var hasher = Hasher()
        hasher.combine(self)
        for block in self.blocks
            {
            hasher.combine(block)
            }
        let hashValue = hasher.finalize()
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(abs(Int(bitPattern: word)))
        }

    public var isEmpty: Bool
        {
        self.blocks.isEmpty
        }
        
    public var displayString: String
        {
        "Block" + self.blocks.displayString
        }
        
    public var returnBlocks: Array<ReturnBlock>
        {
        var returnBlocks = Array<ReturnBlock>()
        for block in self.blocks
            {
            returnBlocks.append(contentsOf: block.returnBlocks)
            }
        return(returnBlocks)
        }
        
    public var hasInlineReturnBlock: Bool
        {
        for block in self.blocks
            {
            if block.hasInlineReturnBlock
                {
                return(true)
                }
            }
        return(false)
        }
        
    public var isReturnBlock: Bool
        {
        return(false)
        }
        
    public var declaration: Location?
        {
        self.locations.declaration.isNil ? .zero : self.locations.declaration
        }
        
    public var container: Container = .none
    public var type: Type = TypeContext.freshTypeVariable()
    internal var locations = SourceLocations()
    internal var blocks = Blocks()
    internal var localSymbols = Symbols()
    internal var source: String?
    public private(set) var index = IdentityKey.nextKey()
    private var nextLocalSlotOffset = 0
    private var nextParameterOffset = 16
    public var ancestors = Blocks()
    public private(set) var parentBlock: Block?
    
    required override init()
        {
        }
        
    public required init?(coder: NSCoder)
        {
        self.parentBlock = coder.decodeObject(forKey: "parentBlock") as? Block
        self.blocks = coder.decodeObject(forKey: "blocks") as! Array<Block>
        self.localSymbols = coder.decodeObject(forKey:"localSymbols") as! Symbols
        self.index = coder.decodeObject(forKey: "index") as! IdentityKey
        self.nextLocalSlotOffset = coder.decodeInteger(forKey: "nextLocalSlotOffset")
        self.nextParameterOffset = coder.decodeInteger(forKey: "nextParameterOffset")
        self.type = coder.decodeObject(forKey: "type") as! Type
        self.source = coder.decodeObject(forKey: "source") as? String
        }
    
        
    public func encode(with coder: NSCoder)
        {
        print("ENCODE \(Swift.type(of: self))")
        coder.encode(self.parentBlock,forKey: "parentBlock")
        coder.encode(self.blocks,forKey: "blocks")
        coder.encode(self.localSymbols,forKey: "localSymbols")
        coder.encode(self.index,forKey: "index")
        coder.encode(self.nextLocalSlotOffset,forKey: "nextLocalSlotOffset")
        coder.encode(self.nextParameterOffset,forKey: "nextParameterOffset")
        coder.encode(self.type,forKey: "type")
        coder.encode(self.source,forKey: "source")
        }
        
//    public func setContainer(_ scope: Scope?)
//        {
//        self.container = .scope(scope!)
//        }
        
    public func appendIssue(_ issues: CompilerIssue)
        {
        self.parentBlock?.appendIssue(issues)
        }
        
    public func appendIssue(at: Location,message: String)
        {
        self.parentBlock?.appendIssue(at: at,message: message,isWarning: false)
        }
        
    public func appendIssue(at: Location,message: String,isWarning: Bool = false)
        {
        self.parentBlock?.appendIssue(at: at,message: message,isWarning: isWarning)
        }
        
    public func appendWarningIssue(at: Location,message: String)
        {
        self.parentBlock?.appendIssue(at: at,message: message,isWarning: true)
        }
        
    public func lookupMethod(label: Label) -> Method?
        {
        self.parentBlock?.lookupMethod(label: label)
        }
        
    public func removeSymbol(_ symbol: Symbol)
        {
        fatalError()
        }
        
    public func addSymbol(_ symbol: Symbol)
        {
        if symbol is Parameter
            {
            self.addParameterSlot(symbol as! Parameter)
            }
        else if symbol is Slot
            {
            self.addLocalSlot(symbol as! LocalSlot)
            }
        else
            {
            self.localSymbols.append(symbol)
            }
        }
        
    public func setParentBlock(_ block: Block)
        {
        self.parentBlock = block
        }
        
    public func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newBlock = Self.init()
        newBlock.parentBlock = self.parentBlock
        newBlock.index = self.index
        for block in self.blocks
            {
            newBlock.addBlock(block.freshTypeVariable(inContext: context))
            }
        newBlock.type = self.type.freshTypeVariable(inContext: context)
        newBlock.setIndex(self.index.keyByIncrementingMinor())
        newBlock.ancestors.append(self)
        newBlock.locations = self.locations
        return(newBlock)
        }
        
    public func addLocalSlot(_ localSlot: LocalSlot)
        {
        self.localSymbols.append(localSlot)
        localSlot.frame = self
        localSlot.offset = self.nextLocalSlotOffset
        self.nextLocalSlotOffset -= 8
        }
    
    public func setIndex(_ index: IdentityKey)
        {
        self.index = index
        }
        
    public func addParameterSlot(_ parameter: Parameter)
        {
        self.localSymbols.append(parameter)
        parameter.frame = self
        parameter.offset = self.nextParameterOffset
        self.nextLocalSlotOffset += 8
        }

    public func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.localSymbols
            {
            if symbol.localLabel == label
                {
                found.append(symbol)
                }
            }
        if let more = self.parentBlock?.lookupN(label: label)
            {
            found.append(contentsOf: more)
            }
        return(found.isEmpty ? nil : found)
        }
        
    public func lookupType(label: Label) -> Type?
        {
        self.parentBlock?.lookupType(label: label)
        }
        
//    public func lookupN(name: Name) -> Symbols?
//        {
//        if name.isRooted
//            {
//            return(self.parentBlock?.lookupN(name: name))
//            }
//        else if name.count == 1
//            {
//            var results = Symbols()
//            for symbol in self.localSymbols
//                {
//                if symbol.localLabel == name.last
//                    {
//                    results.append(symbol)
//                    }
//                }
//            if let upper = self.parentBlock?.lookupN(name: name)
//                {
//                results.append(contentsOf: upper)
//                }
//            return(results.isEmpty ? nil : results)
//            }
//        else
//            {
//            return(self.parentBlock?.lookupN(name: name))
//            }
//        }
        
//    public func lookup(name: Name) -> Symbol?
//        {
//        if name.isRooted
//            {
//            if name.count == 1
//                {
//                return(nil)
//                }
//            if let start = TopModule.shared.lookup(label: name.first)
//                {
//                if name.count == 2
//                    {
//                    return(start)
//                    }
//                if let symbol = start.lookup(name: name.withoutFirst)
//                    {
//                    return(symbol)
//                    }
//                }
//            }
//        if name.isEmpty
//            {
//            return(nil)
//            }
//        else if name.count == 1
//            {
//            if let symbol = self.lookup(label: name.first)
//                {
//                return(symbol)
//                }
//            }
//        else if let start = self.lookup(label: name.first)
//            {
//            if let symbol = (start as? Scope)?.lookup(name: name.withoutFirst)
//                {
//                return(symbol)
//                }
//            }
//        return(self.parentBlock?.lookup(name: name))
//        }
        
    public func lookup(label: String) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.localLabel == label
                {
                return(symbol)
                }
            }
        return(self.parentBlock?.lookup(label: label))
        }
        
    public func visit(visitor: Visitor) throws
        {
        for block in self.blocks
            {
            try block.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public func typeCheck() throws
        {
        for block in self.blocks
            {
            try block.typeCheck()
            }
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        }
        
    internal func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = Self()
        newBlock.setIndex(self.index.keyByIncrementingMinor())
        newBlock.type = substitution.substitute(self.type)
        for block in self.blocks
            {
            newBlock.addBlock(substitution.substitute(block))
            }
        newBlock.ancestors.append(self)
        return(newBlock)
        }
        
    public func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self))")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public func addBlock(_ block:Block)
        {
        self.blocks.append(block)
        block.parentBlock = self
        block.container = .block(self)
        }
        
    public func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        for block in self.blocks
            {
            try block.emitCode(into: into,using: using)
            }
        }
        
    public func deepCopy() -> Self
        {
        let newBlock = Self.init()
        newBlock.blocks = self.blocks.map{$0.deepCopy()}
        return(newBlock)
        }
        
    public func addDeclaration(itemKey: Int,location aLocation:Location)
        {
        var location = aLocation
        location.itemKey = itemKey
        self.locations.append(.declaration(location))
        }
        
    public func addDeclaration(_ location: Location)
        {
        self.addDeclaration(itemKey: 0,location: location)
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func addReference(itemKey: Int,location aLocation:Location)
        {
        var location = aLocation
        location.itemKey = itemKey
        self.locations.append(.reference(location))
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
//        let blockTypes = self.returnBlocks.filter{$0.enclosingMethodInstance == self.container.enclosingMethodInstance}.reduce(TypeUnion(),{$0.append($1.type)})
        self.type = context.voidType
        }
        
    public func inferType(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.inferType(inContext: context)
            }
//        let blockTypes = self.returnBlocks.filter{$0.enclosingMethodInstance == self.container.enclosingMethodInstance}.reduce(TypeUnion(),{$0.append($1.type)})
        self.type = context.voidType
        }
        
    public func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public func hasPrimitiveBlock() -> Bool
        {
        for block in self.blocks
            {
            if block.hasPrimitiveBlock()
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func hasReturnBlock() -> Bool
        {
        for block in self.blocks
            {
            if block.hasReturnBlock() || block.hasPrimitiveBlock()
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func dump(depth: Int)
        {
//        let padding = String(repeating: "\t", count: depth)
        for block in self.blocks
            {
            block.dump(depth: depth+1)
            }
        }
    }
    
public typealias Blocks = Array<Block>

    


    

    
