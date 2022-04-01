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
    public static var affectedSymbols = Symbols()
    
    public static func resetAffectedSymbols()
        {
        self.affectedSymbols = []
        }
        
    public override var methodInstances:MethodInstances
        {
        var someInstances = self.symbols.compactMap{$0 as? MethodInstance}
        for symbol in self.symbols
            {
            someInstances.append(contentsOf: symbol.methodInstances)
            }
        return(someInstances)
        }
        
//    public override var allIssues: CompilerIssues
//        {
//        get
//            {
//            var myIssues = self.issues
//            for symbol in self.symbols
//                {
//                myIssues.append(contentsOf: symbol.allIssues)
//                }
//            return(myIssues)
//            }
//        set
//            {
//            }
//        }
        
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
        
    private var symbols = Symbols()
    
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
        
    public var allSymbols: Symbols
        {
        Array(self.symbols).sorted{$0.label < $1.label}
        }
        
    public override var allChildren: Symbols
        {
        return(Array(self.symbols))
        }
        
    public override var children: Symbols
        {
        return(self.symbols.sorted{$0.label < $1.label})
        }
        
//    public var classesWithNotDirectlyContainedSuperclasses:Classes
//        {
//        var classes = self.symbols.filter{$0 is Class}.map{$0 as! Class}
//        classes = classes.filter{$0.localSuperclasses.isEmpty}
//        for aClass in self.symbols.filter({$0 is Class}).map({$0 as! Class})
//            {
//            for superclass in aClass.localSuperclasses
//                {
//                if !self.directlyContains(symbol: superclass)
//                    {
//                    classes.append(aClass)
//                    }
//                }
//            }
//        return(classes)
//        }
        
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

    public func removeSymbol(_ symbol: Symbol)
        {
        var newSymbols = self.symbols
        for aSymbol in self.symbols
            {
            if aSymbol.label == symbol.label
                {
                newSymbols.remove(symbol)
                }
            }
        self.symbols = newSymbols
        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self)): \(self.label)")
        for symbol in self.symbols
            {
            symbol.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for symbol in self.symbols
            {
            symbol.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for symbol in self.symbols
            {
            symbol.initializeTypeConstraints(inContext: context)
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
        
    public override func addSymbol(_ symbol: Symbol)
        {
        self.symbols.append(symbol)
        Self.affectedSymbols.append(symbol)
        }
        
        
    public override func lookupMethod(label: Label) -> ArgonWorks.Method?
        {
        for aSymbol in self.symbols.compactMap({$0 as? ArgonWorks.Method})
            {
            if aSymbol.label == label
                {
                return(aSymbol)
                }
            }
        return(nil)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.module?.lookup(label: label))
        }
        
//    public override func lookup(name: Name) -> Symbol?
//        {
//        if name.isRooted
//            {
//            if name.count == 1
//                {
//                return(nil)
//                }
//            if let start = TopModule.shared.lookup(label: name.first)
//                {
//                if name.count == 2
//                    {
//                    return(start)
//                    }
//                if let symbol = start.lookup(name: name.withoutFirst)
//                    {
//                    return(symbol)
//                    }
//                }
//            }
//        if name.isEmpty
//            {
//            return(nil)
//            }
//        else if name.count == 1
//            {
//            if let symbol = self.lookup(label: name.first)
//                {
//                return(symbol)
//                }
//            }
//        else if let start = self.lookup(label: name.first)
//            {
//            if let symbol = (start as? Scope)?.lookup(name: name.withoutFirst)
//                {
//                return(symbol)
//                }
//            }
//        return(self.module?.lookup(name: name))
//        }
        
    public func removeSymbol(withItemKey: Int)
        {
        var symbolsToBeRemoved = Symbols()
        for symbol in self.symbols
            {
            if symbol.itemKey == withItemKey
                {
                symbolsToBeRemoved.append(symbol)
                }
            }
        for symbol in symbolsToBeRemoved
            {
            let index = self.symbols.firstIndex(of: symbol)!
            self.symbols.remove(at: index)
            }
        }
        
    public override func lookupN(label: Label) -> Symbols?
        {
        let someSymbols = self.symbols.filter{$0.label == label}
        if let topSymbols = self.module?.lookupN(label: label)
            {
            return((someSymbols + topSymbols).nilIfEmpty)
            }
        return(someSymbols.nilIfEmpty)
        }
        
//    public override func lookupN(name: Name) -> Symbols?
//        {
//        if name.isRooted
//            {
//            if name.count == 1
//                {
//                return(nil)
//                }
//            if let start = TopModule.shared.lookupN(label: name.first)
//                {
//                if name.count == 2
//                    {
//                    return(start.nilIfEmpty)
//                    }
//                if let symbol = (start.first)?.lookupN(name: name.withoutFirst)
//                    {
//                    return(symbol.nilIfEmpty)
//                    }
//                }
//            return(nil)
//            }
//        if name.isEmpty
//            {
//            return(nil)
//            }
//        else if name.count == 1
//            {
//            if let symbol = self.lookupN(label: name.first)
//                {
//                return(symbol.nilIfEmpty)
//                }
//            }
//        else if let start = self.lookupN(label: name.first)
//            {
//            if let symbol = start.first?.lookupN(name: name.withoutFirst)
//                {
//                return(symbol.nilIfEmpty)
//                }
//            }
//        return(self.module?.lookupN(name: name))
//        }
        
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        for symbol in self.symbols
            {
            symbol.allocateAddresses(using: allocator)
            }
        }
        
    public override func install(inContext context: ExecutionContext)
        {
        for symbol in self.symbols
            {
            symbol.install(inContext: context)
            }
        }
    }
