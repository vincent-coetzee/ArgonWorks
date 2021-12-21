//
//  PrimitiveClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class PrimitiveClass: SystemClass
    {
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        return(.none)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        self.wasMemoryLayoutDone = true
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        self.wasAddressAllocationDone = true
        }
        
    public override func layoutObjectSlots(using allocator: AddressAllocator)
        {
        self.wasSlotLayoutDone = true
        }
    }
