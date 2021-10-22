//
//  ContainerSymbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public struct JournalTransaction
    {
    internal typealias JournalEntries = Array<JournalEntry>
    
    private var entries: JournalEntries
    
    init(entries: JournalEntries)
        {
        self.entries = entries
        }
        
    public func rollback()
        {
        for entry in self.entries
            {
            switch(entry)
                {
                case .addSymbol(let symbol,let toSymbol):
                    toSymbol.removeSymbol(symbol)
                case .addSuperclass(let aClass,let toClass):
                    toClass.removeSuperclass(aClass)
                case .addSubclass(let aClass,let toClass):
                    toClass.removeSubclass(aClass)
                }
            }
        }
    }
    
public enum JournalEntry
    {
    public var displayString: String
        {
        switch(self)
            {
            case .addSymbol(let symbol,let toSymbol):
                return("ADD \(symbol.label) TO \(toSymbol.label)")
            case .addSuperclass(let symbol,let toSymbol):
                return("ADD SUPERCLASS \(symbol.label) TO CLASS \(toSymbol.label)")
            case .addSubclass(let symbol,let toSymbol):
                return("ADD SUBCLASS \(symbol.label) TO CLASS \(toSymbol.label)")
            }
        }
        
    case addSymbol(Symbol,to: Symbol)
    case addSuperclass(Class,to: Class)
    case addSubclass(Class,to: Class)
    }
    
public class ContainerSymbol:Symbol
    {
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
        
    public func commitJournalTransaction()
        {
        self.resetJournalEntries()
        }
        
    public func rollbackJournalTransaction()
        {
        self.journalTransaction.rollback()
        self.resetJournalEntries()
        }
        
    public override var journalTransaction: JournalTransaction
        {
        return(JournalTransaction(entries: self.allJournalEntries))
        }
        
    public override var allJournalEntries: Array<JournalEntry>
        {
        var entries = Array<JournalEntry>()
        for symbol in self.symbols
            {
            entries.append(contentsOf: symbol.allJournalEntries)
            }
        entries.append(contentsOf: self.journalEntries)
        return(entries)
        }
        
    internal var symbolsByLabel = Dictionary<Label,Symbol>()
    internal var journalEntries = Array<JournalEntry>()
    
    public override var isExpandable: Bool
        {
        return(self.symbols.count > 0)
        }
        
    public override var childCount: Int
        {
        return(self.children!.count)
        }
        
    public override var isSymbolContainer: Bool
        {
        return(true)
        }
        
    public override var allChildren: Symbols
        {
        return(Array(self.symbols))
        }
        
    public override var children: Symbols?
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
        self.symbolsByLabel = coder.decodeObject(forKey: "symbolsByLabel") as! Dictionary<Label,Symbol>
        super.init(coder: coder)
        }
        
    public override init(label: Label)
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
        
    public override func resetJournalEntries()
        {
        for symbol in self.symbols
            {
            symbol.resetJournalEntries()
            }
        self.journalEntries = []
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols
            {
            try symbol.emitCode(using: generator)
            }
        }
        
    public override func realizeSuperclasses(topModule: TopModule)
        {
        for element in self.symbols
            {
            element.realizeSuperclasses(topModule: topModule)
            }
        }
        
    public override func addSymbol(_ symbol:Symbol)
        {
        for oldSymbol in self.symbols
            {
            if symbol.label ==  oldSymbol.label
                {
                fatalError("Duplicate symbol in Module")
                }
            }
        self.symbolsByLabel[symbol.label] = symbol
        self.journalEntries.append(.addSymbol(symbol,to: self))
        symbol.setParent(self)
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
                self.symbolsByLabel[element.label] = nil
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
