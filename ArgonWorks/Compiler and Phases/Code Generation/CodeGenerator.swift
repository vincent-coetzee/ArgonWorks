//
//  CodeGenerator.swift
//  CodeGenerator
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation


public class CodeGenerator: CompilerPass
    {
    public let compiler: Compiler
    public var wasCancelled = false
    public var isLValue = false
    public let payload: VMPayload
    
    public init(_ compiler: Compiler,payload: VMPayload)
        {
        self.compiler = compiler
        self.payload = payload
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
        let newModule = module.moduleWithEmittedCode(using: self)
        guard !self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
    }
