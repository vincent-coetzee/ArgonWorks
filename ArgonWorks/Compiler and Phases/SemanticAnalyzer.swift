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
    
//    @discardableResult
//    public static func analyzeModule(_ module: Module) -> Bool
//        {
//        let analyzer = SemanticAnalyzer(compiler: self.compiler)
//        return(analyzer.analyze(node))
//        }
        
    public var virtualMachine: VirtualMachine
        {
        fatalError("Virtual Machine needed")
        }
        
    init(compiler: Compiler)
        {
        self.compiler = compiler
        self.typeContext = TypeContext(scope: compiler.topModule.argonModule)
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    public static func analyzeModule(_ module: Module,in compiler: Compiler) -> Bool
        {
        let analyzer = SemanticAnalyzer(compiler: compiler)
        module.analyzeSemantics(using: analyzer)
        return(!analyzer.wasCancelled)
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
