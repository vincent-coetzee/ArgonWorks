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
        let modules = self.symbols.values.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label}
        return(ModuleHolder(TopModule(modules)))
        }

    public static let shared = TopModule()
        
    public override var name: Name
        {
        return(Name(rooted:true))
        }
        
    public let argonModule = ArgonModule()
        
    public var userModules: Array<Module>
        {
        return(self.symbols.values.filter{$0 is Module && !($0 is ArgonModule)}.map{$0 as! Module})
        }
    
    init()
        {
        super.init(label: "Root")
        self.index = UUID(index: 0)
        self.addSymbol(self.argonModule)
        }
        
    init(_ array:Array<Module>)
        {
        super.init(label: "Root")
        for item in array
            {
            self.symbols[item.label] = item
            }
        self.index = UUID(index: 0)
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func resolveReferences()
        {
        self.argonModule.resolveReferences()
        }
        
    public override func lookup(name:Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        if name.isRooted
            {
            if let context = self.primaryContext.lookup(label: name.first)
                {
                return(context.lookup(name: name.withoutFirst))
                }
            return(nil)
            }
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        return(nil)
        }
    }
