//
//  Realizer.swift
//  Realizer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class Realizer: CompilerPass
    {
    public let compiler:Compiler
    public var wasCancelled = false
    public var realizedSymbols = Symbols()
    
    @discardableResult
    public static func realize(_ parseNode:ParseNode,in compiler:Compiler) -> Bool
        {
        Realizer(compiler: compiler).realize(parseNode)
        }
        
    public var virtualMachine: VirtualMachine
        {
        return(self.compiler.virtualMachine)
        }
        
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
    
    public func hasRealizedSymbol(_ symbol: Symbol) -> Bool
        {
        return(self.realizedSymbols.contains(symbol))
        }
        
    public func markSymbolAsRealized(_ symbol: Symbol)
        {
        self.realizedSymbols.append(symbol)
        }
        
    private func realize(_ parseNode:ParseNode) -> Bool
        {
        parseNode.realize(using: self)
        return(!self.wasCancelled)
        }
    }
