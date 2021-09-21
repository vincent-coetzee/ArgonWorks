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
    
    @discardableResult
    public static func analyze(_ node:ParseNode,in compiler:Compiler) -> Bool
        {
        let analyzer = SemanticAnalyzer(compiler: compiler)
        return(analyzer.analyze(node))
        }
        
    public var virtualMachine: VirtualMachine
        {
        fatalError("Virtual Machine needed")
        }
        
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    private func analyze(_ node:ParseNode) -> Bool
        {
        node.analyzeSemantics(using: self)
        return(!self.wasCancelled)
        }
    }

//public class TypeInferencer
//    {
//    public class Environment
//        {
//        private var types:[String:LocalType] = [:]
//        }
//        
//    public indirect enum LocalType
//        {
//        case named(Class)
//        case variable(String)
//        case function(String,LocalType,LocalType)
//        }
//        
//    private var nextVariable = 0
//    
//    public func infer(expression: Expression) -> LocalType
//        {
//        if expression is LiteralExpression
//            {
//            let literal = expression as! LiteralExpression
//            return(.named(literal.resultType.class!))
//            }
//        else if expression is LocalSlotExpression
//            {
//            let local = expression as! LocalSlotExpression
//            let localSlot = local.localSlot
//            return(.named(localSlot.type))
//            }
//        return(.named(self.compiler.topModule.argonModule.void))
//        }
//    }
