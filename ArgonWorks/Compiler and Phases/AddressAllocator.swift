//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class AddressAllocator: CompilerPass
    {
    public var virtualMachine: VirtualMachine
        {
        fatalError("Virtual Machine needed")
        }
        
    public let compiler: Compiler
    public var wasCancelled = false
    
    init(_ compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    public func processModule(_ module: Module?) -> Module?
        {
        guard let module = module else
            {
            return(nil)
            }
        let newModule = module.moduleWithAllocatedAddresses(using: self)
        guard !self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
    }
