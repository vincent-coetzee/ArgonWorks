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
        
    public override func layoutObjectSlots(using allocator: AddressAllocator)
        {
        guard !self.wasSlotLayoutDone else
            {
            return
            }
        self.wasSlotLayoutDone = true
        }
    }
