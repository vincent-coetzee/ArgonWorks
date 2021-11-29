//
//  SignalBlock.swift
//  SignalBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class SignalBlock: Block
    {
    private let symbol:String
    
    public init(symbol: String)
        {
        self.symbol = symbol
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.symbol = ""
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.symbol = ""
        super.init()
        }
        
     public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        buffer.append(nil,"SIG",.literal(.symbol(self.symbol)),.none,.none)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.type = context.symbolType
        }
    }

