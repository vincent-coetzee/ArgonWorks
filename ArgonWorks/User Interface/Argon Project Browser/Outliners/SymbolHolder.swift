//
//  SymbolHolder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa


        
public class SymbolHolder: OutlineItem
    {
    public var identityKey: Int
        {
        self.symbol.identityHash
        }
        
    public var isSystemItem: Bool
        {
        self.symbol.isSystemType
        }
        
    public var iconTint: NSColor
        {
        if self.symbol is TypeClass
            {
            return(SyntaxColorPalette.classColor)
            }
        else if self.symbol is TypeEnumeration || self.symbol is EnumerationCase
            {
            return(SyntaxColorPalette.enumerationColor)
            }
        else if self.symbol is Method || self.symbol is MethodInstance
            {
            return(SyntaxColorPalette.methodColor)
            }
        else if self.symbol is TypeAlias
            {
            return(SyntaxColorPalette.typeColor)
            }
        else if self.symbol is Constant
            {
            return(SyntaxColorPalette.constantColor)
            }
        else if symbol is Slot
            {
            return(SyntaxColorPalette.slotColor)
            }
        else if symbol is Module
            {
            return(SyntaxColorPalette.identifierColor)
            }
        else
            {
            return(NSColor.white)
            }
        }
    
    public var childCount: Int
        {
        self.children.count
        }
        
    private var children: Symbols
        {
        self.context.children(forSymbol: self.symbol)
        }
        
    public var labels: Array<Label>
        {
        self.children.map{$0.label}
        }
        
    public var label: String
        {
        self.symbol.displayName
        }
        
    public var icon: NSImage
        {
        let image = self._icon
        image.isTemplate = true
        return(image)
        }
        
    private var _icon: NSImage
        {
        if self.symbol is TypeClass
            {
            return(NSImage(named: "IconClass")!)
            }
        else if self.symbol is TypeEnumeration
            {
            return(NSImage(named: "IconEnumeration")!)
            }
        else if self.symbol is Method || self.symbol is MethodInstance
            {
            return(NSImage(named: "IconMethod")!)
            }
        else if self.symbol is TypeAlias
            {
            return(NSImage(named: "IconType")!)
            }
        else if self.symbol is Constant
            {
            return(NSImage(named: "IconConstant")!)
            }
        else if self.symbol is Slot || self.symbol is EnumerationCase
            {
            return(NSImage(named: "IconSlot")!)
            }
        else if self.symbol is Module
            {
            return(NSImage(named: "IconModule")!)
            }
        else
            {
            return(NSImage(named: "IconEmpty")!)
            }
        }
        
    public var isExpandable: Bool
        {
        self.context.isSymbolExpandable(self.symbol)
        }
        
    public var symbol: Symbol
    private var symbolChildren: Symbols?
    private let context: OutlinerContext
    public unowned var parentItem: OutlineItem?
    
    init(symbol: Symbol,context: OutlinerContext,parent: OutlineItem? = nil)
        {
        self.symbol = symbol
        self.context = context
        self.parentItem = parent
        }
        
    public func child(atIndex: Int) -> OutlineItem
        {
        return(SymbolHolder(symbol: self.children[atIndex],context: self.context,parent: self))
        }
        
    public func makeView(for outliner: Outliner) -> OutlineItemNSView
        {
        let view = ConcreteOutlineItemView(frame: .zero)
        view.outlineItem = self
        return(view)
        }
        
    public func insertionIndex(forSymbol: Symbol) -> Int
        {
        return(self.labels.firstIndex(of: forSymbol.label)!)
        }
    }
