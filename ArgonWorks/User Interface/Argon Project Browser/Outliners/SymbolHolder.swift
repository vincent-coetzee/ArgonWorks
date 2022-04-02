//
//  SymbolHolder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa
        
public class SymbolHolder: NSObject,NSCoding,OutlineItem
    {
    public var identityKey: Int
        {
        self.symbol.identityHash
        }
        
    public var isSystemItem: Bool
        {
        self.symbol.isSystemType
        }
        
    public var textColorIdentifier: StyleIdentifier
        {
        .textColor
        }
        
    public var iconTintIdentifier: StyleIdentifier
        {
        if self.symbol is TypeClass
            {
            return(.classColor)
            }
        else if self.symbol is TypeEnumeration || self.symbol is EnumerationCase
            {
            return(.enumerationColor)
            }
        else if self.symbol is Method || self.symbol is MethodInstance
            {
            return(.methodColor)
            }
        else if self.symbol is TypeAlias
            {
            return(.typeColor)
            }
        else if self.symbol is Constant
            {
            return(.constantColor)
            }
        else if symbol is Slot
            {
            return(.slotColor)
            }
        else if symbol is Module
            {
            return(.identifierColor)
            }
        else
            {
            return(.defaultColor)
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
    public var isExpanded = false
    
    public required init?(coder: NSCoder)
        {
        self.context = OutlinerContext(rawValue: coder.decodeInteger(forKey: "context"))!
        self.parentItem = coder.decodeObject(forKey: "parentItem") as? OutlineItem
        self.isExpanded = coder.decodeBool(forKey: "isExpanded")
        self.symbol = TopModule.shared.lookup(name: coder.decodeName(forKey: "symbolName"))!
        }
        
    init(symbol: Symbol,context: OutlinerContext,parent: OutlineItem? = nil)
        {
        self.symbol = symbol
        self.context = context
        self.parentItem = parent
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.context.rawValue,forKey: "context")
        coder.encode(self.parentItem,forKey: "parentItem")
        coder.encode(self.isExpanded,forKey: "isExpanded")
        coder.encodeName(self.symbol.fullName,forKey: "symbolName")
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
