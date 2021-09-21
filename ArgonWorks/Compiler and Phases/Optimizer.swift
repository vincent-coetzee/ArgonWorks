//
//  Optimizer.swift
//  Optimizer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class Optimizer: CompilerPass
    {
    public let compiler: Compiler
    public var wasCancelled = false
    
    @discardableResult
    public static func optimize(_ node:ParseNode,in compiler:Compiler) -> Bool
        {
        Optimizer(compiler: compiler).optimize(node)
        }
        
    public var virtualMachine: VirtualMachine
        {
        fatalError("Virtal Machine access needed")
        }
        
    public init(compiler: Compiler)
        {
        self.compiler = compiler
        }
    
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    private func optimize(_ node:ParseNode) -> Bool
        {
        return(!self.wasCancelled)
        }
    }
