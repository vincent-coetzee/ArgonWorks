//
//  ContainerSymbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class ContainerSymbol:Symbol
    {
    public override var isGroup: Bool
        {
        return(true)
        }
        
    internal var symbols = SymbolDictionary()
    private var _children: Symbols?
    
    public override var isExpandable: Bool
        {
        return(self.symbols.values.count > 0)
        }
        
    public override var childCount: Int
        {
        return(self.children!.count)
        }
        
    public override var children: Symbols?
        {
        return(self.symbols.values.sorted{$0.label < $1.label})
        }
        
    public var classesWithNotDirectlyContainedSuperclasses:Classes
        {
        var classes = self.symbols.values.filter{$0 is Class}.map{$0 as! Class}
        classes = classes.filter{$0.superclasses.isEmpty}
        for aClass in self.symbols.values.filter({$0 is Class}).map({$0 as! Class})
            {
            for superclass in aClass.superclasses
                {
                if !self.directlyContains(symbol: superclass)
                    {
                    classes.append(aClass)
                    }
                }
            }
        return(classes)
        }
        
    ///
    ///
    /// Support for naming context
    ///
    ///
    public override func lookup(label:String) -> Symbol?
        {
        if let symbol = self.symbols[label]
            {
            return(symbol)
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func setSymbol(_ symbol:Symbol,atName: Name)
        {
        if atName.isRooted
            {
            self.primaryContext.setSymbol(symbol,atName: atName.withoutFirst)
            return
            }
        else if atName.count == 1
            {
            self.symbols[atName.last] = symbol
            return
            }
        self.lookup(label: atName.first)?.setSymbol(symbol,atName: atName.withoutFirst)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for node in self.symbols.valuesByKey
            {
            node.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        guard !realizer.hasRealizedSymbol(self) else
            {
            return
            }
        realizer.markSymbolAsRealized(self)
        for child in self.symbols.valuesByKey
            {
            if !realizer.hasRealizedSymbol(child)
                {
                realizer.markSymbolAsRealized(child)
                child.realize(using: realizer)
                }
            }
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols.valuesByKey
            {
            try symbol.emitCode(using: generator)
            }
        }
        
    public override func realizeSuperclasses(in vm: VirtualMachine)
        {
        for element in self.symbols.valuesByKey
            {
            element.realizeSuperclasses(in: vm)
            }
        }
        
    @discardableResult
    public override func addSymbol(_ symbol:Symbol) -> Symbol
        {
        self.symbols[symbol.label] = symbol
        symbol.setParent(self)
        return(symbol)
        }
        
    public func addSymbols(_ symbols:Array<Symbol>) -> ContainerSymbol
        {
        for symbol in symbols
            {
            self.addSymbol(symbol)
            }
        return(self)
        }
    }
