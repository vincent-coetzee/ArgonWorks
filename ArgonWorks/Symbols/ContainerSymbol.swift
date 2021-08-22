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
        return(true)
        }
        
    public override var children: Symbols?
        {
        guard self._children.isNil else
            {
            return(self._children)
            }
        if self.symbols.isEmpty
            {
            return(nil)
            }
        var visibleSymbols = Symbols()
        let allSymbols = self.symbols.values + ((self as? Class).isNotNil ? (self as! Class).subclasses : [])
        for symbol in allSymbols
            {
            if !(symbol is Class)
                {
                visibleSymbols.append(symbol)
                }
            }
        visibleSymbols += self.classesWithNotDirectlyContainedSuperclasses
        visibleSymbols = visibleSymbols.sorted{$0.label<$1.label}
        self._children = visibleSymbols
        return(self._children)
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
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for node in self.symbols.valuesByKey
            {
            node.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        for child in self.symbols.valuesByKey
            {
            if child is MethodInstance
                {
                print("junk")
                }
            child.realize(using: realizer)
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
