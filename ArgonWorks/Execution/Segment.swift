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
            fatalError()
//            switch(self)
//                {
//                case .stack:
//                    return(.SS)
//                case .static:
//                    return(.STS)
//                case .managed:
//                    return(.MS)
//                case .data:
//                    return(.DS)
//                }
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
//        return(self.segmentType.register)
        fatalError()
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
    ///
    ///
    /// Allocate a working object from the segment and return
    /// the address of that object to the caller. This allocates
    /// the given number of bytes and also uses the first
    /// word of the allocation to store an object header
    /// record. This is needed by the memory manangement algorithm
    /// to know whether to follow the object or to copy it
    /// when garbage collection is taking place. Strictly speaking
    /// this header is only needed by objects allocated in the
    /// managed segment but is used for all allocations to simplify
    /// memory management across the various segments.
    ///
    ///
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
