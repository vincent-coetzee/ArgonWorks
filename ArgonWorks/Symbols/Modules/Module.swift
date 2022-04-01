//
//  Module.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
    
public var AddressTable = Dictionary<IdentityKey,Address>()

public class Module:ContainerSymbol,Scope
    {
    public override var enclosingModule: Module
        {
        return(self)
        }
        
    public var enclosingMethodInstance: MethodInstance
        {
        fatalError()
        }
        
    public override var symbolType: SymbolType
        {
        .module
        }
        
    public var mainMethod: MethodInstance?
        {
        for symbol in self.allSymbols
            {
            if let instance = symbol as? MethodInstance
                {
                if instance.isMainMethod
                    {
                    return(instance)
                    }
                }
            }
        return(nil)
        }
//
//    public var asContainer: Container
//        {
//        return(.module(self))
//        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var moduleScope: Module?
        {
        self
        }
        
    public var enclosingMethodInstanceScope: MethodInstance
        {
        fatalError()
        }
        
    public var placeholderSymbols: Array<PlaceholderSymbol>
        {
        self.allSymbols.compactMap{$0 as? PlaceholderSymbol}
        }
        
    public var parentScope: Scope?
        {
        get
            {
            self.module
            }
        set
            {
//            self.module = newValue as? Module
            if newValue.isNil
                {
            fatalError()
            }
            self.setModule(newValue as! Module)
            }
        }
        
    public override var argonHash: Int
        {
        "\(Swift.type(of: self))\(self.label)".polynomialRollingHash
        }
        
    public var everyMethodInstance: MethodInstances
        {
        var instances = self.allSymbols.compactMap{$0 as? MethodInstance}
        for module in (self.allSymbols.compactMap{$0 as? Module})
            {
            instances.append(contentsOf: module.everyMethodInstance)
            }
        return(instances)
        }
    
    public override var instanceSizeInBytes: Int
        {
        let moduleType = ArgonModule.shared.lookup(label: "Module") as! Type
        let size = moduleType.instanceSizeInBytes
        let slotsSize = self.allSymbols.filter{$0 is ModuleSlot}.count * Argon.kWordSizeInBytesInt
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
        
    public var everySymbol: Symbols
        {
        var everySymbol = Symbols()
        for module in self.allModules
            {
            everySymbol.append(contentsOf: module.allSymbols)
            }
        return(everySymbol)
        }
        
    public var moduleSlots: Array<ModuleSlot>
        {
        self.allSymbols.compactMap{$0 as? ModuleSlot}
        }
        
    public var firstMainModule: MainModule?
        {
        for symbol in self.allSymbols where symbol is Module
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
        
//    public var firstMainMethod: Method?
//        {
//        return(self.firstMainModule?.mainMethod)
//        }

    public override var isModule: Bool
        {
        return(true)
        }
        
    private var imports: Array<Importer> = []
    private var containerModule: Module!
    private var wasModuleLayoutDone = false
    private var installationBox = Dictionary<IdentityKey,Symbol>()
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
        
    public func queueOnBox(_ symbol: Symbol)
        {
        self.installationBox[symbol.index] = symbol
        }
        
    public func layoutObjectSlots(withArgonModule argonModule: ArgonModule)
        {
        var offset = 0
        for slot in self.allSymbols.compactMap({$0 as? Slot}).sorted(by: {$0.label < $1.label})
            {
            slot.offset = offset
            offset += Argon.kWordSizeInBytesInt
            }
        }

    public func emitCode(using generator: CodeGenerator) throws -> Module
        {
        for symbol in self.allSymbols
            {
            if symbol.label == "testSomeDates"
                {
                print("halt")
                }
            try symbol.emitCode(using: generator)
            }
        return(self)
        }
    
    public override var typeCode:TypeCode
        {
        .module
        }
        
    public var allClasses: TypeClasses
        {
        var classes = TypeClasses()
        for module in self.allModules
            {
            classes.append(contentsOf: module.classes)
            }
        return(classes.sorted{$0.label < $1.label})
        }
        
    public var allEnumerations: TypeEnumerations
        {
        var enumerations = TypeEnumerations()
        for module in self.allModules
            {
            enumerations.append(contentsOf: module.allEnumerations)
            }
        return(enumerations.sorted{$0.label < $1.label})
        }
        
    public var allModules: Modules
        {
        var modules = Modules()
        for module in self.allSymbols.compactMap({$0 as? Module})
            {
            modules.append(module)
            modules.append(contentsOf: module.allModules)
            }
        return(modules)
        }
        
    public var classes:TypeClasses
        {
        Array(self.allSymbols.compactMap{$0 as? TypeClass})
        }
        
    public var enumerations:TypeEnumerations
        {
        var classes = Array(self.allSymbols.compactMap{$0 as? TypeEnumeration})
        classes += self.allSymbols.compactMap{($0 as? Module)?.enumerations}.flatMap{$0}
        return(classes)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = ArgonModule.shared.moduleType
        for symbol in self.allSymbols
            {
            symbol.initializeType(inContext: context)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for symbol in self.allSymbols
            {
            symbol.initializeTypeConstraints(inContext: context)
            }
        }

    public override var iconName: String
        {
        "IconModule"
        }
        
    public override var iconTint: NSColor
        {
        NSColor.argonNeonPink
        }
        
    public func dumpMethods()
        {
//        for method in self.allSymbols.flatMap({$0 as? Method})
//            {
//            method.dump()
//            }
        for module in self.allSymbols.compactMap({$0 as? Module})
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
        symbol.setModule(self)
//        symbol.container = .module(self)
        }
        
    public func slotWithLabel(_ label: Label) -> Slot?
        {
        for symbol in self.allSymbols
            {
            if symbol is Slot && symbol.label == label
                {
                return(symbol as! Slot)
                }
            }
        return(nil)
        }
        
//    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
//        {
//        let count = self.allSymbols.count
//        var text = ""
//        if count == 0
//            {
//            }
//        else if count == 1
//            {
//            text = "1 child"
//            }
//        else
//            {
//            text = "\(count) children"
//            }
//        leaderCell.textField?.stringValue = text
//        }
//        
//    public override func isElement(ofType: Group.ElementType) -> Bool
//        {
//        return(true)
//        }
        
    public func lookupSlot(label: String) -> Slot?
        {
        for symbol in self.allSymbols where symbol.label == label
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
        for aSymbol in self.allSymbols
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
        
    public override func inferType()
        {
        for symbol in self.allSymbols
            {
            symbol.inferType()
            }
        }
        
    public func typeCheckModule() -> Module?
        {
            let typeContext = TypeContext()
            var temporarySymbols = Symbols()
            let newModule = Self(label: self.label)
            TypeContext.initialSubstitution.symbols[newModule.argonHash] = newModule
            TypeContext.initialSubstitution.symbols[ArgonModule.shared.argonHash] = ArgonModule.shared
            for symbol in self.allSymbols
                {
                symbol.initializeType(inContext: typeContext)
                let newSymbol = symbol.freshTypeVariable(inContext: typeContext)
                newSymbol.initializeTypeConstraints(inContext: typeContext)
                temporarySymbols.append(newSymbol)
                }
            let substitution = typeContext.unify()
            for symbol in temporarySymbols
                {
                newModule.addSymbol(substitution.substitute(symbol))
                }
            for symbol in newModule.allSymbols
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
        newModule.setMemoryAddress(self.memoryAddress)
        return(newModule)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? Module
            {
            return(self.label == second.label && self.module == second.module && self.allSymbols == second.allSymbols)
            }
        return(super.isEqual(object))
        }
        
    public func moduleWithOptimization(using: Optimizer) -> Module?
        {
        return(self)
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
        for symbol in self.allSymbols
            {
            symbol.layoutObjectSlots()
            }
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        do
            {
            for symbol in self.allSymbols
                {
                symbol.allocateAddresses(using: allocator)
                AddressTable[symbol.index] = symbol.memoryAddress
                }
            for aStatic in Argon.staticTable
                {
                try aStatic.allocateAddresses(using: allocator)
                }
            self.layoutInMemory(using: allocator)
            }
        catch let error as CompilerIssue
            {
            self.appendIssue(error)
            }
        catch let error
            {
            self.appendIssue(at: .zero, message: "Unexpected error: \(error)")
            }
        }
        
    public func createSystemMethods(for type: Type)
        {
        if type.isSetClass
            {
            self.createSetMethods(for: type)
            }
        else if type.isListClass
            {
            self.createListMethods(for: type)
            }
        else if type.isArrayClass
            {
            self.createArrayMethods(for: type)
            }
        else if type.isDictionaryClass
            {
            self.createDictionaryMethods(for: type)
            }
        else if type.isBitSetClass
            {
            self.createBitSetMethods(for: type)
            }
        }
        
    private func createListMethods(for type: Type)
        {
        let listClass = type as! TypeClass
        guard listClass.generics.count > 0 else
            {
            return
            }
        let elementType = listClass.generics[0]
        let listNodeClass = self.lookup(label: "ListNode") as! TypeClass
        let thisNodeClass = listNodeClass.withGenerics([elementType])
        let slot = ClassSlot(label: "ListNodeClass",type: listNodeClass)
//        slot.value = .type(thisNodeClass)
        listClass.addClassSlot(slot)
        var method = InlineMethodInstance(label: "append",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "to", relabel: nil, type: listClass, isVisible: true, isVariadic: false)],returnType: ArgonModule.shared.void).listInsertMethod()
        var signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "remove",parameters: [Parameter(label: "element", relabel: nil, type: listClass, isVisible: false, isVariadic: false),Parameter(label: "from", relabel: nil, type: listClass, isVisible: true, isVariadic: false)],returnType: elementType).listRemoveMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "contains",parameters: [Parameter(label: "list", relabel: nil, type: listClass, isVisible: false, isVariadic: false),Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false)],returnType: ArgonModule.shared.boolean).listContainsMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "insert",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "after", relabel: nil, type: elementType, isVisible: true, isVariadic: false),Parameter(label: "in", relabel: nil, type: listClass, isVisible: true, isVariadic: false)],returnType: elementType).listInsertAfterMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "insert",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "before", relabel: nil, type: elementType, isVisible: true, isVariadic: false),Parameter(label: "in", relabel: nil, type: listClass, isVisible: true, isVariadic: false)],returnType: elementType).listInsertBeforeMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "insert",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "in", relabel: nil, type: listClass, isVisible: true, isVariadic: false)],returnType: elementType).listInsertMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        }
        
    private func createArrayMethods(for type: Type)
        {
        let arrayClass = type as! TypeClass
        guard arrayClass.generics.count > 0 else
            {
            return
            }
        let elementType = arrayClass.generics[0]
        var method = InlineMethodInstance(label: "insert",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "at", relabel: nil, type: ArgonModule.shared.integer, isVisible: true, isVariadic: false),Parameter(label: "in", relabel: nil, type: arrayClass, isVisible: true, isVariadic: false)],returnType: ArgonModule.shared.void).arrayInsertMethod()
        var signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "append",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "to", relabel: nil, type: arrayClass, isVisible: true, isVariadic: false)],returnType: ArgonModule.shared.void).arrayAppendMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "remove",parameters: [Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false),Parameter(label: "from", relabel: nil, type: arrayClass, isVisible: true, isVariadic: false)],returnType: ArgonModule.shared.void).arrayRemoveMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "contains",parameters: [Parameter(label: "array", relabel: nil, type: arrayClass, isVisible: false, isVariadic: false),Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false)],returnType: ArgonModule.shared.boolean).arrayContainsMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "append",parameters: [Parameter(label: "array1", relabel: nil, type: arrayClass, isVisible: false, isVariadic: false),Parameter(label: "array2", relabel: nil, type: arrayClass, isVisible: false, isVariadic: false)],returnType: arrayClass).arrayAppendArrayMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        }
        
    private func createDictionaryMethods(for type: Type)
        {
        }
        
    private func createBitSetMethods(for type: Type)
        {
        }
        
    private func createSetMethods(for type: Type)
        {
        let setClass = type as! TypeClass
        guard setClass.generics.count > 0 else
            {
            return
            }
        let elementType = setClass.generics[0]
        var method = InlineMethodInstance(label: "insert",parameters: [Parameter(label: "set", relabel: nil, type: setClass, isVisible: false, isVariadic: false),Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false)],returnType: ArgonModule.shared.void).setInsertMethod()
        var signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "remove",parameters: [Parameter(label: "set", relabel: nil, type: setClass, isVisible: false, isVariadic: false),Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false)],returnType: elementType).setRemoveMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "contains",parameters: [Parameter(label: "set", relabel: nil, type: setClass, isVisible: false, isVariadic: false),Parameter(label: "element", relabel: nil, type: elementType, isVisible: false, isVariadic: false)],returnType: ArgonModule.shared.boolean).setContainsMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "union",parameters: [Parameter(label: "set1", relabel: nil, type: setClass, isVisible: false, isVariadic: false),Parameter(label: "set2", relabel: nil, type: setClass, isVisible: false, isVariadic: false)],returnType: setClass).setUnionMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        method = InlineMethodInstance(label: "intersection",parameters: [Parameter(label: "set1", relabel: nil, type: setClass, isVisible: false, isVariadic: false),Parameter(label: "set2", relabel: nil, type: setClass, isVisible: false, isVariadic: false)],returnType: setClass).setIntersectionMethod()
        signature = method.methodSignature
        if !self.hasMethod(withSignature: signature)
            {
            self.addSymbol(method)
            }
        }
        
    public func matchingTypeOrType(_ type: Type) -> Type
        {
        for typeSymbol in self.allSymbols.compactMap({$0 as? Type})
            {
            if type.isEqual(typeSymbol)
                {
                return(typeSymbol)
                }
            }
        return(type)
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
        let addresses = self.allSymbols.map{$0.memoryAddress}
        let symbolsSize = addresses.count + 100
        let symbolArray = segment.allocateArray(size: symbolsSize,elements: addresses)
        modulePointer.setAddress(symbolArray,atSlot: "symbols")
        modulePointer.setBoolean(self is SystemModule,atSlot: "isSystemType")
        modulePointer.setBoolean(self is TopModule,atSlot: "isTopModule")
        modulePointer.setBoolean(self is ArgonModule,atSlot: "isArgonModule")
        modulePointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
        let moduleSlots = self.allSymbols.compactMap{$0 as? ModuleSlot}
        moduleSlots.forEach{$0.layoutInMemory(using: allocator)}
        modulePointer.setAddress(segment.allocateArray(size: moduleSlots.count,elements: moduleSlots.map{$0.memoryAddress}),atSlot: "slots")
        ////
        /// Now lay out each of the symsols in a module
        ///
        for symbol in self.allSymbols
            {
            symbol.layoutInMemory(using: allocator)
            }
        }
        
    public override func emitValueCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let temporary = buffer.nextTemporary
        buffer.add(.MOVE,.address(self.memoryAddress),temporary)
        self.place = temporary
        }
        
    public override func emitAddressCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let temporary = buffer.nextTemporary
        buffer.add(.MOVE,.address(self.memoryAddress),temporary)
        self.place = temporary
        }
        
    public override func lookupType(label: Label) -> Type?
        {
        for symbol in self.allSymbols
            {
            if symbol.isType && symbol.label == label
                {
                return(symbol as? Type)
                }
            }
        return(self.module.lookupType(label: label))
        }
        
    public override func lookupMethod(label: Label) -> ArgonWorks.Method?
        {
        for symbol in self.allSymbols
            {
            if symbol.isMethod && symbol.label == label
                {
                return(symbol as? ArgonWorks.Method)
                }
            }
        return(self.module.lookupMethod(label: label))
        }
    }

public typealias Modules = Array<Module>
