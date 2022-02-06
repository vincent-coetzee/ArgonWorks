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
    
    internal var currentPass: CompilerPass?
    internal var completionWasCancelled: Bool = false
    internal var tokenRenderer:SemanticTokenRenderer
    internal let source: String
    internal let reporter: Reporter
    
    init(source: String,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        Argon.resetStatics()
        Argon.resetTypes()
        TopModule.resetTopModule()
        self.source = source
        self.currentPass = nil
        self.tokenRenderer = tokenRenderer
        self.tokenRenderer.update(source)
        self.reporter = reportingContext
        }

    init(tokens: Tokens,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        Argon.resetStatics()
        Argon.resetTypes()
        TopModule.resetTopModule()
        self.currentPass = nil
        self.source = ""
        self.tokenRenderer = tokenRenderer
        self.reporter = reportingContext
//        let cleanTokens = tokens.filter{!$0.isWhitespace}
        }

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
    public func compile(parseOnly: Bool = false,moduleReceiver: ModuleReceiver? = nil) -> Module?
        {
        let addressAllocator = AddressAllocator()
        if let module = Parser(self).processModule(nil)
            {
            if let module = module.typeCheckModule()
                {
                if let module = addressAllocator.processModule(module)
                    {
                    if let module = CodeGenerator(self,addressAllocator: addressAllocator).processModule(module)
                        {
                        moduleReceiver?.moduleUpdated(module)
                        addressAllocator.payload.installArgonModule(ArgonModule.shared)
                        addressAllocator.payload.installClientModule(module)
                        addressAllocator.payload.installMainMethod(module.mainMethod)
                        let vm = VirtualMachine(payload: addressAllocator.payload)
                        try! vm.payload.write(toPath: "/Users/vincent/Desktop/InferenceSample.carton")
                        module.display(indent: "")
                        for symbol in module.symbols
                            {
                            print("\(symbol.label) \(Swift.type(of: symbol)) \(symbol.memoryAddress)")
                            }
                        if let module = Optimizer(self).processModule(module)
                            {
                            let visitor = TestVisitor.visit(module)
//                            self.allIssues = visitor.allIssues
//                            print(visitor.allIssues)
                            let someIssues = module.issues
//                            print(someIssues)
                            self.reporter.pushIssues(visitor.allIssues)
                            return(module)
                            }

                        }
                    }
                }
            }
//                }
//            }
        return(nil)
        }
    }
