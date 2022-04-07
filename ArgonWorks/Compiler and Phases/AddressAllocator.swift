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
    
    init(argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        self.payload = VMPayload(argonModule: argonModule)
        self.allocateArgonModule()
        }
        
    private func allocateArgonModule()
        {
        self.argonModule.allocateAddresses(using: self)
        self.argonModule.layoutInMemory(using: self)
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
        module.allocateAddresses(using: self)
        guard !self.wasCancelled else
            {
            return(nil)
            }
        return(module)
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
            case .space:
                fatalError()
            }
        }
        
    public func allocateVirtualTable(_ virtualTable: VirtualTable) -> Address
        {
        //
        // 1 Word for the Class this is for
        // 1 Word for the count of entries in the table
        // N words for the entries in the table
        //
        let wordCount = virtualTable.entries.count
        let address = self.payload.codeSegment.allocateWords(count: wordCount)
        return(address)
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
