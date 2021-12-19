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
        buffer.append(nil,"SIG",.literal(.symbol(StaticSymbol(string: self.symbol))),.none,.none)
        }

    public override func display(indent: String)
        {
        print("\(indent)SIGNAL: \(Swift.type(of: self))")
        print("\(indent)SYMBOLS: \(self.symbol)")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = context.voidType
        }
    }

