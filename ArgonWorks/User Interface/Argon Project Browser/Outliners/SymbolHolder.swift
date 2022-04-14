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
        
    public var textColorIdentifier: StyleColorIdentifier
        {
        .textColor
        }
        
    public var iconTintIdentifier: StyleColorIdentifier
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
        
    private var children: Array<SymbolHolder>
        {
        if self.isExpandable
            {
            if self.holderKids.isNil
                {
                self.holderKids = self.context.children(forSymbol: self.symbol).map{SymbolHolder(symbol: $0,context: self.context,parent: self)}
                }
            }
        else
            {
            self.holderKids = []
            }
        return(self.holderKids!)
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
    private var holderKids: Array<SymbolHolder>?
    private let context: OutlinerContext
    public unowned var parentItem: OutlineItem?
    public var isExpanded = false
    
    public required init?(coder: NSCoder)
        {
        self.context = OutlinerContext(rawValue: coder.decodeInteger(forKey: "context"))!
        self.parentItem = coder.decodeObject(forKey: "parentItem") as? OutlineItem
        self.isExpanded = coder.decodeBool(forKey: "isExpanded")
        self.symbol = coder.decodeObject(forKey: "symbol") as! Symbol
        self.holderKids = coder.decodeObject(forKey: "kids") as? Array<SymbolHolder>
        }
        
    init(symbol: Symbol,context: OutlinerContext,parent: OutlineItem? = nil)
        {
        self.symbol = symbol
        self.context = context
        self.parentItem = parent
        }
        
    public func expandIfNeeded(inOutliner outliner: NSOutlineView)
        {
        if self.isExpanded
            {
            outliner.expandItem(self)
            if self.childCount > 0
                {
                for item in self.children
                    {
                    item.expandIfNeeded(inOutliner: outliner)
                    }
                }
            }
        }
        
    public func invalidateChildren()
        {
        self.holderKids = nil
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.context.rawValue,forKey: "context")
        coder.encode(self.parentItem,forKey: "parentItem")
        coder.encode(self.isExpanded,forKey: "isExpanded")
        coder.encode(self.symbol,forKey: "symbol")
        coder.encode(self.holderKids,forKey: "kids")
        }
        
    public func child(atIndex: Int) -> OutlineItem
        {
        self.children[atIndex]
        }
        
    public func makeView(for outliner: Outliner) -> OutlineItemNSView
        {
        let view = ConcreteOutlineItemView(frame: .zero)
        view.outlineItem = self
        return(view)
        }
        
    public func insertionIndex(forSymbol: Symbol) -> Int
        {
        if let index = self.labels.firstIndex(of: forSymbol.label)
            {
            return(index)
            }
        return(0)
        }
        
    public override func isEqual(to: Any?) -> Bool
        {
        if let other = to as? SymbolHolder
            {
            return(other.symbol.identityHash == self.symbol.identityHash)
            }
        return(false)
        }
    }

public typealias SymbolHolders = Array<SymbolHolder>
