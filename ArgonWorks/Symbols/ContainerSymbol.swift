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
    public override var methodInstances:MethodInstances
        {
        var someInstances = self.symbols.compactMap{$0 as? MethodInstance}
        for symbol in self.symbols
            {
            someInstances.append(contentsOf: symbol.methodInstances)
            }
        return(someInstances)
        }
        
    public override var allIssues: CompilerIssues
        {
        get
            {
            var myIssues = self.issues
            for symbol in self.symbols
                {
                myIssues.append(contentsOf: symbol.allIssues)
                }
            return(myIssues)
            }
        set
            {
            }
        }
        
    public override var allImportedSymbols: Symbols
        {
        var importedSymbols = Symbols()
        for symbol in self.symbols
            {
            if symbol.isImported
                {
                importedSymbols.append(symbol)
                }
            importedSymbols.append(contentsOf: symbol.allImportedSymbols)
            }
        return(importedSymbols)
        }

    public override var isGroup: Bool
        {
        return(true)
        }
        
    internal var symbols = Symbols()
    
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
        self.symbols = coder.decodeObject(forKey: "symbols") as! Symbols
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
    
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.symbols,forKey: "symbols")
        super.encode(with: coder)
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
        
    public override func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                found.append(symbol)
                }
            }
        if let more = self.parent.lookupN(label: label)
            {
            found.append(contentsOf: more)
            }
        return(found.isEmpty ? nil : found)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self)): \(self.label)")
        for symbol in self.symbols
            {
            symbol.display(indent: indent + "\t")
            }
        }
        
    public override func setSymbol(_ symbol:Symbol,atName: Name)
        {
        fatalError()
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for symbol in self.symbols
            {
            try symbol.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for symbol in self.symbols
            {
            try symbol.initializeTypeConstraints(inContext: context)
            }
        }

    public override func visit(visitor: Visitor) throws
        {
        for symbol in self.symbols
            {
            try symbol.visit(visitor: visitor)
            }
        try visitor.accept(self)
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
        self.symbols.append(symbol)
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
        
    public override func allocateAddresses(using allocator:AddressAllocator) throws
        {
        for symbol in self.symbols
            {
            try symbol.allocateAddresses(using: allocator)
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
