//
//  ClosureBlock.swift
//  ClosureBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ClosureBlock: Block
    {
    public var parameters = Parameters()
//    public var returnType:Type = VoidClass.voidClass.type
    public var buffer: T3ABuffer = T3ABuffer()
        
    public func addParameter(label:String,type: Type)
        {
        let parameter = Parameter(label: label,type: type)
        self.addLocalSlot(parameter)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)CLOSURE")
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into: T3ABuffer,using: CodeGenerator) throws
        {
//        var stackOffset = MemoryLayout<Word>.size
//        for parameter in self.parameters
//            {
////            parameter.addresses.append(.stack(.BP,stackOffset))
//            stackOffset += MemoryLayout<Word>.size
//            }
//        stackOffset = -8
//        for slot in self.localSlots
//            {
////            slot.addresses.append(.stack(.BP,stackOffset))
//            stackOffset -= MemoryLayout<Word>.size
//            }
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        }
    }
