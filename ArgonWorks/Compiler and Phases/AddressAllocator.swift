//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class AddressAllocator: CompilerPass
    {
    @discardableResult
    public static func allocateAddresses(_ node:ParseNode,in compiler: Compiler) -> Bool
        {
        let allocator = AddressAllocator(compiler: compiler)
        return(allocator.allocateAddresses(node))
        }
        
    public var virtualMachine: VirtualMachine
        {
        return(self.compiler.virtualMachine)
        }
        
    public let compiler: Compiler
    public var wasCancelled = false
    
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    private func allocateAddresses(_ node:ParseNode) -> Bool
        {
        node.allocateAddresses(using: self)
        return(!self.wasCancelled)
        }
    }
