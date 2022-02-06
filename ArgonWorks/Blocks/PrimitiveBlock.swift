//
//  PrimitiveBlock.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/12/21.
//

import Foundation

public class PrimitiveBlock: Block
    {
    private let primitiveIndex:Int
    
    init(primitiveIndex: Int)
        {
        self.primitiveIndex = primitiveIndex
        super.init()
        }
        
    required init()
        {
        self.primitiveIndex = -1
        super.init()
        }
    
    public required init?(coder: NSCoder)
        {
        self.primitiveIndex = coder.decodeInteger(forKey:"primitiveIndex")
        super.init(coder: coder)
        }
            
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.primitiveIndex,forKey:"primitiveIndex")
        super.encode(with: coder)
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        buffer.add(.PRIM,.integer(Argon.Integer(self.primitiveIndex)))
        }
    }
