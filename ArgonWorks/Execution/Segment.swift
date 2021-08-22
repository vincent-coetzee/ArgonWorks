//
//  Segment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public class Segment
    {
    internal static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
    
    public enum SegmentType:UInt64
        {
        case stack = 1
        case `static` = 2
        case managed = 3
        case data = 4
        
        public var register: Instruction.Register
            {
            switch(self)
                {
                case .stack:
                    return(.ss)
                case .static:
                    return(.sts)
                case .managed:
                    return(.ms)
                case .data:
                    return(.ds)
                }
            }
        }
        
    public var startOffset: Word
        {
        return(0)
        }
        
    public var endOffset: Word
        {
        return(0)
        }
        
    public var segmentType:SegmentType
        {
        fatalError("Should have been overridden")
        }
        
    public var spaceFree: MemorySize
        {
        return(MemorySize.bytes(0))
        }
        
    public var spaceUsed: MemorySize
        {
        return(MemorySize.bytes(0))
        }

    public var size: MemorySize
    public var virtualMachine: VirtualMachine!
    
    public var segmentRegister: Instruction.Register
        {
        return(self.segmentType.register)
        }
        
    public init(size: MemorySize)
        {
        self.size = size
        self.virtualMachine = nil
        }
        
    public func address(offset: Word) -> Word
        {
        return(0)
        }
        
    public func allocateAddress(sizeInBytes: Int) -> Address
        {
        fatalError("This should be implemented in a subclass.")
        }
        
    public func allocateObject(sizeInBytes:Int) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public func allocateString(_ string:String) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public func allocateObject(ofClass clazz:Class) -> Address
        {
        fatalError()
        }
    }
