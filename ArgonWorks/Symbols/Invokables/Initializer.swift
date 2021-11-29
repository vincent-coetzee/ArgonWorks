//
//  Initializer.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Initializer:Function,Scope
    {
    public var isSlotScope: Bool
        {
        false
        }
        
    public override var enclosingScope: Scope
        {
        return(self)
        }
        
    public var isMethodInstanceScope: Bool
        {
        return(false)
        }
        
    public var isClosureScope: Bool
        {
        return(false)
        }
        
    public var isInitializerScope: Bool
        {
        return(true)
        }
        
    public override var instructions: Array<T3AInstruction>
        {
        self.buffer.instructions
        }
        
    internal private(set) var block = Block()
    internal var declaringClass: Class?
    private let buffer = T3ABuffer()
    private var symbols = Symbols()
    
    public override var typeCode:TypeCode
        {
        .initializer
        }

    public required init(label: Label)
        {
        super.init(label: label)
        self.block = InitializerBlock(initializer: self)
        self.block.setParent(self)
        }
            
    public required init?(coder: NSCoder)
        {
        self.symbols = coder.decodeObject(forKey: "symbols") as! Symbols
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.declaringClass = coder.decodeObject(forKey: "declaringClass") as? Class
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.symbols,forKey:"symbols")
        coder.encode(self.block,forKey: "block")
        coder.encode(self.declaringClass,forKey: "declaringClass")
        super.encode(with: coder)
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        self.symbols.append(symbol)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
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
