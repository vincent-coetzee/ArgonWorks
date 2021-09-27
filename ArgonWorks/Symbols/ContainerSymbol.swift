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
        
    internal var symbols = Symbols()
    private var _children: Symbols?
    
    public override var isExpandable: Bool
        {
        return(self.symbols.count > 0)
        }
        
    public override var childCount: Int
        {
        return(self.children!.count)
        }
        
    public override var children: Symbols?
        {
        return(self.symbols.sorted{$0.label < $1.label})
        }
        
    public var classesWithNotDirectlyContainedSuperclasses:Classes
        {
        var classes = self.symbols.filter{$0 is Class}.map{$0 as! Class}
        classes = classes.filter{$0.superclasses.isEmpty}
        for aClass in self.symbols.filter({$0 is Class}).map({$0 as! Class})
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
        
    public required init?(coder: NSCoder)
        {
        self.symbols = coder.decodeObject(forKey: "symbols") as! Symbols
        self._children = coder.decodeObject(forKey: "_children") as? Symbols
        super.init(coder: coder)
        }
        
    public override init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.symbols,forKey: "symbols")
        coder.encode(self._children,forKey: "_children")
        }
    ///
    ///
    /// Support for naming context
    ///
    ///
    public override func lookup(label:String) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func removeSymbol(_ symbol: Symbol)
        {
        self.symbols.removeAll(where: {$0.index == symbol.index})
        }
        
    public override func setSymbol(_ symbol:Symbol,atName: Name)
        {
        fatalError()
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for node in self.symbols
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
        for child in self.symbols
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
        for symbol in self.symbols
            {
            try symbol.emitCode(using: generator)
            }
        }
        
    public override func realizeSuperclasses()
        {
        for element in self.symbols
            {
            element.realizeSuperclasses()
            }
        }
        
    @discardableResult
    public override func addSymbol(_ symbol:Symbol) -> Symbol
        {
        self.symbols.append(symbol)
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
        
    public override func removeObject(taggedWith: Int)
        {
        for element in self.symbols
            {
            element.removeObject(taggedWith: taggedWith)
            if element.tag == taggedWith
                {
                self.symbols.removeAll(where: {$0.index == element.index})
                }
            }
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
