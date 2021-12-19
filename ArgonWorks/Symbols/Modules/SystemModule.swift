//
//  SystemModule.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation

public class SystemModule: Module
    {
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
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
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        for symbol in self.symbols where symbol is SystemModule || symbol is SymbolGroup
            {
            if let innerSymbol = symbol.lookup(label: label)
                {
                return(innerSymbol)
                }
            }
        return(nil)
        }
    }
