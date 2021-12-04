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
    private static var instanceCounter = 1
    
    public static var systemClassNames: Array<String>
        {
        TopModule(compiler: Compiler()).argonModule.classes.map{$0.label}
        }

    public var argonModule: ArgonModule
        {
        return(self.topModule.argonModule)
        }
        
    public private(set) var allIssues: CompilerIssues = []
    internal var reportingContext:Reporter
    private var parser: Parser!
    internal var lastNode: ParseNode?
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var topModule: TopModule!
    internal var tokenRenderer:SemanticTokenRenderer
    internal let instanceNumber: Int
    
    init()
        {
        self.instanceNumber = Self.instanceCounter
        Self.instanceCounter += 1
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        self.reportingContext = NullReporter()
        self.tokenRenderer = NullTokenRenderer()
        self.topModule = TopModule(compiler: self)
        self.parser = Parser(compiler: self,source: "")
        self.currentPass = self.parser
        self.tokenRenderer.update("")

        }
        
    init(source: String,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        self.instanceNumber = Self.instanceCounter
        Self.instanceCounter += 1
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        print("COMPILER TOPMODULE ADDRESS \(unsafeBitCast(self.topModule,to: Int.self))")
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        self.topModule = TopModule(compiler: self)
        self.parser = Parser(compiler: self,source: source)
        self.currentPass = self.parser
        self.tokenRenderer.update(source)
        }

    init(tokens: Tokens,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        self.instanceNumber = Self.instanceCounter
        Self.instanceCounter += 1
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        print("COMPILER TOPMODULE ADDRESS \(unsafeBitCast(self.topModule,to: Int.self))")
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        let cleanTokens = tokens.filter{!$0.isWhitespace}
        self.topModule = TopModule(compiler: self)
        self.topModule.printContents("\t")
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
            SemanticAnalyzer.analyzeModule(module,in:self)
            AddressAllocator.allocateAddresses(module,in: self)
            CodeGenerator.emit(into: module,in:self)
            Optimizer.optimize(module,in:self)
            let visitor = TestVisitor.visit(module)
            self.allIssues = visitor.allIssues
            let someIssues = module.issues
            print(someIssues)
            self.reportingContext.pushIssues(self.allIssues)
            let newModule = module.checkTypes()
            module.display(indent: "")
            newModule.display(indent:"")
            return(module)
            }
        return(nil)
        }
    }
