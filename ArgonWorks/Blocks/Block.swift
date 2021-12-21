//
//  Block.swift
//  Block
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class Block:NSObject,NamingContext,NSCoding,Displayable,VisitorReceiver,ErrorScope
    {
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
        
    public var isMethodInstanceScope: Bool
        {
        false
        }
    
    public var isClosureScope: Bool
        {
        false
        }
    
    public var isInitializerScope: Bool
        {
        false
        }
    
    public var isSlotScope: Bool
        {
        false
        }
    
    public var enclosingBlockContext: BlockContext
        {
        if self is BlockContext
            {
            return(self as! BlockContext)
            }
        return(self.parent.enclosingBlockContext)
        }
    
    public var enclosingScope: Scope
        {
        return(self.parent.enclosingScope)
        }
        
    public var allIssues: CompilerIssues
        {
        var myIssues = self.issues
        for block in self.blocks
            {
            myIssues.append(contentsOf: block.allIssues)
            }
        return(myIssues)
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
        
    public var enclosingClass: Class?
        {
        return(self.parent.enclosingClass)
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
        
    public var parentBlock: Block?
        {
        return(self.parent.block)
        }
        
    public var topModule: TopModule
        {
        return(self.parent.topModule)
        }
        
    public var declaration: Location?
        {
        self.locations.declaration.isNil ? .zero : self.locations.declaration
        }
        
    public var type: Type? = nil
    internal var locations = SourceLocations()
    internal var blocks = Blocks()
    internal var localSymbols = Symbols()
    internal var source: String?
    public private(set) var index:UUID
    public private(set) var parent: Parent = .none
    public var issues: CompilerIssues = []
    private var nextLocalSlotOffset = 0
    private var nextParameterOffset = 16
    public private(set) var container: Container?
    
    public var methodInstance: MethodInstance
        {
        return(self.parent.block!.methodInstance)
        }
        
    public var primaryContext: NamingContext
        {
        return(self.parent.primaryContext)
        }
    
    @discardableResult
    public func removeSymbol(_ symbol: Symbol) -> Symbol
        {
        fatalError("Attempt to remove a symbol n a block")
        }
        
    public func setSymbol(_ symbol: Symbol,atName: Name)
        {
        self.parent.setSymbol(symbol,atName: atName)
        }
        
    required override init()
        {
        self.index = UUID()
        }
        
    public required init?(coder: NSCoder)
        {
        self.blocks = coder.decodeObject(forKey: "blocks") as! Array<Block>
        self.localSymbols = coder.decodeObject(forKey:"localSymbols") as! Symbols
        self.index = coder.decodeObject(forKey: "index") as! UUID
        self.parent = coder.decodeParent(forKey: "parent")!
        self.nextLocalSlotOffset = coder.decodeInteger(forKey: "nextLocalSlotOffset")
        self.nextParameterOffset = coder.decodeInteger(forKey: "nextParameterOffset")
        self.type = coder.decodeObject(forKey: "type") as? Type
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        self.source = coder.decodeObject(forKey: "source") as? String
        }
    
        
    public func encode(with coder: NSCoder)
        {
        print("ENCODE \(Swift.type(of: self))")
        coder.encode(self.blocks,forKey: "blocks")
        coder.encode(self.localSymbols,forKey: "localSymbols")
        coder.encode(self.index,forKey: "index")
        coder.encodeParent(self.parent,forKey: "parent")
        coder.encode(self.nextLocalSlotOffset,forKey: "nextLocalSlotOffset")
        coder.encode(self.nextParameterOffset,forKey: "nextParameterOffset")
        coder.encode(self.type,forKey: "type")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        coder.encode(self.source,forKey: "source")
        }
        
    public func appendIssue(at: Location, message: String)
        {
        self.issues.append(CompilerIssue(location: at,message: message))
        }
    
    public func appendWarningIssue(at: Location, message: String)
        {
        self.issues.append(CompilerIssue(location: at,message: message,isWarning: true))
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
        
    public func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newBlock = Self.init()
        newBlock.index = self.index
        for block in self.blocks
            {
            newBlock.addBlock(block.freshTypeVariable(inContext: context))
            }
        newBlock.type = self.type?.freshTypeVariable(inContext: context)
        return(newBlock)
        }
        
    public func addLocalSlot(_ localSlot: LocalSlot)
        {
        self.localSymbols.append(localSlot)
        localSlot.frame = (self as! BlockContext)
        localSlot.offset = self.nextLocalSlotOffset
        self.nextLocalSlotOffset -= 8
        }
    
    public func setIndex(_ index: UUID)
        {
        self.index = index
        }
        
    public func addParameterSlot(_ parameter: Parameter)
        {
        self.localSymbols.append(parameter)
        parameter.frame = (self as! BlockContext)
        parameter.offset = self.nextParameterOffset
        self.nextLocalSlotOffset += 8
        }
        
    public func appendIssue(at: Location,message: String,isWarning:Bool = false)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: isWarning))
        }
        
    public func appendIssues(_ issues: CompilerIssues)
        {
        self.issues.append(contentsOf: issues)
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        }
        
    public func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.localSymbols
            {
            if symbol.label == label
                {
                found.append(symbol)
                }
            }
        if let more = self.parent.lookupN(label: label)
            {
            found.append(contentsOf: more)
            }
        return(found.isEmpty ? nil : found)
        }
        
    public func lookupN(name: Name) -> Symbols?
        {
        if name.isRooted
            {
            return(self.parent.lookupN(name: name))
            }
        else if name.count == 1
            {
            var results = Symbols()
            for symbol in self.localSymbols
                {
                if symbol.label == name.last
                    {
                    results.append(symbol)
                    }
                }
            if let upper = self.parent.lookupN(name: name)
                {
                results.append(contentsOf: upper)
                }
            return(results.isEmpty ? nil : results)
            }
        else
            {
            return(self.parent.lookupN(name: name))
            }
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
        let newBlock = Self.init()
        newBlock.index = self.index
        for block in self.blocks
            {
            newBlock.addBlock(substitution.substitute(block))
            }
        newBlock.type = substitution.substitute(self.type!)
        newBlock.setParent(self.parent)
        newBlock.issues = self.issues
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
        
    public func printParentChain()
        {
        self.parent.printParentChain()
        }
        
    public func addBlock(_ block:Block)
        {
        self.blocks.append(block)
        block.setParent(self)
        }
        
    public func setParent(_ block:Block)
        {
        self.parent = .block(block)
        }
        
    public func setParent(_ symbol:Symbol)
        {
        self.parent = .node(symbol)
        }
        
    public func setParent(_ parent:Parent)
        {
        self.parent = parent
        }
        
    public func setParent(_ context: Context)
        {
        switch(context)
            {
            case .none:
                break
            case .block(let block):
                self.parent = .block(block)
            case .node(let node):
                self.parent = .node(node)
            }
        }
        
    public func emitCode(into: T3ABuffer,using: CodeGenerator) throws
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
        
    public func addDeclaration(_ location:Location)
        {
        self.locations.append(.declaration(location))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
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
        
    public func lookup(label: String) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let start = self.lookup(label: name.first)
                {
                if name.count == 2
                    {
                    return(start)
                    }
                if let symbol = start.lookup(name: name.withoutFirst)
                    {
                    return(symbol)
                    }
                }
            }
        if name.isEmpty
            {
            return(nil)
            }
        else if name.count == 1
            {
            if let symbol = self.lookup(label: name.first)
                {
                return(symbol)
                }
            }
        else if let start = self.lookup(label: name.first)
            {
            if let symbol = start.lookup(name: name.withoutFirst)
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(name: name))
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

    


    

    
