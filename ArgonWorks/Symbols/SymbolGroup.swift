//
//  SymbolGroup.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import AppKit

public class SymbolGroup:ContainerSymbol
    {
    public override var defaultColor: NSColor
        {
        NSColor.argonXCornflower
        }
        
    public override var imageName: String
        {
        "IconGroup"
        }
        
    ///
    ///
    /// Essentially make a SymbolGroup transparent so that
    /// it acts as though it is not there.
    ///
    /// 
    public override func lookup(label:String) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        for element in self.symbols
            {
            if let symbol = element.lookup(label: label)
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public override var isSystemContainer: Bool
        {
        return(true)
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
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        for element in self.symbols.filter{$0.isSystemContainer}
            {
            if let symbol = element.lookup(name:name)
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public override func directlyContains(symbol:Symbol) -> Bool
        {
        for aSymbol in self.symbols
            {
            if aSymbol.id == symbol.id
                {
                return(true)
                }
            if aSymbol.directlyContains(symbol: symbol)
                {
                return(true)
                }
            }
        return(false)
        }
    }
