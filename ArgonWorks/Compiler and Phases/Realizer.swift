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
        
    private func realize(_ parseNode:ParseNode) -> Bool
        {
        parseNode.realize(using: self)
        return(!self.wasCancelled)
        }
    }
