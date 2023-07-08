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
    private let staticSymbol: StaticSymbol
    
    public init(symbol: String)
        {
        self.symbol = symbol
        self.staticSymbol = StaticSymbol(string: self.symbol)
        Argon.addStatic(self.staticSymbol)
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.symbol = coder.decodeObject(forKey: "symbol") as! String
        self.staticSymbol = coder.decodeObject(forKey: "staticSymbol") as! StaticSymbol
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.symbol = ""
        self.staticSymbol = StaticSymbol(string: "")
        super.init()
        }
        
     public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        buffer.append(.SIG,.address(self.staticSymbol.memoryAddress),.none,.none)
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

