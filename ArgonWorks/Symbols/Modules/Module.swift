//
//  Module.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
    
public class Module:ContainerSymbol,Scope
    {
    public var isMethodInstanceScope: Bool
        {
        false
        }
        
    public var parentScope: Scope?
        {
        get
            {
            self.module
            }
        set
            {
            self.module = newValue as? Module
            }
        }
        
    public override var argonHash: Int
        {
        var hashValue = super.argonHash
        for symbol in self.symbols
            {
            hashValue = hashValue << 13 ^ symbol.argonHash
            }
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .managed
        }
        
    public var everyMethodInstance: MethodInstances
        {
        var instances = self.symbols.compactMap{$0 as? MethodInstance}
        for module in (self.symbols.compactMap{$0 as? Module})
            {
            instances.append(contentsOf: module.everyMethodInstance)
            }
        return(instances)
        }
    
    public var instanceSizeInBytes: Int
        {
        let moduleType = ArgonModule.shared.lookup(label: "Module") as! Type
        let size = moduleType.instanceSizeInBytes
        let slotsSize = self.symbols.filter{$0 is ModuleSlot}.count * Argon.kWordSizeInBytesInt
        return(size + slotsSize)
        }
        
    public override var sizeInBytes: Int
        {
        let moduleType = ArgonModule.shared.lookup(label: "Module") as! Type
        return(moduleType.instanceSizeInBytes + (self.moduleSlots.count * Argon.kWordSizeInBytesInt))
        }

    public var isMainModule: Bool
        {
        false
        }
        
    public var moduleSlots: Array<ModuleSlot>
        {
        self.symbols.compactMap{$0 as? ModuleSlot}
        }
        
    public var firstMainModule: MainModule?
        {
        for symbol in self.symbols where symbol is Module
            {
            if let module = (symbol as! Module).firstMainModule
                {
                return(module)
                }
            }
        return(nil)
        }
        
    public override var type: Type!
        {
        get
            {
            super.type = TypeConstructor(label: self.label, generics: [ArgonModule.shared.moduleType])
            return(super.type)
            }
        set
            {
            super.type = newValue
            }
        }
        
    public var firstMainMethod: Method?
        {
        return(self.firstMainModule?.mainMethod)
        }

    public override var isModule: Bool
        {
        return(true)
        }
        
    private var imports: Array<Importer> = []
    private var containerModule: Module!
    private var wasModuleLayoutDone = false
    ///
    ///
    /// Create a module class for this module which is a shadow
    /// type that holds the "class" of this module. It will act
    /// in place of the module when types are needed.
    ///
    ///
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        print("START DECODE MODULE")
        self.imports = coder.decodeObject(forKey: "imports") as! Array<Importer>
        super.init(coder: coder)
        print("END DECODE MODULE \(self.label)")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.imports,forKey: "imports")
        super.encode(with: coder)
        }
        
    public override func addLocalSlot(_ localSlot: LocalSlot)
        {
        fatalError()
        }
        
    public func layoutObjectSlots(withArgonModule argonModule: ArgonModule)
        {
        var offset = 0
        for slot in self.symbols.compactMap({$0 as? Slot}).sorted(by: {$0.label < $1.label})
            {
            slot.offset = offset
            offset += Argon.kWordSizeInBytesInt
            }
        }

    public func emitCode(using generator: CodeGenerator) throws -> Module
        {
        for symbol in self.symbols
            {
            try symbol.emitCode(using: generator)
            }
        return(self)
        }
    
    public override var typeCode:TypeCode
        {
        .module
        }
        
    public var classes:TypeClasses
        {
        var classes = Array(self.symbols.compactMap{$0 as? TypeClass})
        classes += self.symbols.compactMap{($0 as? Module)?.classes}.flatMap{$0}
        return(classes)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = ArgonModule.shared.moduleType
        for symbol in self.symbols
            {
            symbol.initializeType(inContext: context)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for symbol in self.symbols
            {
            symbol.initializeTypeConstraints(inContext: context)
            }
        }

    public override var iconName: String
        {
        "IconModule"
        }
        
    public override var defaultColor: NSColor
        {
        Palette.shared.moduleColor
        }
        
    public func dumpMethods()
        {
//        for method in self.symbols.flatMap({$0 as? Method})
//            {
//            method.dump()
//            }
        for module in self.symbols.compactMap({$0 as? Module})
            {
            module.dumpMethods()
            }
        }
        
        
    public override func addSymbol(_ symbol: Symbol)
        {
        if symbol is Importer
            {
            self.imports.append(symbol as! Importer)
            }
        super.addSymbol(symbol)
        symbol.module = self
        }
        
    public func slotWithLabel(_ label: Label) -> Slot?
        {
        for symbol in self.symbols
            {
            if symbol is Slot && symbol.label == label
                {
                return(symbol as! Slot)
                }
            }
        return(nil)
        }
        
    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        let count = self.symbols.count
        var text = ""
        if count == 0
            {
            }
        else if count == 1
            {
            text = "1 child"
            }
        else
            {
            text = "\(count) children"
            }
        leaderCell.textField?.stringValue = text
        }
        
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(true)
        }
        
    public func lookupSlot(label: String) -> Slot?
        {
        for symbol in self.symbols where symbol.label == label
            {
            if let slot = symbol as? Slot
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public override var weight: Int
        {
        10_000
        }
        
    public override func directlyContains(symbol:Symbol) -> Bool
        {
        for aSymbol in self.symbols
            {
            if aSymbol.index == symbol.index
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func moduleWithEmittedCode(using: CodeGenerator) -> Module?
        {
        do
            {
            return(try self.emitCode(using: using))
            }
        catch let error as CompilerIssue
            {
            self.appendIssue(error)
            }
        catch let error
            {
            self.appendIssue(at: .zero,message: "Unexpected error: \(error)")
            }
        return(nil)
        }
        
    public func typeCheckModule() -> Module?
        {
            let typeContext = TypeContext()
            let tempModule = Self(label: self.label)
            for symbol in self.symbols
                {
                symbol.initializeType(inContext: typeContext)
                let newSymbol = symbol.freshTypeVariable(inContext: typeContext)
                newSymbol.initializeType(inContext: typeContext)
                newSymbol.initializeTypeConstraints(inContext: typeContext)
                tempModule.addSymbol(newSymbol)
                }
            let substitution = typeContext.unify()
            let newModule = Self(label: self.label)
            Argon.resetTypes()
            for symbol in tempModule.symbols
                {
                newModule.addSymbol(substitution.substitute(symbol))
                }
            for symbol in newModule.symbols
                {
                do
                    {
                    try symbol.typeCheck()
                    }
                catch let issue as CompilerIssue
                    {
                    symbol.appendIssue(issue)
                    }
                catch let error
                    {
                    symbol.appendIssue(CompilerIssue(location: self.declarationLocation,message: "Unexpected error: \(error)"))
                    }
                }
        newModule.display(indent: "")
        newModule.wasSlotLayoutDone = self.wasSlotLayoutDone
        newModule.wasMemoryLayoutDone = self.wasMemoryLayoutDone
        newModule.wasAddressAllocationDone = self.wasAddressAllocationDone
        newModule.memoryAddress = self.memoryAddress
        return(newModule)
        }
        
    public func moduleWithOptimization(using: Optimizer) -> Module?
        {
        return(nil)
        }
        
    public func moduleWithSemanticsAnalyzed(using analyzer:SemanticAnalyzer) -> Module?
        {
        return(nil)
        }
        
    public override func layoutObjectSlots()
        {
        var offset = 0
        for slot in self.moduleSlots
            {
            slot.offset = offset
            offset += Argon.kWordSizeInBytesInt
            }
        for symbol in self.symbols
            {
            symbol.layoutObjectSlots()
            }
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        allocator.allocateAddress(for: self)
        self.wasAddressAllocationDone = true
        for symbol in self.symbols
            {
            try symbol.allocateAddresses(using: allocator)
            }
        for aStatic in Argon.staticTable
            {
            try aStatic.allocateAddresses(using: allocator)
            }
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        ///
        /// Need to do some stuff to pump the module into memory
        ///
        let segment = allocator.segment(for: self.segmentType)
        let moduleType = ArgonModule.shared.lookup(label: "Module") as! Type
        let modulePointer = ClassBasedPointer(address: self.memoryAddress,type: moduleType)
        modulePointer.setClass(moduleType)
        let addresses = self.symbols.map{$0.memoryAddress}
        let symbolsSize = addresses.count + 100
        let symbolArray = segment.allocateArray(size: symbolsSize,elements: addresses)
        modulePointer.setAddress(symbolArray,atSlot: "symbols")
        modulePointer.setBoolean(self is SystemModule,atSlot: "isSystemType")
        modulePointer.setBoolean(self is TopModule,atSlot: "isTopModule")
        modulePointer.setBoolean(self is ArgonModule,atSlot: "isArgonModule")
        modulePointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
        let moduleSlots = self.symbols.compactMap{$0 as? ModuleSlot}
        moduleSlots.forEach{$0.layoutInMemory(using: allocator)}
        modulePointer.setAddress(segment.allocateArray(size: moduleSlots.count,elements: moduleSlots.map{$0.memoryAddress}),atSlot: "slots")
        ////
        /// Now lay out each of the symsols in a module
        ///
        for symbol in self.symbols
            {
            symbol.layoutInMemory(using: allocator)
            }
        }
        
    @discardableResult
    public func moduleWithAllocatedAddresses(using allocator: AddressAllocator) -> Module?
        {
        guard !self.wasModuleLayoutDone else
            {
            return(self)
            }
        self.wasModuleLayoutDone = true
        ///
        /// Ask the ArgonModule to allocate into the same allocator i.e.payload
        /// in case it has not been laid out yet. If it has been done it won't
        /// do it again as it's protected by a flag.
        ///
        do
            {
            self.layoutObjectSlots()
            try self.allocateAddresses(using: allocator)
            self.layoutInMemory(using: allocator)
            return(self)
            }
        catch let error as CompilerIssue
            {
            self.appendIssue(error)
            }
        catch let error
            {
            self.appendIssue(at: .zero, message: "Unexpected error: \(error)")
            }
        return(nil)
        }
        
    public override func emitRValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        let temporary = buffer.nextTemporary()
        buffer.append(.MOV,.address(self.memoryAddress),.none,temporary)
        self.place = temporary
        }
        
    public override func emitLValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        let temporary = buffer.nextTemporary()
        buffer.append(.MOV,.address(self.memoryAddress),.none,temporary)
        self.place = temporary
        }
    }

public typealias Modules = Array<Module>
