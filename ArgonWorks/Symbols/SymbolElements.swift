//
//  SymbolWalker.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/9/21.
//

import AppKit

public class Group: Symbol
    {
    public enum ElementType
        {
        case none
        case `class`
        case enumeration
        case method
        case constant
        case type
        }

    public override var isExpandable: Bool
        {
        return(self.elements.count > 0)
        }
        
    public override var children: Symbols
        {
        let kids = self.elements.filter{$0.isElement(ofType: self.elementType)}.sorted{$0.label<$1.label}
        var newKids = Symbols()
        for kid in kids
            {
            if kid is Module
                {
                newKids.append(ModuleElement(symbol: kid,elementType: self.elementType))
                }
            else
                {
                switch(self.elementType)
                    {
                    case .class:
                        newKids.append(ClassElement(symbol: kid))
                    case .enumeration:
                        newKids.append(EnumerationElement(symbol: kid))
                    case .method:
                        newKids.append(MethodElement(symbol: kid))
                    case .constant:
                        newKids.append(ConstantElement(symbol: kid))
                    case .type:
                        newKids.append(TypeElement(symbol: kid))
                    default:
                        break
                    }
                }
            }
        return(newKids)
        }
        
    private let elements: Symbols
    private let elementType: ElementType
    
    public init(label:String,elements: Symbols,elementType: ElementType)
        {
        self.elements = elements
        self.elementType = elementType
        super.init(label: label)
        }
        
    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        let count = self.elements.count
        var text = ""
        if count == 0
            {
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
        
    public required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
        
 
    }

public class SymbolElement: Symbol
    {
    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        self.symbol.configure(leaderCell: leaderCell,foregroundColor: foregroundColor)
        }
        
    public override var imageName: String
        {
        return(self.symbol.imageName)
        }
        
    public override var isExpandable: Bool
        {
        return(self.symbol.isExpandable && self.children.count > 0)
        }
        
    public override var children: Symbols
        {
        return([])
        }
        
    internal let symbol: Symbol
    
    public init(symbol: Symbol)
        {
        self.symbol = symbol
        super.init(label: symbol.label)
        }
    
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        let color = self.symbol.isSystemSymbol ? Palette.shared.hierarchyBrowserSystemClassColor : (foregroundColor.isNil ? NSColor.argonStoneTerrace : foregroundColor!)
        self.symbol.configure(cell: cell,foregroundColor: color)
//        if self.symbol is Group || self.symbol is SymbolGroup
//            {
//            let count = self.children.count
//            }
        }
        
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    }
    
public class ClassElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        kids += symbols.filter{$0 is Class}
        return(kids.map{ClassElement(symbol: $0)}.sorted{$0.label<$1.label})
        }
    }

public class TypeElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        kids += symbols.filter{$0 is TypeAlias}
        return(kids.map{TypeElement(symbol: $0)}.sorted{$0.label<$1.label})
        }
    }

public class ModuleElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        return(kids.map{ModuleElement(symbol: $0,elementType: self.elementType)}.sorted{$0.label<$1.label})
        }
        
    private let elementType: Group.ElementType
    
    public init(symbol: Symbol,elementType: Group.ElementType)
        {
        self.elementType = elementType
        super.init(symbol: symbol)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
        
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        var color:NSColor
        let kids = self.children.filter{$0.isElement(ofType: self.elementType)}
        if kids.isEmpty
            {
            color = NSColor.argonXSmoke
            }
        else
            {
            color = self.symbol.isSystemSymbol ? Palette.shared.hierarchyBrowserSystemClassColor : (foregroundColor.isNil ? NSColor.argonStoneTerrace : foregroundColor!)
            }
        self.symbol.configure(cell: cell,foregroundColor: color)
        }
    }
    
public class MethodElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        kids += symbols.filter{$0 is Method || $0 is MethodInstance || $0 is Function}
        return(kids.map{MethodElement(symbol: $0)}.sorted{$0.label<$1.label})
        }
    }

public class ConstantElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        kids += symbols.filter{$0 is Constant}
        return(kids.map{ConstantElement(symbol: $0)}.sorted{$0.label<$1.label})
        }
    }

public class EnumerationElement: SymbolElement
    {
    public override var children: Symbols
        {
        let symbols = symbol.allChildren
        var kids = Symbols()
        kids += symbols.filter{$0 is Module || $0 is SymbolGroup}
        kids += symbols.filter{$0 is Enumeration}
        return(kids.map{EnumerationElement(symbol: $0)}.sorted{$0.label<$1.label})
        }
    }
