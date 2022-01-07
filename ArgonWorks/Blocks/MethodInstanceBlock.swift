//
//  MethodInstanceBlock.swift
//  MethodInstanceBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class MethodInstanceBlock: Block
    {
    internal var methodInstance: MethodInstance?
        
    public override var declaration: Location?
        {
        self.methodInstance?.declaration
        }
        
    required init()
        {
        self.methodInstance = nil
        super.init()
        }
        
    init(methodInstance:MethodInstance)
        {
        self.methodInstance = methodInstance
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        super.init(coder: coder)
        }
    
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.methodInstance,forKey: "methodInstance")
        super.encode(with: coder)
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public func addParameters(_ parameters: Parameters)
        {
        for parameter in parameters
            {
            self.methodInstance?.addParameterSlot(parameter)
            }
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = super.substitute(from: substitution)
        for block in self.blocks
            {
            newBlock.addBlock(substitution.substitute(block))
            }
        newBlock.type = substitution.substitute(self.type)
        newBlock.issues = self.issues
        return(newBlock)
        }
        
    public override func display(indent: String)
        {
        print("START OF METHOD INSTANCE BLOCK--------------------------------------------------------------------------------")
        print("\(indent)\(Swift.type(of: self))")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        print("END OF METHOD INSTANCE BLOCK----------------------------------------------------------------------------------")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        let returnBlocks = self.returnBlocks.filter{$0.containsMethodInstanceScope}
        for block in returnBlocks
            {
            context.append(TypeConstraint(left: block.type, right: self.type, origin: .block(self)))
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        self.type = ArgonModule.shared.void
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func emitCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        for symbol in self.localSymbols
            {
            try symbol.emitCode(into: into,using: using)
            }
        for block in self.blocks
            {
            try block.emitCode(into: into,using: using)
            }
        }
        
    public func dump()
        {
        print("METHOD INSTANCE BLOCK")
        print("=====================")
        for block in self.blocks
            {
            block.dump(depth: 4)
            }
        }
    }
