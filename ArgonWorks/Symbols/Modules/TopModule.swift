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
        var instances = self.allSymbols.compactMap{$0 as? MethodInstance}
        for module in (self.allSymbols.compactMap{$0 as? Module}.filter{!($0 is ArgonModule)})
            {
            instances.append(contentsOf: module.everyMethodInstance)
            }
        return(instances)
        }
        
    public var argonModule: ArgonModule
        {
        self._argonModule
        }
        
//    public var moduleRoot: Module
//        {
//        let modules = self.symbols.filter({$0 is Module}).map({$0 as! Module}).sorted{$0.label<$1.label}
//        return(ModuleHolder(TopModule(modules)))
//        }
        
    public override var fullName: Name
        {
        return(Name(rooted:true))
        }
        
    public var userModules: Array<Module>
        {
        return(self.allSymbols.filter{$0 is Module && !($0 is ArgonModule)}.map{$0 as! Module})
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
        
    
    public var _argonModule: ArgonModule!
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        self.argonModule.lookup(label: label)
        }
        
    public override func lookupType(label: Label) -> Type?
        {
        self.argonModule.lookupType(label: label)
        }
        
    public override func lookupMethod(label: Label) -> ArgonWorks.Method?
        {
        self.argonModule.lookupMethod(label: label)
        }
        
    public override func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.allSymbols
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
        
    public override func lookup(name inName: Name) -> Symbol?
        {
        if !inName.isRooted
            {
            fatalError("Can not use non rooted name in TopModule.")
            }
        var name = inName.cdr
        if name.isEmpty
            {
            return(nil)
            }
        let first = name.car
        for symbol in self.allSymbols
            {
            if symbol.label == first
                {
                if name.isEmpty
                    {
                    return(symbol)
                    }
                else
                    {
                    return(symbol.lookup(name: name.cdr))
                    }
                }
            }
        return(nil)
        }
    }
