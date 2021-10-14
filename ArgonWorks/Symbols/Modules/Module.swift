//
//  Module.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
    
public class Module:ContainerSymbol
    {
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
        
    private var imports: Array<Import> = []
    
    public override init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        self.imports = coder.decodeObject(forKey: "imports") as! Array<Import>
        super.init(coder: coder)
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

    public override func realize(using realizer: Realizer)
        {
        for symbol in self.symbols
            {
            symbol.realize(using: realizer)
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
        for method in self.symbols.flatMap({$0 as? Method})
            {
            method.dump()
            }
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
        if symbol is Import
            {
            self.imports.append(symbol as! Import)
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
        
    internal func layout()
        {
        self.layoutSlots()
        self.layoutInMemory()
        }
        
    internal func layoutSlots()
        {
        print(self.classes)
        for aClass in self.classes
            {
            aClass.layoutObjectSlots()
            }
        }
    }

public typealias Modules = Array<Module>
