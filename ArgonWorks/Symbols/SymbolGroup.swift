//
//  SymbolGroup.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import Foundation

public class SymbolGroup:ContainerSymbol
    {
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
        if let symbol = self.symbols[label]
            {
            return(symbol)
            }
        for element in self.symbols.values
            {
            if let symbol = element.lookup(label: label)
                {
                return(symbol)
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
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        for element in self.symbols.values
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
        for aSymbol in self.symbols.values
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
