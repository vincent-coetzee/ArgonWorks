//
//  MethodInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

   public enum SpecificOrdering
        {
        case more
        case unordered
        case less
        }
        
public struct TagSignature: Equatable
    {
    internal let tags: Array<Label?>
    
    init(tags:  Array<Label?>)
        {
        self.tags = tags
        }
        
    init(arguments: Arguments)
        {
        self.tags = arguments.map{$0.tag}
        }
        
    internal func withArguments(_ arguments: Arguments) -> TagSignature
        {
        var newTags = Array<Label>()
        var index = 0
        for argument in arguments
            {
            if argument.tag.isNil
                {
                newTags.append(self.tags[index]!)
                }
            else
                {
                newTags.append(argument.tag!)
                }
            index += 1
            }
        return(TagSignature(tags: newTags))
        }
    }
    
public class MethodInstance: Function
    {
    public override var childOutlineItemCount: Int
        {
        self.parameters.count + 2
        }

    public override var hasChildOutlineItems: Bool
        {
        true
        }
        
    public override var isOutlineItemExpandable: Bool
        {
        self.childOutlineItemCount > 0
        }

    public override func childOutlineItem(atIndex: Int) -> OutlineItem
        {
        if atIndex == self.parameters.count
            {
            return(self.type)
            }
        else if atIndex == self.parameters.count + 1
            {
            return(self.returnType)
            }
        return(self.parameters[atIndex])
        }
        
    public override var outlineItemFields: Dictionary<String, FieldBox>
        {
        var fields = Dictionary<String,FieldBox>()
        fields["class"] = FieldBox(label: "class",root: self,keyPath: \Symbol.classLabel)
        fields["index"] = FieldBox(label: "index",root: self,keyPath: \Symbol.index)
        fields["memoryAddress"] = FieldBox(label: "memoryAddress",root: self,keyPath: \Symbol.memoryAddressField)
        fields["container"] = FieldBox(label: "container",root: self,keyPath: \Symbol.container)
        fields["typeName"] = FieldBox(label: "typeName",root: self,keyPath: \Symbol.typeNameField)
        return(fields)
        }
        
    public var methodSelectorString: String
        {
        var string = self.label
        for parameter in self.parameters
            {
            string += parameter.isVisible ? parameter.label + "::" : "::"
            }
        return(string)
        }
        
    public override var asContainer: Container
        {
        .methodInstance(self)
        }
        
    public override var enclosingMethodInstance: MethodInstance
        {
        self
        }
        
    public var isPotentialSlotWriter: Bool
        {
        if self.parameters.count != 2
            {
            return(false)
            }
        if !self.parameters[0].type.isClass
            {
            return(false)
            }
        let targetClass = self.parameters[0].type as! TypeClass
        if targetClass.isSystemClass
            {
            return(false)
            }
        if !self.parameters[1].type.isClass
            {
            return(false)
            }
        let valueClass = self.parameters[1].type as! TypeClass
        if !targetClass.layoutSlots.map({$0.label}).contains(self.label)
            {
            return(false)
            }
        let slotClass = targetClass.layoutSlot(atLabel: self.label)
        if slotClass.type != valueClass
            {
            return(false)
            }
        return(true)
        }
        
    public var isPotentialSlotReader: Bool
        {
        if self.parameters.count != 1
            {
            return(false)
            }
        if !self.parameters[0].type.isClass
            {
            return(false)
            }
        let targetClass = self.parameters[0].type as! TypeClass
        if targetClass.isSystemClass
            {
            return(false)
            }
        if self.returnType.isVoidType
            {
            return(false)
            }
        if !targetClass.layoutSlots.map({$0.label}).contains(self.label)
            {
            return(false)
            }
        let slotClass = targetClass.layoutSlot(atLabel: self.label)
        if slotClass.type != self.returnType
            {
            return(false)
            }
        return(true)
        }
        
    public var isInlineMethodInstance: Bool
        {
        false
        }
        
    public override var description: String
        {
        self.displayString
        }
        
    public var instructionsSizeInBytes: Int
        {
        self.codeBuffer.count * Instruction.sizeInWords * Argon.kWordSizeInBytesInt
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .code
        }
        
    public override var sizeInBytes: Int
        {
        return(ArgonModule.shared.methodInstance.instanceSizeInBytes)
        }
        
    public override var argonHash: Int
        {
        var hashValue = super.argonHash
        for slot in self.parameters
            {
            hashValue = hashValue << 13 ^ slot.argonHash
            }
        hashValue = hashValue << 13 ^ self.returnType.argonHash
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public var isBlockContextScope: Bool
        {
        false
        }
        
    public override var declaration: Location?
        {
        self.locations.declaration
        }
        
    public var isSlotScope: Bool
        {
        false
        }
        
    public var typeSignature:TypeSignature
        {
        TypeSignature(label: self.label,types: self.parameters.map{$0.type},returnType: self.returnType)
        }
        
    public var mangledName: String
        {
        let start = self.label
        let next = self.parameters.map{$0.type.mangledName}.joined(separator: "_")
        let end = "=" + self.returnType.mangledName
        return(start + "." + next + end)
        }
        
    ///
    ///
    /// A method instance is concrete if all the parameters and the return type
    /// have types that contain a concrete type, i.e. there are no type variables
    /// in place of types anywhere.
    ///
    ///
    public var isConcreteInstance: Bool
        {
        if self.returnType.isTypeVariable
            {
            return(false)
            }
        for parameter in self.parameters
            {
            if parameter.type.isTypeVariable
                {
                return(false)
                }
            }
        return(true)
        }
        
    public override var iconName: String
        {
        "IconMethodInstance"
        }
        
    public var isSystemMethodInstance: Bool
        {
        return(false)
        }
        
    public var tagSignature: TagSignature
        {
        TagSignature(tags: self.parameters.map{$0.tag})
        }
        
    public override var displayString: String
        {
        let parmString = "(" + self.parameters.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.label)\(parmString) -> \(self.returnType.displayString)")
        }
        
    public var hasVariableTypes: Bool
        {
        for parameter in self.parameters
            {
            if parameter.type.hasVariableTypes
                {
                return(true)
                }
            }
        return(self.returnType.hasVariableTypes)
        }

    public var isPrimitiveMethodInstance = false
    public var isAutoGenerated = false
    public var isGenericMethod = false
    public var isMainMethod: Bool = false
    public var conditionalTypes: Types = []
    internal var originalMethodInstance: MethodInstance?
    public var codeBuffer: InstructionBuffer
    public var instructionAddressHolder = FutureHolder<Instruction,Instruction.Operand>()
    
    public required init?(coder: NSCoder)
        {
        self.isGenericMethod = coder.decodeBool(forKey: "isGeneric")
        self.conditionalTypes = coder.decodeObject(forKey: "conditionalTypes") as! Types
        self.originalMethodInstance = coder.decodeObject(forKey: "originalMethodInstance") as? MethodInstance
        self.isMainMethod = coder.decodeBool(forKey: "isMainMethod")
        self.codeBuffer = coder.decodeObject(forKey: "codeBuffer") as! InstructionBuffer
//        self.codeBuffer = T3ABuffer()
        super.init(coder: coder)
        }
    
    public required init(label: Label)
        {
        self.codeBuffer = InstructionBuffer()
        super.init(label: label)
        }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.isGenericMethod,forKey: "isGeneric")
        coder.encode(self.conditionalTypes,forKey: "conditionalTypes")
        coder.encode(self.originalMethodInstance,forKey: "orginalMethodInstance")
        coder.encode(self.isMainMethod,forKey: "isMainMethod")
        coder.encode(self.codeBuffer,forKey: "codeBuffer")
        super.encode(with: coder)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? MethodInstance
            {
            return(self.label == second.label && self.module == second.module && self.parameters == second.parameters && self.returnType == second.returnType)
            }
        return(super.isEqual(object))
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = Self(label: self.label)
        instance.setIndex(self.index.keyByIncrementingMinor())
        instance.ancestors.append(self)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        instance.isMainMethod = self.isMainMethod
        instance.setMemoryAddress(self.memoryAddress)
        return(self)
        }
        
    public var methodSignature: MethodSignature
        {
        let signature = MethodSignature(label: self.label,methodInstance: self)
        signature.parameters = self.parameters
        signature.returnType = self.returnType
        return(signature)
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        allocator.allocateAddress(forMethodInstance: self)
        self.wasAddressAllocationDone = true
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newParameters = self.parameters.map{$0.freshTypeVariable(inContext: context)}
        let newReturnType = self.returnType.freshTypeVariable(inContext: context)
        let newInstance = Self(label: self.label)
        newInstance.setIndex(self.index.keyByIncrementingMinor())
        newInstance.ancestors.append(self)
        newInstance.container = self.container
        newInstance.setIndex(self.index)
        newInstance.parameters = newParameters
        newInstance.returnType = newReturnType
        newInstance.setMemoryAddress(self.memoryAddress)
        newInstance.isMainMethod = self.isMainMethod
        return(newInstance)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        }
        
    public override func install(inContext context: ExecutionContext)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        if self.label == "doSomeSeriousShit"
            {
            print("halt")
            print("soSomeSeriousShit: \(self.memoryAddress)")
            }
        let segment = context.segment(for: self)
        let methodInstanceType = ArgonModule.shared.lookup(label: "MethodInstance") as! Type
        let instancePointer = ClassBasedPointer(address: self.memoryAddress.cleanAddress,type: methodInstanceType)
        instancePointer.setClass(methodInstanceType)
        instancePointer.flipCount = 0
        instancePointer.hasBytes = false
        instancePointer.objectType = .methodInstance
        instancePointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
        if let module = self.module
            {
            instancePointer.setAddress(module.memoryAddress,atSlot: "module")
            }
        else
            {
            fatalError("Parent of method instance should be a module but is not.")
            }
        let parameterType = ArgonModule.shared.parameter
        if let parmArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.parameters.count,elements: Array<Address>()))
            {
            for parm in self.parameters
                {
                let parmPointer = ClassBasedPointer(address: segment.allocateObject(ofType: parameterType, extraSizeInBytes: 0),type: parameterType)
                parmPointer.setStringAddress(segment.allocateString(parm.label),atSlot: "tag")
                parmPointer.setBoolean(parm.isVisible,atSlot: "tagIsShown")
                parmPointer.setBoolean(parm.isVariadic,atSlot: "isVariadic")
                parm.type.install(inContext: context)
                parmPointer.setAddress(parm.type.memoryAddress,atSlot: "type")
                parmPointer.setStringAddress(parm.relabel.isNil ? 0 : segment.allocateString(parm.relabel!),atSlot: "retag")
                parmArray.append(parmPointer.address)
                }
            instancePointer.setArrayPointer(parmArray,atSlot: "parameters")
            }
        let blockAddress = context.codeSegment.allocateInstructionBlock(for: self)
        instancePointer.setAddress(blockAddress,atSlot: "instructionBlock")
        let instructionsAddress = blockAddress + Word(ArgonModule.shared.instructionBlock.instanceSizeInBytes)
        instancePointer.setAddress(instructionsAddress,atSlot: "instructionAddress")
        instancePointer.setInteger(self.codeBuffer.count,atSlot: "instructionCount")
        var wordPointer = WordPointer(bitPattern: instructionsAddress)
        self.instructionAddressHolder.setValue(.address(instructionsAddress))
        print("INDTRUCTIONS ADDRESS: \(String(format: "%llX",instructionsAddress))")
        self.codeBuffer.display(indent: "")
        self.codeBuffer.flattenLabels(atAddress: instructionsAddress)
        if self.label == "mainMethod"
            {
            let aString = String(format: "%llX",instructionsAddress)
            print("INSTRUCTIONS ADDRESS: \(aString)")
            }
        for instruction in self.codeBuffer.instructions
            {
            instruction.install(intoPointer:wordPointer,context: context)
            wordPointer += instruction.sizeInWords
            }
        }
        
    public func parametersMatchArguments(_ arguments: Arguments,for expression: Expression,at: Location) -> Bool
        {
        var failed = false
        for (parameter,argument) in zip(self.parameters,arguments)
            {
            if parameter.tag != argument.tag
                {
                failed = true
                if parameter.tag != nil
                    {
                    expression.appendIssue(at: at, message: "Expected argument tag '\(parameter.tag!)' but found '\(argument.tag ?? "")'")
                    }
                }
            }
        return(!failed)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        self.codeBuffer = InstructionBuffer()
        try self.emitCode(into: self.codeBuffer,using: generator)
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.parameters.forEach{$0.initializeType(inContext: context)}
        self.returnType.initializeType(inContext: context)
        self.type = TypeFunction(label: self.label, types: self.parameters.map{$0.type}, returnType: self.returnType)
        }
        
    public func moreSpecific(than instance:MethodInstance,forTypes types: Types) -> Bool
        {
        var orderings = Array<SpecificOrdering>()
        for index in 0..<types.count
            {
            let argumentType = types[index]
            let thisType = self.parameters[index].type!
            let thatType = instance.parameters[index].type!
            if thisType.isSubtype(of: thatType)
                {
                orderings.append(.more)
                }
            else if thisType.isClass && thatType.isClass && argumentType.isClass
                {
                let argumentClassList = (argumentType as! TypeClass).precedenceList
                if let thisTypeIndex = argumentClassList.firstIndex(of: thisType as! TypeClass),let thatTypeIndex = argumentClassList.firstIndex(of: thatType as! TypeClass)
                    {
                    orderings.append(thisTypeIndex > thatTypeIndex ? .more : .less)
                    }
                else
                    {
                    orderings.append(.unordered)
                    }
                }
            else
                {
                orderings.append(.unordered)
                }
            }
        for ordering in orderings
            {
            if ordering == .more
                {
                return(true)
                }
            }
        return(false)
        }

    public func parametersAreCongruent(withArguments arguments: TaggedTypes) -> Bool
        {
        guard self.parameters.count == arguments.count else
            {
            return(false)
            }
        for (parameter,argument) in zip(self.parameters,arguments)
            {
            if argument.tag.isNil && parameter.isVisible
                {
                return(false)
                }
            if argument.tag.isNotNil && argument.tag! != parameter.label
                {
                return(false)
                }
            if argument.type!.isClass && parameter.type.isClass && !argument.type!.isSubtype(of: parameter.type)
                {
                return(false)
                }
            if argument.type!.isEnumeration && parameter.type.isEnumeration && argument.type! != parameter.type
                {
                return(false)
                }
            }
        return(true)
        }
        
    public func parameterTypesAreSupertypes(ofTypes types: Types) -> Bool
        {
        for (inType,myType) in zip(types,self.parameters.map{$0.type!})
            {
            if inType.isTypeVariable || myType.isTypeVariable
                {
                return(false)
                }
            if !inType.isSubtype(of: myType)
                {
                return(false)
                }
            }
        return(true)
        }
    }

public typealias MethodInstances = Array<MethodInstance>

public protocol NSCodable
    {
    init(coder: NSCoder,forKey: String)
    func encode(with coder: NSCoder,forKey: String)
    }
    
extension NSCoder
    {
    func encode<T:NSCodable>(_ array:Array<T>,forKey: String)
        {
        self.encode(array.count,forKey: forKey + "count")
        var index = 0
        for element in array
            {
            element.encode(with: self,forKey: forKey + "\(index)")
            index += 1
            }
        }
        
    func decode<T>(_ type:Array<T>.Type,forKey: String) -> Array<T> where T:NSCodable
        {
        let theCount = self.decodeInteger(forKey: forKey + "count")
        var elements = Array<T>()
        for index in 0..<theCount
            {
            let element = T(coder: self,forKey: forKey + "\(index)")
            elements.append(element)
            }
        return(elements)
        }
    }
