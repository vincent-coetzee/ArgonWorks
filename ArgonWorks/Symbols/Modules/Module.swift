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
    public override var isModule: Bool
        {
        return(true)
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
        
    public override var children: Array<Symbol>?
        {
        let modules = self.symbols.filter{$0 is Module}
        let methods = self.symbols.filter{$0 is Method}.sorted{$0.label < $1.label}
        let groups = self.symbols.filter{$0 is SymbolGroup}.sorted{$0.label < $1.label}
        return(modules + groups + methods)
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

    public override var imageName: String
        {
        "IconTest"
        }
        
    public override var symbolColor: NSColor
        {
        .argonNeonOrange
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
