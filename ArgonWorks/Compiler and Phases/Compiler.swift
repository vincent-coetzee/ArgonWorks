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
        TopModule.shared.argonModule.classes.map{$0.label}
        }
    
    public static let cleanData = try! NSKeyedArchiver.archivedData(withRootObject: TopModule.shared, requiringSecureCoding: false)
    
    public var argonModule: ArgonModule
        {
        return(self.topModule.argonModule)
        }
        
    internal var reportingContext:ReportingContext
    private var parser: Parser!
    internal var lastNode: ParseNode?
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var topModule: TopModule
    internal var tokenRenderer:SemanticTokenRenderer
    
    init(source: String,reportingContext: ReportingContext = NullReportingContext.shared,tokenRenderer: SemanticTokenRenderer = NullTokenRenderer())
        {
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        self.topModule = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Self.cleanData) as! TopModule
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        self.parser = Parser(compiler: self,source: source)
        self.currentPass = self.parser
        self.tokenRenderer.update(source)
        }
        
    init(tokens: Tokens,reportingContext: ReportingContext = NullReportingContext.shared,tokenRenderer: SemanticTokenRenderer = NullTokenRenderer())
        {
        self.parser = nil
        self.currentPass = nil
        self.lastNode = nil
        self.topModule = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Self.cleanData) as! TopModule
        self.reportingContext = reportingContext
        self.tokenRenderer = tokenRenderer
        self.parser = Parser(compiler: self,tokens: tokens)
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
        if let node = self.parser.parse(),!parseOnly
            {
            self.topModule.resolveReferences(topModule: self.topModule)
            Realizer.realize(node,in:self)
            SemanticAnalyzer.analyze(node,in:self)
            AddressAllocator.allocateAddresses(node,in: self)
            CodeGenerator.emit(into: node,in:self)
            Optimizer.optimize(node,in:self)
            return(node)
            }
        return(nil)
        }
    }
