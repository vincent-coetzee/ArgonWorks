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
    public var processedModule: Module?
    
    public init(_ compiler: Compiler)
        {
        self.compiler = compiler
        }
    
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    public func processModule(_ module: Module?) -> Module?
        {
        guard let module = module else
            {
            return(nil)
            }
        guard let newModule = module.moduleWithOptimization(using: self),!self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
    }
