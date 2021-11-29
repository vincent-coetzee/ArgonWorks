//
//  ContainerSymbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import Collections

public class ContainerSymbol:Symbol
    {
    public override var allNamedInvokables: Array<NamedInvokable>
        {
        var buffer = Array<NamedInvokable>()
        for symbol in self.symbols
            {
            if symbol is Invocable
                {
                buffer.append(NamedInvokable(fullName: symbol.fullName, invokable: symbol as! Invocable))
                }
            else
                {
                buffer.append(contentsOf: symbol.allNamedInvokables)
                }
            }
        return(buffer)
        }
        
    public override var allImportedSymbols: Symbols
        {
        var importedSymbols = Symbols()
        for symbol in self.symbolsByLabel.values
            {
            if symbol.isImported
                {
                importedSymbols.append(symbol)
                }
            importedSymbols.append(contentsOf: symbol.allImportedSymbols)
            }
        return(importedSymbols)
        }
        
    internal var symbols: Symbols
        {
        Array(self.symbolsByLabel.values)
        }
        
    public override var isGroup: Bool
        {
        return(true)
        }
        
    internal var symbolsByLabel = OrderedDictionary<Label,Symbol>()
    
    public override var isExpandable: Bool
        {
        return(self.symbols.count > 0)
        }
        
    public override var childCount: Int
        {
        return(self.children.count)
        }
        
    public override var isSymbolContainer: Bool
        {
        return(true)
        }
        
    public override var allChildren: Symbols
        {
        return(Array(self.symbols))
        }
        
    public override var children: Symbols
        {
        return(self.symbols.sorted{$0.label < $1.label})
        }
        
    public var classesWithNotDirectlyContainedSuperclasses:Classes
        {
        var classes = self.symbols.filter{$0 is Class}.map{$0 as! Class}
        classes = classes.filter{$0.localSuperclasses.isEmpty}
        for aClass in self.symbols.filter({$0 is Class}).map({$0 as! Class})
            {
            for superclass in aClass.localSuperclasses
                {
                if !self.directlyContains(symbol: superclass)
                    {
                    classes.append(aClass)
                    }
                }
            }
        return(classes)
        }
        
    public required init?(coder: NSCoder)
        {
        self.symbolsByLabel = coder.decodeObject(forKey: "symbolsByLabel") as! OrderedDictionary<Label,Symbol>
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
    
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.symbolsByLabel,forKey: "symbolsByLabel")
        }
    ///
    ///
    /// Support for naming context
    ///
    ///
    public override func lookup(label:String) -> Symbol?
        {
        if let symbol = self.symbolsByLabel[label]
            {
            return(symbol)
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func removeSymbol(_ symbol: Symbol)
        {
        if self.symbolsByLabel[symbol.label].isNotNil
            {
            symbol.resetParent()
            self.symbolsByLabel[symbol.label] = nil
            }
        }
        
    public override func setSymbol(_ symbol:Symbol,atName: Name)
        {
        fatalError()
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for symbol in self.symbolsByLabel.values
            {
            try symbol.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for symbol in self.symbolsByLabel.values
            {
            try symbol.initializeTypeConstraints(inContext: context)
            }
        self.type = context.voidType
        }

    public override func visit(visitor: Visitor) throws
        {
        for symbol in self.symbolsByLabel.values
            {
            try symbol.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func deepCopy() -> Self
        {
        let container = super.deepCopy()
        var newSymbols = OrderedDictionary<Label,Symbol>()
        for symbol in self.symbols
            {
            newSymbols[symbol.label] = symbol.deepCopy()
            }
        container.symbolsByLabel = newSymbols
        return(container)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols
            {
            try symbol.emitCode(using: generator)
            }
        }
        
    public override func addSymbol(_ symbol:Symbol)
        {
        self.symbolsByLabel[symbol.label] = symbol
        symbol.setParent(self)
        print("ADDED \(symbol.fullName.displayString) TO \(self.fullName.displayString)")
        }
        
    public func addSymbols(_ symbols:Array<Symbol>) -> ContainerSymbol
        {
        for symbol in symbols
            {
            self.addSymbol(symbol)
            }
        return(self)
        }
        
    public override func printContents(_ offset: String = "")
        {
        var indent = offset
        let typeName = Swift.type(of: self)
        print("\(indent)\(typeName): \(self.label)")
        if self.symbols.count > 0
            {
            indent += "\t"
            print("\(indent)\(self.symbols.count) symbols")
            print("\(indent)============================================")
            for element in self.symbols
                {
                element.printContents(indent)
                }
            }
        }
    }
