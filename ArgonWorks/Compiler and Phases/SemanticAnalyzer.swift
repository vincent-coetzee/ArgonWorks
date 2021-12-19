//
//  SemanticAnalyzer.swift
//  SemanticAnalyzer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class SemanticAnalyzer: CompilerPass
    {
    public let compiler:Compiler
    public var wasCancelled = false
    public let typeContext: TypeContext

    init(_ compiler: Compiler)
        {
        self.compiler = compiler
        self.typeContext = TypeContext(scope: TopModule.shared.argonModule)
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
        guard let newModule = module.moduleWithSemanticsAnalyzed(using: self),!self.wasCancelled else
            {
            return(nil)
            }
        return(newModule)
        }
    }
