//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation


    
public class AddressAllocator: CompilerPass
    {
    public var wasCancelled = false
    public var payload: VMPayload
    public let argonModule: ArgonModule
    
    init()
        {
        self.payload = VMPayload()
        self.argonModule = ArgonModule.shared
        self.allocateArgonModule()
        }
        
    private func allocateArgonModule()
        {
        try! ArgonModule.shared.allocateAddresses(using: self)
        ArgonModule.shared.layoutInMemory(using: self)
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    @discardableResult
    public func processModule(_ module: Module?) -> Module?
        {
        guard let module = module else
            {
            return(nil)
            }
        /// Allocate space for the class dictionary pointer
        /// amd the method array pointer
        ///
        do
            {
            try module.allocateAddresses(using: self)
            guard !self.wasCancelled else
                {
                return(nil)
                }
            return(module)
            }
        catch let error as CompilerIssue
            {
            module.appendIssue(error)
            }
        catch let error
            {
            module.appendIssue(at: .zero, message: "Unexpected error: \(error)")
            }
        return(nil)
        }
        
    public func registerSymbol(_ symbol: Argon.Symbol) -> Int
        {
        self.payload.symbolRegistry.registerSymbol(symbol)
        }
        
    public func segment(for segmentType: Segment.SegmentType) -> Segment
        {
        switch(segmentType)
            {
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
        
    public func allocateAddress(forMethodInstance methodInstance: MethodInstance)
        {
        let segment = self.segment(for: methodInstance.segmentType)
        segment.allocateMemoryAddress(for: methodInstance)
        }
        
    public func allocateAddress(forPrimitiveInstance methodInstance: PrimitiveInstance)
        {
        let index = methodInstance.primitiveIndex
        methodInstance.setMemoryAddress(self.payload.address(forPrimitiveIndex: Int(index)))
        }
        
    public func allocateAddress(for aStatic: StaticObject)
        {
        let segment = self.segment(for: aStatic.segmentType)
        segment.allocateMemoryAddress(for: aStatic)
        }
    }
