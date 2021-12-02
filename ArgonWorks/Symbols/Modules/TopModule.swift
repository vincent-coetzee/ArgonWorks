//
//  TopModule.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

///
///
/// There is only a single TopModule in any application running
/// Argon. That means the only valid way to access an instance
/// of a TopModule is through the accessor variable on the class.
///
///
public class TopModule: SystemModule
    {
    public override var typeCode:TypeCode
        {
        .topModule
        }
        
    ///
    ///
    /// We ARE the primary context, so just return ourselves
    ///
    ///
    public override var primaryContext: NamingContext
        {
        return(self)
        }
        
    public var moduleRoot: Module
        {
        let modules = self.symbols.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label}
        return(ModuleHolder(TopModule(modules)))
        }

    public var allModules: Symbols
        {
        return(self.symbols.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label})
        }


    public override var topModule: TopModule
        {
        return(self)
        }
        
    public override var fullName: Name
        {
        return(Name(rooted:true))
        }
    
    public var argonModule: ArgonModule
        {
        return(self.lookup(label: "Argon") as! ArgonModule)
        }
        
    public var userModules: Array<Module>
        {
        return(self.symbols.filter{$0 is Module && !($0 is ArgonModule)}.map{$0 as! Module})
        }
    
    init(compiler: Compiler)
        {
        super.init(label: "Root")
        self.index = UUID(index: 0)
        self.addSymbol(ArgonModule(compiler: compiler))
        }
        
    init(_ array:Array<Module>)
        {
        super.init(label: "Root")
        for element in array
            {
            self.symbolsByLabel[element.label] = element
            }
        self.index = UUID(index: 0)
        }
        
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func replaceSymbol(_ source: Symbol,with replacement: Symbol)
        {
        for symbol in self.symbols
            {
            symbol.replaceSymbol(source,with: replacement)
            if symbol == source
                {
                self.symbolsByLabel[source.label] = replacement
                }
            }
        }
        
    public override func lookup(name: Name) -> Symbol?
        {
        if name.isRooted
            {
            if name.count == 1
                {
                return(self)
                }
            if let start = self.lookup(label: name.first)
                {
                if name.count == 2
                    {
                    return(start)
                    }
                if let symbol = start.lookup(name: name.withoutFirst)
                    {
                    return(symbol)
                    }
                }
            }
        if name.isEmpty
            {
            return(nil)
            }
        else if name.count == 1
            {
            if let symbol = self.lookup(label: name.first)
                {
                return(symbol)
                }
            }
        else if let start = self.lookup(label: name.first)
            {
            if let symbol = start.lookup(name: name.withoutFirst)
                {
                return(symbol)
                }
            }
        return(nil)
        }
    }
