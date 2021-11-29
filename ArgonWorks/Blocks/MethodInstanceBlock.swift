//
//  MethodInstanceBlock.swift
//  MethodInstanceBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class MethodInstanceBlock: Block
    {
    private var _methodInstance: MethodInstance
    
    public override var methodInstance: MethodInstance
        {
        return(self._methodInstance)
        }
        
    required init()
        {
        self._methodInstance = MethodInstance(label: "")
        super.init()
        }
        
    init(methodInstance:MethodInstance)
        {
        self._methodInstance = methodInstance
        super.init()
        self.setParent(methodInstance)
        }
        
    public required init?(coder: NSCoder)
        {
        self._methodInstance = coder.decodeObject(forKey: "methodInstance") as! MethodInstance
        super.init(coder: coder)
        }
    
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.methodInstance.lookup(label: label))
        }
        
    public func addParameters(_ parameters: Parameters)
        {
        for parameter in parameters
            {
            self.addLocalSlot(parameter)
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        let returnBlocks = self.returnBlocks.filter{$0.enclosingScope.isMethodInstanceScope}
        for block in returnBlocks
            {
            context.append(TypeConstraint(left: block.type, right: self.type, origin: .block(self)))
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = self.methodInstance.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func deepCopy() -> Self
        {
        let newBlock = super.deepCopy()
        newBlock._methodInstance = self.methodInstance
        return(newBlock)
        }
        
    public override func addLocalSlot(_ slot:Slot)
        {
        self.methodInstance.addLocalSlot(slot)
        }
        
    public override func encode(with coder: NSCoder)
        {
        print("START ENCODE \(Swift.type(of: self))")
        coder.encode(self._methodInstance,forKey: "methodInstance")
        super.encode(with: coder)
        }
        
    public override func emitCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        for slot in self.localSlots
            {
            try slot.emitCode(into: into,using: using)
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
