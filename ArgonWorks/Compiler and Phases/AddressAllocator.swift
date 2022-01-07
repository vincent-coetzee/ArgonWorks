//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation


    
public class AddressAllocator: CompilerPass
    {
    public let compiler: Compiler
    public var wasCancelled = false
    public var payload: VMPayload
    public let argonModule: ArgonModule
    
    init(_ compiler: Compiler)
        {
        self.compiler = compiler
        self.payload = VMPayload()
        self.argonModule = ArgonModule.shared
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
        ArgonModule.shared.moduleWithAllocatedAddresses(using: self)
        let newModule = module.moduleWithAllocatedAddresses(using: self)
        guard !self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
        
    public func registerSymbol(_ symbol: Argon.Symbol) -> Address
        {
        self.payload.symbolRegistry.registerSymbol(symbol)
        }
        
    public func segment(for segmentType: Segment.SegmentType) -> Segment
        {
        switch(segmentType)
            {
            case .null:
                break
            case .static:
                return(self.payload.staticSegment)
            case .managed:
                return(self.payload.managedSegment)
            case .stack:
                return(self.payload.stackSegment)
            case .code:
                return(self.payload.codeSegment)
            }
        fatalError("Can not determine segment")
        }
        
    public func allocateAddress(for symbol: Symbol)
        {
        let segment = self.segment(for: symbol.segmentType)
        segment.allocateMemoryAddress(for: symbol)
        }
        
    public func allocateAddress(for methodInstance: MethodInstance)
        {
        let segment = self.segment(for: methodInstance.segmentType)
        segment.allocateMemoryAddress(for: methodInstance)
        }
        
    public func allocateAddress(for aStatic: StaticObject)
        {
        let segment = self.segment(for: aStatic.segmentType)
        segment.allocateMemoryAddress(for: aStatic)
        }
    }
