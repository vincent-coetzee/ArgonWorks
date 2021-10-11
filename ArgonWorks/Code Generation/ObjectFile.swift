//
//  ObjectFile.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Foundation

public class ObjectFile: NSObject,NSCoding
    {
    public struct RelocatableEntry
        {
        internal let symbol: Symbol
        internal let relocatable: T3AInstruction.RelocatableValue
        internal let relocatableIndex: Int
        }
        
    private var relocatables: Array<ObjectFile.RelocatableEntry> = []
    internal var relocatablesBySymbolIndex = Dictionary<UUID,RelocatableEntry>()
    internal var relocatablesByIndex = Dictionary<Int,RelocatableEntry>()
    internal var methods: Array<Method> = []
        
    override init()
        {
        }
        
    required public init(coder: NSCoder)
        {
        self.relocatables = coder.decodeRelocatableEntries(forKey: "relocatables")
        self.methods = coder.decodeObject(forKey: "methods") as! Array<Method>
        for entry in self.relocatables
            {
            self.relocatablesBySymbolIndex[entry.symbol.index] = entry
            self.relocatablesByIndex[entry.relocatableIndex] = entry
            }
        }
    
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.relocatables.map{$0.symbol},forKey: "symbols")
        coder.encodeRelocatableEntries(self.relocatables, forKey: "relocatables")
        }
        
    public func addMethod(_ method: Method)
        {
        for instance in method.instances
            {
            self.addMethodInstance(instance)
            }
        }
        
    public func addMethods(_ methods: Methods)
        {
        for method in methods
            {
            self.addMethod(method)
            }
        }
        
    private func processOperand(operandNumber: Int,_ operand: T3AInstruction.Operand,instruction: T3AInstruction)
        {
        guard operand.isRelocatable else
            {
            return
            }
        let value = operand.relocatableValue
        let index = self.relocatables.count
        let entry = RelocatableEntry(symbol: value.symbol!,relocatable: value, relocatableIndex: index)
        self.relocatables.append(entry)
        self.relocatablesBySymbolIndex[entry.symbol.index] = entry
        self.relocatablesByIndex[index] = entry
        switch(operandNumber)
            {
            case 1:
                instruction.operand1 = .relocatable(.relocatableIndex(index))
            case 2:
                instruction.operand2 = .relocatable(.relocatableIndex(index))
            case 3:
                instruction.result = .relocatable(.relocatableIndex(index))
            default:
                break
            }
        }
        
    public func addMethodInstance(_ methodInstance: MethodInstance)
        {
        for instruction in methodInstance.buffer
            {
            self.processOperand(operandNumber: 1,instruction.operand1,instruction: instruction)
            self.processOperand(operandNumber: 2,instruction.operand2,instruction: instruction)
            self.processOperand(operandNumber: 3,instruction.result,instruction: instruction)
            }
        }
    }
