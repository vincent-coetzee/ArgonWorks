//
//  MethodInstanceBlock.swift
//  MethodInstanceBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class MethodInstanceBlock: Block
    {
    private let _methodInstance: MethodInstance
    
    public override var methodInstance: MethodInstance
        {
        return(self._methodInstance)
        }
        
    init(methodInstance:MethodInstance)
        {
        self._methodInstance = methodInstance
        super.init()
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
        
    public override func realize(using realizer:Realizer)
        {
        for slot in self.localSlots
            {
            slot.realize(using: realizer)
            }
        for block in self.blocks
            {
            block.realize(using: realizer)
            }
        }
        
    public func addParameters(_ parameters: Parameters)
        {
        for parameter in parameters
            {
            self.addLocalSlot(parameter)
            }
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
