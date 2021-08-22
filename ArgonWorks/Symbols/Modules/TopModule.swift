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
        
    public override var topModule: TopModule
        {
        self
        }
        
    public override var name: Name
        {
        return(Name(rooted:true))
        }
        
    public var argonModule: ArgonModule
        {
        return(self._argonModule)
        }
    
    private let _argonModule: ArgonModule
    
    public init(virtualMachine: VirtualMachine)
        {
        self._argonModule = ArgonModule(virtualMachine: virtualMachine)
        super.init(label:"")
        self.addSymbol(self._argonModule)
        }
        
    public func resolveReferences(virtualMachine: VirtualMachine)
        {
        self._argonModule.resolve(in: virtualMachine)
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
