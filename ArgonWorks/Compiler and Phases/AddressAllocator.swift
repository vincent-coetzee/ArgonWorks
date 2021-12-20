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
        self.payload.symbolTable.addSymbol(symbol)
        }
        
    public func segment(for symbol: Symbol) -> Segment
        {
        switch(symbol.segmentType)
            {
            case .empty:
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
        switch(symbol.segmentType)
            {
            case .empty:
                break
            case .static:
                self.payload.staticSegment.allocateMemoryAddress(for: symbol)
            case .managed:
                self.payload.managedSegment.allocateMemoryAddress(for: symbol)
            case .stack:
                self.payload.stackSegment.allocateMemoryAddress(for: symbol)
            case .code:
                self.payload.codeSegment.allocateMemoryAddress(for: symbol)
            }
        }
        
    public func allocateAddress(for methodInstance: MethodInstance)
        {
        switch(methodInstance.segmentType)
            {
            case .empty:
                break
            case .static:
                self.payload.staticSegment.allocateMemoryAddress(for: methodInstance)
            case .managed:
                self.payload.managedSegment.allocateMemoryAddress(for: methodInstance)
            case .stack:
                self.payload.stackSegment.allocateMemoryAddress(for: methodInstance)
            case .code:
                self.payload.codeSegment.allocateMemoryAddress(for: methodInstance)
            }
        }
        
    public func allocateAddress(for aStatic: StaticObject)
        {
        switch(aStatic.segmentType)
            {
            case .empty:
                break
            case .static:
                self.payload.staticSegment.allocateMemoryAddress(for: aStatic)
            case .managed:
                self.payload.managedSegment.allocateMemoryAddress(for: aStatic)
            case .stack:
                self.payload.stackSegment.allocateMemoryAddress(for: aStatic)
            case .code:
                self.payload.codeSegment.allocateMemoryAddress(for: aStatic)
            }
        }
    }
