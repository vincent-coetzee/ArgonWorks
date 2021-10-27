//
//  Initializer.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Initializer:Function
    {
    public override var instructions: Array<T3AInstruction>
        {
        self.buffer.instructions
        }
        
    internal private(set) var block = Block()
    internal var declaringClass: Class?
    private let buffer = T3ABuffer()
    
    public override var typeCode:TypeCode
        {
        .initializer
        }

    public override init(label: Label)
        {
        super.init(label: label)
        self.block = InitializerBlock(initializer: self)
        self.block.setParent(self)
        }
            
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.declaringClass = coder.decodeObject(forKey: "declaringClass") as? Class
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.block,forKey: "block")
        coder.encode(self.declaringClass,forKey: "declaringClass")
        super.encode(with: coder)
        }
        
    public override func emitCode(using: CodeGenerator) throws
        {
        try self.emitCode(into: self.buffer,using: using)
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        buffer.appendEntry(temporaryCount: 0)
        try self.block.emitCode(into: buffer, using: using)
        buffer.appendExit()
        buffer.append("RET",.none,.none,.none)
        }
        
}
