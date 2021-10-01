//
//  SymbolExpression.swift
//  SymbolExpression
//
//  Created by Vincent Coetzee on 16/8/21.
//

import Foundation

public class SymbolExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.symbol.label)")
        }
        
    public override var canBeScoped: Bool
        {
        if symbol is Class || symbol is Enumeration || symbol is Module
            {
            return(true)
            }
        return(false)
        }
        
    public override var resultType: Type
        {
        return(self.symbol.type)
        }
        
    private let symbol: Symbol
    
    required init?(coder: NSCoder)
        {
        self.symbol = coder.decodeObject(forKey: "symbol") as! Symbol
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.symbol,forKey: "symbol")
        }
        
    init(symbol: Symbol)
        {
        self.symbol = symbol
        super.init()
        }
        
 
        
    public override func realize(using realizer: Realizer)
        {
        self.symbol.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.symbol.analyzeSemantics(using: analyzer)
        }
        
    public override func scopedExpression(for child: String) -> Expression?
        {
        if self.symbol is Class
            {
            if let symbol = (self.symbol as! Class).lookup(label: child.withoutHash())
                {
                return(SymbolExpression(symbol: symbol))
                }
            return(nil)
            }
        else if self.symbol is Module
            {
            if let symbol = (self.symbol as! Module).lookup(label: child.withoutHash())
                {
                return(SymbolExpression(symbol: symbol))
                }
            return(nil)
            }
        else if self.symbol is Enumeration
            {
            if let symbol = (self.symbol as! Enumeration).lookup(label: child)
                {
                return(SymbolExpression(symbol: symbol))
                }
            return(nil)
            }
        else
            {
            return(nil)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("SymbolExpression NEEDS TO GENERATE CODE")
        }
    }
