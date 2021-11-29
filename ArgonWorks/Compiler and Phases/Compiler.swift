//
//  Compiler.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import Combine

public class Compiler
    {
    public static var systemClassNames: Array<String>
        {
        TopModule().argonModule.classes.map{$0.label}
        }

    public var argonModule: ArgonModule
        {
        return(self.topModule.argonModule)
        }
        
    internal var reportingContext:Reporter
    private var parser: Parser!
    internal var lastNode: ParseNode?
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var topModule: TopModule
    internal var tokenRenderer:SemanticTokenRenderer
    
    init(source: String,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        self.topModule = TopModule()
        print("COMPILER TOPMODULE ADDRESS \(unsafeBitCast(self.topModule,to: Int.self))")
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        self.parser = Parser(compiler: self,source: source)
        self.currentPass = self.parser
        self.tokenRenderer.update(source)
        }

    init(tokens: Tokens,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        self.topModule = TopModule()
        print("COMPILER TOPMODULE ADDRESS \(unsafeBitCast(self.topModule,to: Int.self))")
        self.topModule.printContents("\t")
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        let cleanTokens = tokens.filter{!$0.isWhitespace}
        self.parser = Parser(compiler: self,tokens: cleanTokens)
        self.currentPass = self.parser
        }

    public func cancelCompletion()
        {
        self.completionWasCancelled = true
        }

    @discardableResult
    public func compile(parseOnly: Bool = false) -> ParseNode?
        {
        self.reportingContext.resetReporting()
        if let module = self.parser.parse(),!parseOnly
            {
            let visitor = TestVisitor()
            visitor.startVisit()
            try! module.visit(visitor: visitor)
            visitor.endVisit()
            self.reportingContext.pushIssues()
            SemanticAnalyzer.analyzeModule(module,in:self)
            AddressAllocator.allocateAddresses(module,in: self)
            CodeGenerator.emit(into: module,in:self)
            Optimizer.optimize(module,in:self)
            return(module)
            }
        self.reportingContext.pushIssues()
        return(nil)
        }
    }
