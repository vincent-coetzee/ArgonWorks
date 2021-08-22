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
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols.valuesByKey
            {
            try symbol.emitCode(using: generator)
            }
        }

    public override func realize(using realizer: Realizer)
        {
        for symbol in self.symbols.valuesByKey
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
        var classes = Array(self.symbols.valuesByKey.compactMap{$0 as? Class})
        classes += self.symbols.valuesByKey.compactMap{($0 as? Module)?.classes}.flatMap{$0}
        return(classes)
        }
        
    public var methodInstances:MethodInstances
        {
        return(self.methods.flatMap{$0.instances})
        }
        
    public var methods:Methods
        {
        var methods = Array(self.symbols.valuesByKey.compactMap{$0 as? Method})
        methods += self.symbols.valuesByKey.compactMap{($0 as? Module)?.methods}.flatMap{$0}
        return(methods)
        }
        
    public var isSystemModule: Bool
        {
        return(false)
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
        for method in self.symbols.valuesByKey.flatMap({$0 as? Method})
            {
            method.dump()
            }
        for module in self.symbols.valuesByKey.compactMap({$0 as? Module})
            {
            module.dumpMethods()
            }
        }
        
    public func lookupSlot(label: String) -> Slot?
        {
        for symbol in self.symbols.valuesByKey
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
        for aSymbol in self.symbols.valuesByKey
            {
            if aSymbol.id == symbol.id
                {
                return(true)
                }
            }
        return(false)
        }
        
    internal func layout(in vm: VirtualMachine)
        {
        self.layoutSlots()
        self.layoutInMemory(in: vm)
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
