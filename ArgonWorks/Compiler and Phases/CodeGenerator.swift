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
    public let registerFile: RegisterFile
    public var wasCancelled = false
    
    public var virtualMachine: VirtualMachine
        {
        fatalError("Virtual Machine needed")
        }
        
    @discardableResult
    public static func emit(into node:ParseNode,in compiler:Compiler) -> Bool
        {
        let generator = CodeGenerator(compiler: compiler)
        return(generator.emitCode(into: node))
        }
        
    public init(compiler: Compiler)
        {
        self.compiler = compiler
        self.registerFile = RegisterFile()
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    private func emitCode(into node: ParseNode) -> Bool
        {
        do
            {
            try node.emitCode(using: self)
            return(!self.wasCancelled)
            }
        catch let error
            {
            compiler.reportingContext.dispatchError(at: .zero, message: "Code generation error: \(error)")
            return(false)
            }
        }
    }
