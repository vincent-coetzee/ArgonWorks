//
//  SystemValueClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class ValueClass: Class
    {
    public override var segmentType: Segment.SegmentType
        {
        .managed
        }
        
    public override var isSystemSymbol: Bool
        {
        return(false)
        }
        
    public override var typeCode:TypeCode
        {
        return(.none)
        }
        
    public override var isSystemClass: Bool
        {
        return(false)
        }
        
    public override var isValueClass: Bool
        {
        true
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

public class SystemValueClass: SystemClass
    {
    public override var segmentType: Segment.SegmentType
        {
        .managed
        }
        
    public override var isValueClass: Bool
        {
        true
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
