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
    public static func resetTopModule()
        {
        Node.resetUUIDs()
        Self.shared = nil
        Self.shared = TopModule(instanceNumber: 0)
        let argonModule = ArgonModule(instanceNumber: 0)
        Self.shared.addSymbol(argonModule)
        ArgonModule.shared = argonModule
        ArgonModule.shared.initialize()
        }
        
    public static var shared: TopModule!
    
    public override var typeCode:TypeCode
        {
        .topModule
        }
        
    public override var everyMethodInstance: MethodInstances
        {
        var instances = self.symbols.compactMap{$0 as? MethodInstance}
        for module in (self.symbols.compactMap{$0 as? Module}.filter{!($0 is ArgonModule)})
            {
            instances.append(contentsOf: module.everyMethodInstance)
            }
        return(instances)
        }
        
    public var argonModule: ArgonModule
        {
        return(self.lookup(label: "Argon") as! ArgonModule)
        }
        
//    public var moduleRoot: Module
//        {
//        let modules = self.symbols.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label}
//        return(ModuleHolder(TopModule(modules)))
//        }

    public var allModules: Symbols
        {
        return(self.symbols.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label})
        }
        
    public override var fullName: Name
        {
        return(Name(rooted:true))
        }
        
    public var userModules: Array<Module>
        {
        return(self.symbols.filter{$0 is Module && !($0 is ArgonModule)}.map{$0 as! Module})
        }
        
    init(instanceNumber: Int)
        {
        super.init(label: "Root")
        }
//
//    init(_ array:Array<Module>)
//        {
//        super.init(label: "Root")
//        self.setIndex(UUID.systemUUID(0))
//        for element in array
//            {
//            self.symbols.append(element)
//            }
//        }
        
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
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
        if let more = self.argonModule.lookupN(label: label)
            {
            found.append(contentsOf: more)
            }
        return(found.isEmpty ? nil : found)
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
