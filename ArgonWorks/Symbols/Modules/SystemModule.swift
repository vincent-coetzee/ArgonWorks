//
//  SystemModule.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation

public class SystemModule: Module
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        .systemModule
        }
        
    public override var isSystemModule: Bool
        {
        return(true)
        }
        
    public override var isSystemContainer: Bool
        {
        return(true)
        }
        
    public var subModules: Modules
        {
        return(self.symbols.compactMap{$0 as? SystemModule})
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let symbol = self.symbolsByLabel[label]
            {
            return(symbol)
            }
        for module in self.subModules
            {
            if let value = module.lookup(label: label)
                {
                return(value)
                }
            }
        return(nil)
        }
        
    public override func lookup(name:Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        if name.isRooted
            {
            if let context = self.primaryContext.lookup(label: name.first)
                {
                return(context.lookup(name: name.withoutFirst))
                }
            return(nil)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        for module in self.symbols.filter({$0.isSystemContainer})
            {
            if let symbol = module.lookup(name: name)
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    internal override func layout()
        {
        self.layoutSlots()
        for aModule in self.symbols.compactMap({$0 as? SystemModule})
            {
            aModule.layout()
            }
        self.layoutInMemory()
        }
        
    internal func resolveReferences(topModule: TopModule)
        {
        for symbol in self.symbols
            {
            if let aClass = symbol as? Class
                {
                aClass.realizeSuperclasses(topModule: topModule)
                }
            else if let aModule = symbol as? SystemModule
                {
                print("RESOLVING MODULE \(aModule.label)")
                aModule.resolveReferences(topModule: topModule)
                }
            }
        }
    }
