//
//  EnumerationDecompositionExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/1/22.
//

import Foundation

public class EnumerationDecompositionExpression: Expression
    {
    private let enumeration: TypeEnumeration
    private let symbol: Argon.Symbol
    private let slotNames: Array<String>
    private let value: Expression
    private var slots = Slots()
    public var block = Block()
        {
        didSet
            {
            self.generateSlots()
            }
        }
    
    init(enumeration: TypeEnumeration,caseSymbol: Argon.Symbol,slotNames: Array<String>,value:Expression)
        {
        self.enumeration = enumeration
        self.symbol = caseSymbol
        self.slotNames = slotNames
        self.value = value
        super.init()
        enumeration.container = .expression(self)
        value.container = .expression(self)
        }
        
    public required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as! TypeEnumeration
        self.symbol = coder.decodeObject(forKey: "symbol") as! Argon.Symbol
        self.slotNames = coder.decodeObject(forKey: "slotNames") as! Array<String>
        self.slots = coder.decodeObject(forKey: "slots") as! Array<Slot>
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.value = coder.decodeObject(forKey: "value") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.enumeration,forKey: "enumeration")
        coder.encode(self.symbol,forKey: "symbol")
        coder.encode(self.slotNames,forKey: "slotNames")
        coder.encode(self.slots,forKey: "slots")
        coder.encode(self.block,forKey: "block")
        coder.encode(self.value,forKey: "value")
        super.encode(with: coder)
        }
        
    private func generateSlots()
        {
        let aCase = self.enumeration.lookup(label: self.symbol) as! EnumerationCase
        for (label,type) in zip(self.slotNames,aCase.associatedTypes)
            {
            let slot = LocalSlot(label: label, type: type,value: nil)
            self.slots.append(slot)
            self.block.addLocalSlot(slot)
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let new = EnumerationDecompositionExpression(enumeration: self.enumeration,caseSymbol: self.symbol,slotNames: self.slotNames,value: self.value.freshTypeVariable(inContext: context))
        new.slots = self.slots.map{$0.freshTypeVariable(inContext: context)}
        new.locations = self.locations
        return(new as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for slot in self.slots
            {
            slot.initializeType(inContext: context)
            }
        let aCase = self.enumeration.lookup(label: self.symbol) as! EnumerationCase
        self.type = TypeConstructor(label: self.symbol, generics: [self.enumeration] + aCase.associatedTypes)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let new = EnumerationDecompositionExpression(enumeration: substitution.substitute(self.enumeration),caseSymbol: self.symbol,slotNames: self.slotNames,value: substitution.substitute(self.value))
        new.slots = self.slots.map{substitution.substitute($0)}
        new.type = substitution.substitute(self.type)
        new.locations = self.locations
        return(new as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        var index = 0
        let aCase = self.enumeration.`case`(forSymbol: self.symbol)!
        for slot in self.slots
            {
            slot.initializeTypeConstraints(inContext: context)
            context.append(TypeConstraint(left: slot.type,right: aCase.associatedTypes[index],origin: .expression(self)))
            index += 1
            }
        context.append(TypeConstraint(left: self.type,right: context.booleanType,origin: .expression(self)))
        }
        
    public override func emitCode(into instance: InstructionBuffer, using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
        try self.value.emitAddressCode(into: instance,using: generator)
        let caseIndex = self.enumeration.caseIndex(forSymbol: self.symbol)!
        let aClass = generator.argonModule.enumerationCaseInstance as! TypeClass
        let temp = instance.nextTemporary
        // LOAD VALUE OF slot.caseIndex INTO temp
        instance.add(.LOADP,self.value.place,.integer(Argon.Integer(aClass.instanceSlot(atLabel: "caseIndex").offset)),temp)
        // DOES enumerationInstance.case.caseIndex == caseIndex
        instance.add(.MOVE,.integer(0),temp)
        instance.add(.i64,.EQ,temp,.integer(Argon.Integer(caseIndex)),temp)
        let label = instance.nextLabel
        // BRANCH IF FALSE TO label
        instance.add(.BRF,temp,label.operand)
        instance.add(.i64,.ADD,self.value.place,.integer(Argon.Integer(aClass.instanceSizeInBytes)),temp)
        var offset:Argon.Integer = 0
        for slot in self.slots
            {
            instance.add(.LOADP,temp,.integer(offset),.frameOffset(slot.offset))
            offset += 8
            }
        instance.add(.MOVE,.integer(1),temp)
        instance.pendingLabel = label
        instance.add(.NOP)
        self._place = temp
        }
    }
