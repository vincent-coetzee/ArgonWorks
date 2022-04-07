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
    private let argonModule: ArgonModule
    
    public init(_ label: String,_ object1:Type,_ argonModule: ArgonModule)
        {
        self.label = label
        self.object1Type = object1
        self.object2Type = nil
        self.argonModule = argonModule
        }
        
    public init(_ label: String,_ element: InlineElement,_ argonModule: ArgonModule)
        {
        self.label = label
        self.elements = [element]
        self.object1Type = argonModule.void
        self.argonModule = argonModule
        }
        
    public init(_ label: String,_ object1:Type,_ object2:Type,_ argonModule: ArgonModule)
        {
        self.label = label
        self.object1Type = object1
        self.object2Type = object2
        self.argonModule = argonModule
        }
        
    public init(_ label: String,_ argonModule: ArgonModule,_ parameters: InlineElement...)
        {
        self.label = label
        self.object1Type = TypeContext.freshTypeVariable()
        self.elements = parameters
        self.argonModule = argonModule
        }
        
    public func returns(_ type: Type) -> InlineMethodInstance
        {
        let instance = InlineMethodInstance(label: self.label,argonModule: self.argonModule)
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
        
    public func classMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.i64,.CLASS,arguments[0].value.place,.register(.RR))
            }
        self.returnType = argonModule.classType
        return(self)
        }
        
    public func listAppendMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
//            try! arguments[1].value.emitAddressCode(into: buffer, using: generator)
//            let temp = buffer.nextTemporary
//            let address = argonModule.listNode
//            buffer.add(.MAKE,.address(address.memoryAddress),temp)
//            let slot1 = argonModule.listNode.lookup(label: "element") as! Slot
//            let temp2 = buffer.nextTemporary
//            buffer.add(.MOVE,temp,temp2)
//            buffer.add(.i64,.ADD,temp2,.integer(Argon.Integer(slot1.offset)),temp2)
//            buffer.add(.STOREP,arguments[1].value.place,temp2,.integer(0))
//            let slot2 = argonModule.list.lookup(label: "last") as! Slot
//            let temp3 = buffer.nextTemporary
//            buffer.add(.MOVE,arguments[0].value.place,temp3)
//            buffer.add(.i64,.ADD,temp3,.integer(Argon.Integer(slot2.offset)),temp3)
//            let temp4 = buffer.nextTemporary
//            buffer.add(.LOADP,temp3,.integer(0),temp4)
//            buffer.add(.STOREP,
            }
        self.returnType = argonModule.classType
        return(self)
        }
        
    public func addressMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.MOVE,arguments[0].value.place,.register(.RR))
            }
        self.returnType = argonModule.address
        return(self)
        }
        
    public func stringToFloatMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.string.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.float
        return(self)
        }
        
    public func stringToIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.string.magicNumber)),.integer(Argon.Integer(argonModule.integer.magicNumber)))
            }
        self.returnType = argonModule.integer
        return(self)
        }
        
    public func stringToUIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.string.magicNumber)),.integer(Argon.Integer(argonModule.uInteger.magicNumber)))
            }
        self.returnType = argonModule.uInteger
        return(self)
        }
        
    public func stringToByteMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.string.magicNumber)),.integer(Argon.Integer(argonModule.byte.magicNumber)))
            }
        self.returnType = argonModule.byte
        return(self)
        }
        
    public func stringToCharacterMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.string.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.character
        return(self)
        }
        
    public func integerToFloatMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.integer.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.float
        return(self)
        }
        
    public func integerToStringMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.integer.magicNumber)),.integer(Argon.Integer(argonModule.string.magicNumber)))
            }
        self.returnType = argonModule.string
        return(self)
        }
        
    public func integerToUIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.integer.magicNumber)),.integer(Argon.Integer(argonModule.uInteger.magicNumber)))
            }
        self.returnType = argonModule.uInteger
        return(self)
        }
        
    public func integerToByteMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.integer.magicNumber)),.integer(Argon.Integer(argonModule.byte.magicNumber)))
            }
        self.returnType = argonModule.byte
        return(self)
        }
        
    public func integerToCharacterMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.integer.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.character
        return(self)
        }
        
    public func floatToStringMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.float.magicNumber)),.integer(Argon.Integer(argonModule.string.magicNumber)))
            }
        self.returnType = argonModule.string
        return(self)
        }
        
    public func floatToIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.float.magicNumber)),.integer(Argon.Integer(argonModule.integer.magicNumber)))
            }
        self.returnType = argonModule.integer
        return(self)
        }
        
    public func floatToUIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.float.magicNumber)),.integer(Argon.Integer(argonModule.uInteger.magicNumber)))
            }
        self.returnType = argonModule.uInteger
        return(self)
        }
        
    public func floatToByteMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.float.magicNumber)),.integer(Argon.Integer(argonModule.byte.magicNumber)))
            }
        self.returnType = argonModule.byte
        return(self)
        }
        
    public func floatToCharacterMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.float.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.character
        return(self)
        }
        
    public func byteToStringMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.byte.magicNumber)),.integer(Argon.Integer(argonModule.string.magicNumber)))
            }
        self.returnType = argonModule.string
        return(self)
        }
        
    public func byteToIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.byte.magicNumber)),.integer(Argon.Integer(argonModule.integer.magicNumber)))
            }
        self.returnType = argonModule.integer
        return(self)
        }
        
    public func byteToUIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.byte.magicNumber)),.integer(Argon.Integer(argonModule.uInteger.magicNumber)))
            }
        self.returnType = argonModule.uInteger
        return(self)
        }
        
    public func byteToFloatMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.byte.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.float
        return(self)
        }
        
    public func byteToCharacterMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.byte.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.character
        return(self)
        }
        
    public func characterToStringMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.character.magicNumber)),.integer(Argon.Integer(argonModule.string.magicNumber)))
            }
        self.returnType = argonModule.string
        return(self)
        }
        
    public func characterToIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.character.magicNumber)),.integer(Argon.Integer(argonModule.integer.magicNumber)))
            }
        self.returnType = argonModule.integer
        return(self)
        }
        
    public func characterToUIntegerMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.character.magicNumber)),.integer(Argon.Integer(argonModule.uInteger.magicNumber)))
            }
        self.returnType = argonModule.uInteger
        return(self)
        }
        
    public func characterToFloatMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.character.magicNumber)),.integer(Argon.Integer(argonModule.float.magicNumber)))
            }
        self.returnType = argonModule.float
        return(self)
        }
        
    public func characterToByteMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitAddressCode(into: buffer, using: generator)
            buffer.add(.CONVERT,arguments[0].value.place,.integer(Argon.Integer(argonModule.character.magicNumber)),.integer(Argon.Integer(argonModule.byte.magicNumber)))
            }
        self.returnType = argonModule.byte
        return(self)
        }
        
    public func addDateToDateComponent(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subDateComponentFromDate(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func addTimeToTimeComponent(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subTimeComponentFromTime(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func addDateTimeToComponent(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subComponentFromDateTime(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subDateFromDate(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subTimeFromTime(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func subDateTimeFromDateTime(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func differenceBetweenDatesMethod(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func differenceBetweenTimesMethod(argonModule: ArgonModule) -> StandardMethodInstance
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
        
    public func setInsertMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func setContainsMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func setIntersectionMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func setUnionMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func setRemoveMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func listRemoveMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func listInsertMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
//    public func listAppendMethod(argonModule: ArgonModule) -> StandardMethodInstance
//        {
//        self.closure =
//            {
//            (arguments,generator,buffer) -> Void in
////            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
////            buffer.add(.PUSH,arguments[0].value.place)
////            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
////            buffer.add(.PUSH,arguments[1].value.place)
////            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
////            buffer.add(.PUSH,arguments[2].value.place)
////            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
////            buffer.add(.POPN,.integer(Argon.Integer(3)))
//            }
//        return(self)
//        }
        
    public func listContainsMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func listInsertBeforeMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func listInsertAfterMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func arrayInsertMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func arrayRemoveMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func arrayAppendMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func arrayAppendArrayMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func arrayContainsMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
//            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[0].value.place)
//            try! arguments[1].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[1].value.place)
//            try! arguments[3].value.emitValueCode(into: buffer, using: generator)
//            buffer.add(.PUSH,arguments[2].value.place)
//            buffer.add(.TDIFF,arguments[0].value.place,arguments[1].value.place,.register(.RR))
//            buffer.add(.POPN,.integer(Argon.Integer(3)))
            }
        return(self)
        }
        
    public func rawValueMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.RAW,arguments[0].value.place,.register(.RR))
            }
        return(self)
        }
        
    public func makeEnumerationMethod(argonModule: ArgonModule) -> StandardMethodInstance
        {
        self.closure =
            {
            (arguments,generator,buffer) -> Void in
            try! arguments[0].value.emitValueCode(into: buffer, using: generator)
            buffer.add(.MKENUM,arguments[0].value.place,.register(.RR))
            }
        return(self)
        }
    }
