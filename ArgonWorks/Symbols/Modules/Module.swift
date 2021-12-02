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
        return(self)
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
    
    public required init(label: Label)
        {
        super.init(label: label)
        self._type = Type()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE MODULE")
        self.imports = coder.decodeObject(forKey: "imports") as! Array<Importer>
        super.init(coder: coder)
//        print("END DECODE MODULE \(self.label)")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.imports,forKey: "imports")
        super.encode(with: coder)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols
            {
            try symbol.emitCode(using: generator)
            }
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
        
    public var methodInstances:MethodInstances
        {
        return(self.methods.flatMap{$0.instances})
        }
        
    public var methods:Methods
        {
        var methods = Array(self.symbols.compactMap{$0 as? Method})
        methods += self.symbols.compactMap{($0 as? Module)?.methods}.flatMap{$0}
        return(methods)
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
        
    public override func allocateAddresses(using: AddressAllocator)
        {
        for aClass in self.classes
            {
            aClass.allocateAddresses(using: using)
            }
        self.layoutInMemory()
        }

    public func checkTypes() -> Module
        {
        do
            {
            let typeContext = TypeContext(scope: self.enclosingScope)
            for node in self.symbols
                {
                try node.initializeType(inContext: typeContext)
                try node.initializeTypeConstraints(inContext: typeContext)
                }
            let substitution = typeContext.unify()
            return(substitution.substitute(self) as! Module)
            }
        catch let error as CompilerIssue
            {
            self.appendIssue(error)
            print(error)
            }
        catch let error
            {
            self.appendIssue(CompilerIssue(location: self.declarationLocation,message: "Unexpected error: \(error)"))
            }
        return(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        do
            {
            for node in self.symbols
                {
                try node.initializeType(inContext: analyzer.typeContext)
                try node.initializeTypeConstraints(inContext: analyzer.typeContext)
                }
            let substitution = try analyzer.typeContext.unify()
            print(substitution)
            }
        catch let error as CompilerIssue
            {
            self.appendIssue(error)
            print(error)
            }
        catch let error
            {
            self.appendIssue(CompilerIssue(location: self.declarationLocation,message: "Unexpected error: \(error)"))
            }
        }
    }

public typealias Modules = Array<Module>
