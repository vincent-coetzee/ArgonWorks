//
//  CodeGenerator.swift
//  CodeGenerator
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation


public class CodeGenerator: CompilerPass
    {
    public let compiler: Compiler
    public var wasCancelled = false
    public let payload: VMPayload
    public let addressAllocator: AddressAllocator
    
    public init(_ compiler: Compiler,addressAllocator: AddressAllocator)
        {
        self.compiler = compiler
        self.payload = addressAllocator.payload
        self.addressAllocator = addressAllocator
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    public func emitStaticString(_ string: String) -> Address
        {
        return(payload.staticSegment.allocateString(string))
        }
        
    public func registerMethodInstanceIfNeeded(_ methodInstance: MethodInstance)
        {
        if methodInstance.memoryAddress == 0
            {
            let segment = self.payload.segment(for: methodInstance)
            segment.allocateMemoryAddress(for: methodInstance)
            }
        }
        
    public func processModule(_ module: Module?) -> Module?
        {
        guard let module = module else
            {
            return(nil)
            }
        let newModule = module.moduleWithEmittedCode(using: self)
        guard !self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
    }
