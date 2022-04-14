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
    internal var argonModule: ArgonModule
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal let source: String
    internal let tokenHandler: TokenHandler?
    
    init(source: String,argonModule: ArgonModule,tokenHandler: TokenHandler? = nil)
        {
        self.argonModule = argonModule
        self.source = source
        self.currentPass = nil
        self.tokenHandler = tokenHandler
        }

//    init(tokens: Tokens,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
//        {
//        Argon.resetStatics()
//        Argon.resetTypes()
//        TopModule.resetTopModule()
//        self.currentPass = nil
//        self.source = ""
//        self.tokenRenderer = tokenRenderer
//        self.reporter = reportingContext
////        let cleanTokens = tokens.filter{!$0.isWhitespace}
//        }

    public func cancelCompletion()
        {
        self.completionWasCancelled = true
        }

//                    ArgonModule.shared.class.printLayout()
//                    ArgonModule.shared.array.printLayout()
//                    ArgonModule.shared.object.printLayout()
//                    ArgonModule.shared.slot.printLayout()
//                    let memoryPointer = MemoryPointer(address: ArgonModule.shared.object.memoryAddress)
//                    MemoryPointer.dumpMemory(atAddress: memoryPointer.address,count: 100)
//                    try! allocator.payload.write(toPath: "/Users/vincent/Desktop/NewFile.argonv")
//                    try! ObjectFile.write(module: module, topModule: TopModule.shared, atPath: "file:///Users/vincent/Desktop/test.argono")
//                    let objectFile = try! ObjectFile.read(atPath: "file:///Users/vincent/Desktop/test.argono",topModule: TopModule.shared)
//                    objectFile!.module.display(indent: "")

    @discardableResult
    public func compile(parseOnly: Bool = false) -> Module?
        {
        let addressAllocator = AddressAllocator(argonModule: self.argonModule)
        let parser = Parser(self)
        parser.tokenHandler = self.tokenHandler
        guard let parsedModule = parser.processModule(nil) else
            {
            return(nil)
            }
        guard let typeCheckedModule = parsedModule.typeCheckModule() else
            {
            return(parsedModule)
            }
        guard let addressAllocatedModule = addressAllocator.processModule(typeCheckedModule) else
            {
            return(typeCheckedModule)
            }
        guard let codeGeneratedModule = CodeGenerator(self,addressAllocator: addressAllocator).processModule(addressAllocatedModule) else
            {
            return(addressAllocatedModule)
            }
        addressAllocator.payload.installArgonModule(self.argonModule)
        addressAllocator.payload.installClientModule(codeGeneratedModule)
        addressAllocator.payload.installMainMethod(codeGeneratedModule.mainMethod)
//        try! ObjectFile.write(module: addressAllocatedModule, topModule: TopModule.shared, atPath: "/Users/vincent/Desktop/Test.armod")
        let vm = VirtualMachine(payload: addressAllocator.payload)
        try! vm.payload.write(toPath: "/Users/vincent/Desktop/InferenceSample.carton")
        codeGeneratedModule.display(indent: "")
        guard let optimizedModule = Optimizer(self).processModule(codeGeneratedModule) else
            {
            return(codeGeneratedModule)
            }
//        let visitor = IssueVisitor.visit(optimizedModule)
//        print(visitor.allIssues)
        let someIssues = optimizedModule.issues
        print(someIssues)
//        self.reporter.pushIssues(visitor.allIssues)
        return(optimizedModule)
        }
    }
