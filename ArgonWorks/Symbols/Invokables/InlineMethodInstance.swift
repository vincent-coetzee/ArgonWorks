//
//  InlineMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/1/22.
//

import Foundation

public class Inline
    {
    public struct InlineParameter
        {
        let label: Label
        let type: Type
        }
        
    public typealias InlineElement = (Label,Type)
    
    
    private let label: Label
    private let object1Type: Type
    private var object2Type: Type? = nil
    private var elements: Array<InlineElement> = []
    
    public init(_ label: String,_ object1:Type)
        {
        self.label = label
        self.object1Type = object1
        self.object2Type = nil
        }
        
    public init(_ label: String,_ object1:Type,_ object2:Type)
        {
        self.label = label
        self.object1Type = object1
        self.object2Type = object2
        }
        
    public init(_ label: String,_ parameters: InlineElement...)
        {
        self.label = label
        self.object1Type = TypeContext.freshTypeVariable()
        self.elements = parameters
        }
        
    public func returns(_ type: Type) -> InlineMethodInstance
        {
        let instance = InlineMethodInstance(label: self.label)
        if elements.isEmpty
            {
            instance.parameters = [Parameter(label: "object", relabel: nil, type: self.object1Type, isVisible: false, isVariadic: false)]
            if self.object2Type.isNotNil
                {
                instance.parameters.append(Parameter(label: "value", relabel: nil, type: self.object2Type!, isVisible: false, isVariadic: false))
                }
            }
        else
            {
            let parameters = self.elements.map{Parameter(label: $0.0, relabel: nil, type: $0.1, isVisible: true, isVariadic: false)}
            instance.parameters = parameters
            }
        instance.returnType = type
        return(instance)
        }
    }
    
public class InlineMethodInstance: StandardMethodInstance
    {
    public override var isInlineMethodInstance: Bool
        {
        true
        }
        
    internal var closure: (Arguments,CodeGenerator,InstructionBuffer) -> Void = {a,b,c in }
    
    public func emitCode(into buffer:InstructionBuffer,using generator:CodeGenerator,arguments: Arguments)
        {
        self.closure(arguments,generator,buffer)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = self.returnType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        context.append(TypeConstraint(left: self.type,right: self.returnType,origin: .symbol(self)))
        }
        
    public func classMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.i64,.CLASS,arguments[0].value.place,.register(.RR))
            }
        self.returnType = ArgonModule.shared.classType
        return(self)
        }
        
    public func listAppendMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
//            try! arguments[1].value.emitAddressCode(into: buffer, using: generator)
//            let temp = buffer.nextTemporary
//            let address = ArgonModule.shared.listNode
//            buffer.add(.MAKE,.address(address.memoryAddress),temp)
//            let slot1 = ArgonModule.shared.listNode.lookup(label: "element") as! Slot
//            let temp2 = buffer.nextTemporary
//            buffer.add(.MOVE,temp,temp2)
//            buffer.add(.i64,.ADD,temp2,.integer(Argon.Integer(slot1.offset)),temp2)
//            buffer.add(.STOREP,arguments[1].value.place,temp2,.integer(0))
//            let slot2 = ArgonModule.shared.list.lookup(label: "last") as! Slot
//            let temp3 = buffer.nextTemporary
//            buffer.add(.MOVE,arguments[0].value.place,temp3)
//            buffer.add(.i64,.ADD,temp3,.integer(Argon.Integer(slot2.offset)),temp3)
//            let temp4 = buffer.nextTemporary
//            buffer.add(.LOADP,temp3,.integer(0),temp4)
//            buffer.add(.STOREP,
            }
        self.returnType = ArgonModule.shared.classType
        return(self)
        }
        
    public func addressMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.MOVE,arguments[0].value.place,.register(.RR))
            }
        self.returnType = ArgonModule.shared.address
        return(self)
        }
        
    public func stringToFloatMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.float
        return(self)
        }
        
    public func stringToIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)))
            }
        self.returnType = ArgonModule.shared.integer
        return(self)
        }
        
    public func stringToUIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.uInteger.magicNumber)))
            }
        self.returnType = ArgonModule.shared.uInteger
        return(self)
        }
        
    public func stringToByteMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)))
            }
        self.returnType = ArgonModule.shared.byte
        return(self)
        }
        
    public func stringToCharacterMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.character
        return(self)
        }
        
    public func integerToFloatMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.float
        return(self)
        }
        
    public func integerToStringMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)))
            }
        self.returnType = ArgonModule.shared.string
        return(self)
        }
        
    public func integerToUIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.uInteger.magicNumber)))
            }
        self.returnType = ArgonModule.shared.uInteger
        return(self)
        }
        
    public func integerToByteMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)))
            }
        self.returnType = ArgonModule.shared.byte
        return(self)
        }
        
    public func integerToCharacterMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.character
        return(self)
        }
        
    public func floatToStringMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)))
            }
        self.returnType = ArgonModule.shared.string
        return(self)
        }
        
    public func floatToIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)))
            }
        self.returnType = ArgonModule.shared.integer
        return(self)
        }
        
    public func floatToUIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.uInteger.magicNumber)))
            }
        self.returnType = ArgonModule.shared.uInteger
        return(self)
        }
        
    public func floatToByteMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)))
            }
        self.returnType = ArgonModule.shared.byte
        return(self)
        }
        
    public func floatToCharacterMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.character
        return(self)
        }
        
    public func byteToStringMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)))
            }
        self.returnType = ArgonModule.shared.string
        return(self)
        }
        
    public func byteToIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)))
            }
        self.returnType = ArgonModule.shared.integer
        return(self)
        }
        
    public func byteToUIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.uInteger.magicNumber)))
            }
        self.returnType = ArgonModule.shared.uInteger
        return(self)
        }
        
    public func byteToFloatMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.float
        return(self)
        }
        
    public func byteToCharacterMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.character
        return(self)
        }
        
    public func characterToStringMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.character.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.string.magicNumber)))
            }
        self.returnType = ArgonModule.shared.string
        return(self)
        }
        
    public func characterToIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.character.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.integer.magicNumber)))
            }
        self.returnType = ArgonModule.shared.integer
        return(self)
        }
        
    public func characterToUIntegerMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.character.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.uInteger.magicNumber)))
            }
        self.returnType = ArgonModule.shared.uInteger
        return(self)
        }
        
    public func characterToFloatMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.character.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.float.magicNumber)))
            }
        self.returnType = ArgonModule.shared.float
        return(self)
        }
        
    public func characterToByteMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(ArgonModule.shared.character.magicNumber)),.integer(Argon.Integer(ArgonModule.shared.byte.magicNumber)))
            }
        self.returnType = ArgonModule.shared.byte
        return(self)
        }
        
    public func addDateToDateComponent() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DATECADD,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subDateComponentFromDate() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DATECSUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func addTimeToTimeComponent() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.TIMECADD,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subTimeComponentFromTime() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.TIMECSUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func addDateTimeToComponent() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DTIMCADD,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subComponentFromDateTime() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DTIMCSUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subDateFromDate() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DATESUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subTimeFromTime() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.TIMSUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func subDateTimeFromDateTime() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.DTIMSUB,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func differenceBetweenDatesMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[0].value.place)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[1].value.place)
            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[2].value.place)
            buffer.add(.DDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func differenceBetweenTimesMethod() -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[0].value.place)
            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[1].value.place)
            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.PUSH,arguments[2].value.place)
            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
    }
