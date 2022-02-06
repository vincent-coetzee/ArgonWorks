//
//  EnumerationInstanceExpression.swift
//  EnumerationInstanceExpression
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class EnumerationInstanceExpression: Expression
    {
    public override var displayString: String
        {
        "ERROR"
        }
        
    public let enumeration: TypeEnumeration
    public let caseSymbol: Argon.Symbol
    public let associatedValues: Array<Expression>?
    
    required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as! TypeEnumeration
        self.caseSymbol = coder.decodeObject(forKey:"caseSymbol") as! Argon.Symbol
        self.associatedValues = coder.decodeObject(forKey:"associatedValues") as? Array<Expression>
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.enumeration,forKey: "enumeration")
        coder.encode(self.caseSymbol,forKey: "caseSymbol")
        coder.encode(self.associatedValues,forKey: "associatedValues")
        }
        
    init(enumeration: TypeEnumeration,caseSymbol: Argon.Symbol,associatedValues: Array<Expression>?)
        {
        self.enumeration = enumeration
        self.caseSymbol = caseSymbol
        self.associatedValues = associatedValues
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.enumeration.visit(visitor: visitor)
//        try self.caseSymbol.visit(visitor: visitor)
        for expression in self.associatedValues!
            {
            try expression.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        fatalError()
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        let types = self.associatedValues.isNil ? [] : self.associatedValues!.map{$0.type}
        self.associatedValues?.forEach{$0.initializeType(inContext: context)}
        self.enumeration.initializeType(inContext: context)
        self.type = self.enumeration
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        context.append(TypeConstraint(left: self.type,right: self.enumeration,origin: .expression(self)))
        if let aCase = self.enumeration.case(forSymbol: self.caseSymbol),let values = self.associatedValues,values.count == aCase.associatedTypes.count
            {
            for (aType,caseType) in zip(values.map{$0.type},aCase.associatedTypes)
                {
                context.append(TypeConstraint(left: aType,right: caseType,origin: .expression(self)))
                }
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.emitAddressCode(into: instance,using: generator)
        }
        
    public override func emitValueCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.emitAddressCode(into: instance,using: generator)
        }
        
    public override func emitAddressCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
        let temp1 = instance.nextTemporary
        instance.add(.MAKE,.address(ArgonModule.shared.enumerationCaseInstance.memoryAddress),temp1)
        let temp2 = instance.nextTemporary
        instance.add(.MOVE,temp1,temp2)
        instance.add(.i64,.ADD,temp2,.integer(Argon.Integer(ArgonModule.shared.enumerationCaseInstance.classValue.layoutSlot(atLabel: "enumeration").offset)),temp2)
        instance.add(.STOREP,temp2,.address(self.enumeration.memoryAddress),.integer(0))
        instance.add(.MOVE,temp1,temp2)
        instance.add(.i64,.ADD,temp2,.integer(Argon.Integer(ArgonModule.shared.enumerationCaseInstance.classValue.layoutSlot(atLabel: "caseIndex").offset)),temp2)
        let caseIndex = self.enumeration.caseIndex(forSymbol: self.caseSymbol)!
        instance.add(.STOREP,.integer(Argon.Integer(caseIndex)),temp2,.integer(0))
        instance.add(.MOVE,temp1,temp2)
        instance.add(.i64,.ADD,temp2,.integer(Argon.Integer(ArgonModule.shared.enumerationCaseInstance.classValue.layoutSlot(atLabel: "associatedValueCount").offset)),temp2)
        instance.add(.STOREP,.integer(Argon.Integer(self.associatedValues?.count ?? 0)),temp2,.integer(0))
        if let values = self.associatedValues
            {
            instance.add(.i64,.ADD,temp1,.integer(Argon.Integer(ArgonModule.shared.enumerationCaseInstance.instanceSizeInBytes)),temp2)
            for value in values
                {
                try value.emitCode(into: instance,using: generator)
                instance.add(.STOREP,temp2,value.place,.integer(0))
                instance.add(.i64,.ADD,.integer(8),temp2,temp2)
                }
            }
        self._place = temp1
        }
    }
