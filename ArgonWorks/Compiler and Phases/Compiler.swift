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
//    
//    public static func tokenPublisher() -> AnyPublisher<VisualToken,Never>
//        {
//        let subject = PassthroughSubject<VisualToken,Never>()
//        let newSubject:AnyPublisher<VisualToken,Never> = subject.map{$0.mapColors(systemClassNames: Self.systemClassNames)}.eraseToAnyPublisher()
//        return(newSubject)
//        }

    public var tokenRenderer: TokenRenderer
        {
        return(self.parser?.visualToken ?? TokenRenderer(systemClassNames: self.systemClassNames))
        }
        
    public var systemClassNames: Array<String>
        {
        TopModule.shared.argonModule.classes.map{$0.label}
        }
    
    internal private(set) var namingContext: NamingContext
    private var parser: Parser?
    internal var lastChunk: ParseNode?
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var topModule: TopModule
    internal var currentTag = Int.random(in: 0..<Int.max)
    
    init()
        {
        self.topModule = TopModule.shared
        self.namingContext = TopModule.shared
        }
        
    public var reportingContext:ReportingContext = NullReportingContext.shared
    
    public func cancelCompletion()
        {
        }
        
    public func parseChunk(_ source:String) throws
        {
        if source.isEmpty
            {
            return
            }
        Transaction.abort()
        Transaction.begin()
        self.parser = Parser(compiler: self)
        self.parser!.parseChunk(source)
        }
        
    @discardableResult
    public func compileChunk(_ source:String) -> ParseNode?
        {
        if source.isEmpty
            {
            return(nil)
            }
        self.parser = Parser(compiler: self)
        self.lastChunk = parser!.parseChunk(source)!
        if let chunk = self.lastChunk
            {
            Realizer.realize(chunk,in:self)
            SemanticAnalyzer.analyze(chunk,in:self)
            AddressAllocator.allocateAddresses(chunk,in: self)
            CodeGenerator.emit(into: chunk,in:self)
            Optimizer.optimize(chunk,in:self)
            let module = self.namingContext.primaryContext as! TopModule
            module.dumpMethods()
            return(chunk)
            }
        return(nil)
        }
    }
