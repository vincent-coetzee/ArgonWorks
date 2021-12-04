//
//  SymbolGroup.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import AppKit

public class SymbolGroup:ContainerSymbol
    {
    public override var fullName: Name
        {
        return(self.parent.fullName)
        }
        
    public override var isSymbolGroup: Bool
        {
        return(true)
        }

    public override var iconName: String
        {
        "IconGroup"
        }
        
    public override var type: Type?
        {
        get
            {
            return(self.parent.type)
            }
        set
            {
            }
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
        
    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        let count = self.symbols.count
        var text = ""
        if count == 0
            {
            text = ""
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
        for element in self.symbols.filter({$0.isSystemContainer})
            {
            if let symbol = element.lookup(name:name)
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(true)
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

public class SystemSymbolGroup: SymbolGroup
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        let color =  foregroundColor.isNil ? Palette.shared.hierarchyBrowserSystemClassColor : foregroundColor!
        super.configure(cell: cell,foregroundColor: color)
        }
    }
