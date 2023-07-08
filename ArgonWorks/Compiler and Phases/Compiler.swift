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
            
    init(source: String,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        Argon.resetStatics()
        Argon.resetTypes()
        TopModule.resetTopModule()
        self.source = source
        self.currentPass = nil
        self.tokenRenderer = tokenRenderer
        self.tokenRenderer.update(source)

        }

    init(tokens: Tokens,reportingContext: Reporter,tokenRenderer: SemanticTokenRenderer)
        {
        Argon.resetStatics()
        Argon.resetTypes()
        TopModule.resetTopModule()
        self.currentPass = nil
        self.source = ""
        self.tokenRenderer = tokenRenderer
//        let cleanTokens = tokens.filter{!$0.isWhitespace}
        }

    public func cancelCompletion()
        {
        self.completionWasCancelled = true
        }

    @discardableResult
    public func compile(parseOnly: Bool = false) -> Module?
        {
//        self.reportingContext.resetReporting()
        if let module = Parser(self).processModule(nil)
            {
            if let module = module.typeCheckModule()
                {
                let allocator = AddressAllocator(self)
                if let module = allocator.processModule(module)
                    {
                    ArgonModule.shared.class.printLayout()
                    ArgonModule.shared.array.printLayout()
                    ArgonModule.shared.object.printLayout()
                    ArgonModule.shared.slot.printLayout()
                    let memoryPointer = MemoryPointer(address: ArgonModule.shared.object.memoryAddress)
                    MemoryPointer.dumpMemory(atAddress: memoryPointer.address,count: 100)
                    try! allocator.payload.write(toPath: "/Users/vincent/Desktop/TestFile.arv")
                    try! ObjectFile.write(module: module, topModule: TopModule.shared, atPath: "file:///Users/vincent/Desktop/module.argono")
                    let objectFile = try! ObjectFile.read(atPath: "file:///Users/vincent/Desktop/module.argono",topModule: TopModule.shared)
                    objectFile!.module.display(indent: "")
                    if let module = CodeGenerator(self,payload: allocator.payload).processModule(module)
                        {
                        let vm = VirtualMachine(payload: allocator.payload)
                        module.install(inContext: vm.payload)
                        module.display(indent: "")
                        if let module = Optimizer(self).processModule(module)
                            {
                            let visitor = TestVisitor.visit(module)
//                            self.allIssues = visitor.allIssues
                            print(visitor.allIssues)
                            let someIssues = module.issues
                            print(someIssues)
//                            self.reportingContext.pushIssues(self.allIssues)
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
