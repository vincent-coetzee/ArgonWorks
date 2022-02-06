////
////  MethodInstanceBlock.swift
////  MethodInstanceBlock
////
////  Created by Vincent Coetzee on 4/8/21.
////
//
//import Foundation
//
//public class MethodInstanceBlock: Block
//    {
//    public override var container: Container
//        {
//        get
//            {
//            .methodInstance(methodInstance!)
//            }
//        set
//            {
//            }
//        }
//        
//    public override var declaration: Location?
//        {
//        self.methodInstance.isNil ? .zero : self.methodInstance!.declaration
//        }
//        
//    required init()
//        {
//        super.init()
//        }
//        
//    public var methodInstance: MethodInstance?
//    
//    init(methodInstance:MethodInstance)
//        {
//        super.init()
//        self.methodInstance = methodInstance
//        }
//        
//    public required init?(coder: NSCoder)
//        {
//        super.init(coder: coder)
//        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
//        }
//    
//    public override func encode(with coder: NSCoder)
//        {
//        coder.encode(self.methodInstance,forKey: "methodInstance")
//        super.encode(with: coder)
//        }
//        
//    public override func lookup(label: String) -> Symbol?
//        {
//        for symbol in self.localSymbols
//            {
//            if symbol.label == label
//                {
//                return(symbol)
//                }
//            }
//        return(nil)
//        }
//        
//    public override func display(indent: String)
//        {
//        print("START OF METHOD INSTANCE BLOCK--------------------------------------------------------------------------------")
//        print("\(indent)\(Swift.type(of: self))")
//        for block in self.blocks
//            {
//            block.display(indent: indent + "\t")
//            }
//        print("END OF METHOD INSTANCE BLOCK----------------------------------------------------------------------------------")
//        }
//        
//    public override func initializeTypeConstraints(inContext context: TypeContext)
//        {
//        for block in self.blocks
//            {
//            block.initializeTypeConstraints(inContext: context)
//            }
//        let returnBlocks = self.returnBlocks.filter{$0.containsMethodInstanceScope}
//        for block in returnBlocks
//            {
//            context.append(TypeConstraint(left: block.type, right: self.type, origin: .block(self)))
//            }
//        }
//        
//    public override func initializeType(inContext context: TypeContext)
//        {
//        for block in self.blocks
//            {
//            block.initializeType(inContext: context)
//            }
//        self.type = ArgonModule.shared.void
//        }
//        
//    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
//        {
//        for block in self.blocks
//            {
//            block.analyzeSemantics(using: analyzer)
//            }
//        }
//        
//    public override func emitCode(into: T3ABuffer,using: CodeGenerator) throws
//        {
//        for symbol in self.localSymbols
//            {
//            try symbol.emitCode(into: into,using: using)
//            }
//        for block in self.blocks
//            {
//            try block.emitCode(into: into,using: using)
//            }
//        }
//        
//    public func dump()
//        {
//        print("METHOD INSTANCE BLOCK")
//        print("=====================")
//        for block in self.blocks
//            {
//            block.dump(depth: 4)
//            }
//        }
//    }
