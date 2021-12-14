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
    public var enclosingBlockContext: BlockContext
        {
        fatalError()
        }
        
    public var isBlockContextScope: Bool
        {
        false
        }
        
    public var isSlotScope: Bool
        {
        false
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
        
    public override var enclosingScope: Scope
        {
        self.parent.enclosingScope
        }
        
    public var isMainModule: Bool
        {
        false
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
        
    public var firstMainMethod: Method?
        {
        return(self.firstMainModule?.mainMethod)
        }
        
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        return(LiteralExpression(.module(self)))
        }
        
    public override var isModule: Bool
        {
        return(true)
        }
        
    private var imports: Array<Importer> = []
    
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
        self.type = TypeModule(module: self)
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
        
    public var classes:Classes
        {
        var classes = Array(self.symbols.compactMap{$0 as? Class})
        classes += self.symbols.compactMap{($0 as? Module)?.classes}.flatMap{$0}
        return(classes)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.type = (self.enclosingScope.lookup(label: "Module") as! Type)
        for symbol in self.symbols
            {
            try symbol.initializeType(inContext: context)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for symbol in self.symbols
            {
            try symbol.initializeTypeConstraints(inContext: context)
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
        
    public override func lookup(index: UUID) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.index == index
                {
                return(symbol)
                }
            if let found = symbol.lookup(index: index)
                {
                return(found)
                }
            }
        return(nil)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let symbol = super.lookup(label: label)
            {
            return(symbol)
            }
        for anImport in self.imports
            {
            if let symbol = anImport.lookup(label: label)
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        if symbol is Importer
            {
            self.imports.append(symbol as! Importer)
            }
        super.addSymbol(symbol)
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
            if aSymbol.id == symbol.id
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func moduleWithEmittedCode(using: CodeGenerator) -> Module?
        {
        return(nil)
        }
        
    public func moduleWithAllocatedAddresses(using: AddressAllocator) throws -> Module
        {
        for symbol in self.symbols
            {
            try symbol.allocateAddresses(using: using)
            }
        return(self)
        }

    public func typeCheckModule() throws -> Self
        {
            let typeContext = TypeContext(scope: self.enclosingScope)
            let newModule = Self(label: self.label)
            for symbol in self.symbols
                {
                try symbol.initializeType(inContext: typeContext)
                try symbol.initializeTypeConstraints(inContext: typeContext)
                }
            let substitution = typeContext.unify()
            for symbol in self.symbols
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
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        let allMethods = self.symbols.filter{$0 is MethodInstance}
        }
    }

public typealias Modules = Array<Module>
