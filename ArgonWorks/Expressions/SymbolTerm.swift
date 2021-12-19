//
//  SymbolTerm.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/12/21.
//

import Foundation

public class SymbolTerm: Expression
    {
    internal let symbol: Symbol
    
    init(symbol: Symbol)
        {
        self.symbol = symbol
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.symbol = coder.decodeObject(forKey: "symbol") as! Symbol
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.symbol,forKey: "symbol")
        super.encode(with: coder)
        }
        
    public override func emitValueCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public override func emitPointerCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        try self.symbol.emitLValue(into: into,using: using)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = symbol.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
    }
