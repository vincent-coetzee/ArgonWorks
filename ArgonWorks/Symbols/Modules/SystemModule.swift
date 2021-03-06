//
//  SystemModule.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation

public class SystemModule: Module
    {
    public override var typeCode:TypeCode
        {
        .systemModule
        }
        
    public override var isSystemModule: Bool
        {
        return(true)
        }
        
    public var subModules: Modules
        {
        return(self.symbols.valuesByKey.compactMap{$0 as? SystemModule})
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let value = self.symbols[label]
            {
            return(value)
            }
        for module in self.subModules
            {
            if let value = module.lookup(label: label)
                {
                return(value)
                }
            }
        return(nil)
        }
        
    internal override func layout(in vm: VirtualMachine)
        {
        self.layoutSlots()
        for aModule in self.symbols.valuesByKey.compactMap({$0 as? SystemModule})
            {
            aModule.layout(in: vm)
            }
        self.layoutInMemory(in: vm)
        }
        
    internal func resolveReferences(in vm: VirtualMachine)
        {
        for symbol in self.symbols.valuesByKey
            {
            if let aClass = symbol as? Class
                {
                aClass.realizeSuperclasses(in: vm)
                }
            else if let aModule = symbol as? SystemModule
                {
                print("RESOLVING MODULE \(aModule.label)")
                aModule.resolveReferences(in: vm)
                }
            }
        }
    }
