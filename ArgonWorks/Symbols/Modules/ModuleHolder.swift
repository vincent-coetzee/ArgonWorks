//
//  ModuleHolder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import AppKit

public class ModuleHolder: Module
    {
    public override var defaultColor:NSColor
        {
        NSColor.argonCheese
        }
    
    public override var imageName: String
        {
        self.module.imageName
        }
        
    public override var isExpandable: Bool
        {
        return(self.module.symbols.count > 0)
        }
        
    public override func children(forChildType type: ChildType) -> Array<Symbol>
        {
        return(self.children)
        }
        
    public override var children: Array<Symbol>
        {
        let kids = self.module.symbols.filter{$0 is Class || $0 is Enumeration || $0 is Module || $0 is Constant || $0 is TypeAlias || $0 is Function}.sorted{$0.label < $1.label}
        let values = kids.map{ElementHolder($0)}
        return(values)
        }
        
    private let module: Module
    
    init(_ module: Module)
        {
        self.module = module
        super.init(label: module.label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
 
        
    public override func invert(cell: HierarchyCellView)
        {
        super.invert(cell: cell)
        self.module.invert(cell: cell)
        }
        
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        self.module.configure(cell: cell,foregroundColor: foregroundColor.isNil ? self.defaultColor : foregroundColor!)
        }
    }


public class ElementHolder: Symbol
    {
    public override var defaultColor: NSColor
        {
        NSColor.argonCheese
        }
    
    public override var imageName: String
        {
        self.symbol.imageName
        }
        
    public override var isExpandable: Bool
        {
        return((self.symbol.isModule && (self.symbol as! Module).symbols.count > 0) || self.symbol.isEnumeration)
        }
        
    public override func children(forChildType type: ChildType) -> Array<Symbol>
        {
        return(self.children)
        }
        
    public override var children: Array<Symbol>
        {
        if self.symbol.isEnumeration
            {
            let items = (self.symbol as! Enumeration).children.map{ElementHolder($0)}
            return(items)
            }
        else if self.symbol is ContainerSymbol
            {
            let container = self.symbol as! ContainerSymbol
            let kids = container.symbols.filter{$0 is Class || $0 is Enumeration || $0 is Module || $0 is Constant || $0 is TypeAlias || $0 is Function}.sorted{$0.label<$1.label}
            var values = kids.map{ElementHolder($0)}
            if self.symbol.isClass
                {
                values.append(contentsOf: (self.symbol as! Class).subclasses.map{ElementHolder($0)})
                }
            return(values)
            }
        return([])
        }
        
    internal let symbol: Symbol
    
    init(_ symbol: Symbol)
        {
        self.symbol = symbol
        super.init(label: symbol.label)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
        
    public override func invert(cell: HierarchyCellView)
        {
        self.symbol.invert(cell: cell)
        }
        
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        self.symbol.configure(cell: cell,foregroundColor: foregroundColor.isNil ? self.defaultColor : foregroundColor!)
        }
}
