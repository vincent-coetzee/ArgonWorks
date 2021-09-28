//
//  HierarchySymbolWrapper.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/9/21.
//

import AppKit

public class HierarchySymbolWrapper
    {
    public enum GroupType
        {
        case `class`
        case enumeration
        case constant
        case method
        case type
        
        public func matchesSymbol(_ symbol: Symbol) -> Bool
            {
            switch(self)
                {
                case .class:
                    return(symbol is Class || symbol is Slot || symbol is Module || symbol is SymbolGroup)
                case .enumeration:
                    return(symbol is Enumeration || symbol is EnumerationCase || symbol is Module || symbol is SymbolGroup)
                case .constant:
                    return(symbol is Constant || symbol is Module || symbol is SymbolGroup)
                case .method:
                    return(symbol is Method || symbol is Function || symbol is Module || symbol is SymbolGroup)
                case .type:
                    return(symbol is TypeAlias || symbol is Module || symbol is SymbolGroup)
                }
            }
        }
        
    public var children: HierarchySymbolWrappers
        {
        if self.isGroup
            {
            return(self.symbols.map{HierarchySymbolWrapper(symbol: $0,type: self.type)}.sorted{$0.name<$1.name})
            }
        else
            {
            return(self.symbols.first!.allChildren.filter{self.type.matchesSymbol($0)}.map{HierarchySymbolWrapper(symbol: $0,type: self.type)})
            }
        }
        
    public var isSystemSymbol: Bool
        {
        return(!self.isGroup && self.symbols.first!.isSystemSymbol)
        }
        
    public var imageName: String
        {
        if self.isGroup
            {
            return("IconGroup")
            }
        else
            {
            return(self.symbols.first!.imageName)
            }
        }
        
    public var isExpandable: Bool
        {
        if self.isGroup && self.symbols.count > 0
            {
            return(true)
            }
        else if !self.isGroup && self.children.count > 0
            {
            return(true)
            }
        return(false)
        }
        
    public var displayString: String
        {
        if self.isGroup
            {
            return(self.name)
            }
        else
            {
            return(self.symbols.first!.displayString)
            }
        }
        
    public var defaultColor: NSColor
        {
        if self.isGroup
            {
            return(Palette.shared.sunnyScheme.mid)
            }
        else
            {
            let symbol = self.symbols.first!
            if symbol.isSystemSymbol
                {
                return(Palette.shared.sunnyScheme.light)
                }
            else if (symbol is Module || symbol is SymbolGroup) && self.children.count == 0
                {
                return(Palette.shared.sunnyScheme.dark)
                }
            return(symbol.defaultColor)
            }
        }
        
    public let name: String
    public let isGroup: Bool
    public let symbols: Symbols
    public let type: GroupType
    
    init(groupNamed: String,symbols: Array<Symbol>,type: GroupType)
        {
        self.isGroup = true
        self.name = groupNamed
        self.symbols = symbols
        self.type = type
        }
        
    init(symbol: Symbol,type: GroupType)
        {
        self.isGroup = false
        self.name = symbol.label
        self.symbols = [symbol]
        self.type = type
        }
        
    public func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        var newColor = foregroundColor ?? self.defaultColor
        if !self.isGroup
            {
            let symbol = self.symbols.first!
            if symbol is Module || symbol is SymbolGroup
                {
                let kids = symbol.allChildren.filter{self.type.matchesSymbol($0)}
                if kids.count == 0
                    {
                    newColor = NSColor.argonPapayaWhip
                    }
                }
            }
        cell.text.stringValue = self.displayString
        let image = NSImage(named: self.imageName)!
        image.isTemplate = true
        cell.icon.image = image
        cell.icon.contentTintColor = newColor
        cell.text.textColor = newColor
        }

    public func invert(cell: HierarchyCellView)
        {
        let image = NSImage(named: self.imageName)!.image(withTintColor: NSColor.black)
        cell.icon.image = image
        cell.icon.contentTintColor = NSColor.black
        cell.icon.isHighlighted = false
        cell.text.textColor = NSColor.black
        }
        
    public func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        leaderCell.textField?.stringValue = ""
        if self.isGroup && self.symbols.count > 0
            {
            let text = self.symbols.count == 1 ? "1 item" : "\(self.symbols.count) items"
            leaderCell.textField?.stringValue = text
            }
        else if !self.isGroup
            {
            let kids = self.children
            let symbol = self.symbols.first!
            let kidNames = symbol.childName
            if symbol is Module || symbol is SymbolGroup || symbol is Class || symbol is Enumeration
                {
                if kids.count == 1
                    {
                    leaderCell.textField?.stringValue = "1 " + kidNames.0
                    }
                else if kids.count > 0
                    {
                    leaderCell.textField?.stringValue = "\(kids.count) \(kidNames.1)"
                    }
                }
            }
        }
    }

public typealias HierarchySymbolWrappers = Array<HierarchySymbolWrapper>
