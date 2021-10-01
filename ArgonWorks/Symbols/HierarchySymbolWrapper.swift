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
        
        
    public var selectionColor: NSColor
        {
        get
            {
            if self._selectionColor.isNil
                {
                return(self.defaultColor)
                }
            return(self._selectionColor!)
            }
        set
            {
            self._selectionColor = newValue
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
        
    public var isContainerSymbol: Bool
        {
        if self.isGroup
            {
            return(false)
            }
        let symbol = self.symbols.first!
        if symbol.isModule || symbol.isSymbolGroup
            {
            return(true)
            }
        return(false)
        }
        
    public var childCount: Int
        {
        return(self.children.count)
        }
        
    public var defaultColor: NSColor
        {
        if self.isGroup || self.symbols.first!.isModule || self.symbols.first!.isSymbolGroup
            {
            if self.symbols.count == 0
                {
                return(NSColor.argonCoral)
                }
            return(NSColor.argonNeonOrange)
            }
        else
            {
            if self.isSlot
                {
                return(NSColor.argonThemeBlueGreen)
                }
            else
                {
                return(NSColor.argonNeonOrange)
                }
            }
        }
        
    private var isSlot: Bool
        {
        self.isGroup ? false : self.symbols.first!.isSlot
        }
        
    public let name: String
    public let isGroup: Bool
    public let symbols: Symbols
    public let type: GroupType
    private var _selectionColor: NSColor?
    
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
        cell.text.stringValue = self.displayString
        let image = NSImage(named: self.imageName)!
        image.isTemplate = true
        cell.icon.image = image
        var iconColor = NSColor.black
        var textColor = Palette.shared.hierarchyTextColor
        if self.isContainerSymbol
            {
            if self.childCount == 0
                {
                iconColor = .argonMidGray
                textColor = .argonMidGray
                self.selectionColor = .argonMidGray
                }
            else
                {
                iconColor = .argonNeonOrange
                }
            }
        else
            {
            if self.isSlot
                {
                iconColor = NSColor.argonThemeBlueGreen
                }
            else
                {
                iconColor = NSColor.argonNeonOrange
                }
            }
        cell.icon.contentTintColor = iconColor
        cell.text.textColor = textColor
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
