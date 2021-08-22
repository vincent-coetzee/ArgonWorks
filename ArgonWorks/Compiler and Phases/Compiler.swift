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

//    public var tokenRenderer: TokenRenderer
//        {
//        return(self.parser?.visualToken ?? TokenRenderer())
//        }
        
    public var systemClassNames: Array<String>
        {
        self.virtualMachine.argonModule.classes.map{$0.label}
        }
    
    internal private(set) var namingContext: NamingContext
    private var parser: Parser?
    internal var lastChunk: ParseNode?
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var topModule: TopModule
    internal var virtualMachine: VirtualMachine
    
    init(virtualMachine: VirtualMachine)
        {
        self.virtualMachine = virtualMachine
        let module = TopModule(virtualMachine: virtualMachine)
        self.topModule = module
        self.namingContext = module
        }
        
    public var reportingContext:ReportingContext
        {
        return(NullReportingContext.shared)
        }
    
    public func cancelCompletion()
        {
        }
        
    public func compileChunk(_ source:String)
        {
        if source.isEmpty
            {
            return
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
            }
        }
    }
