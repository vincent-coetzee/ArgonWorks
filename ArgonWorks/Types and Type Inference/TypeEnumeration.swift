//
//  TypeEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeEnumeration: TypeConstructor
    {
    public static func ==(lhs:TypeEnumeration,rhs:TypeEnumeration) -> Bool
        {
        lhs.fullName == rhs.fullName && lhs.generics == rhs.generics
        }
        
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        return("TypeEnumeration(\(self.label)\(names))")
        }
        
    public override var instanceSizeInBytes: Int
        {
        if self.hasAssociatedValues
            {
            var count = self.cases.first!.associatedTypes.count
            for aCase in self.cases
                {
                count = max(count,aCase.associatedTypes.count)
                }
            return((1 + count) * Argon.kWordSizeInBytesInt)
            }
        return(Argon.kWordSizeInBytesInt)
        }
    
    public override var isEnumeration: Bool
        {
        true
        }
        
    public override var typeCode:TypeCode
        {
        .enumeration
        }
        
    public override var magicNumber: Int
        {
        var genericsHash = 0
        self.generics.forEach{ genericsHash = genericsHash << 13 | $0.magicNumber }
        return(self.label.polynomialRollingHash << 13 | genericsHash)
        }
        
    public override var userString: String
        {
        self.fullName.displayString
        }
        
    public var hasAssociatedValues: Bool
        {
        self.cases.detect{$0.hasAssociatedValues}
        }
        
    public override var isGeneric: Bool
        {
        self.generics.count > 0
        }
        
    public override var sizeInBytes: Int
        {
        120
        }
        
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        for aCase in self.cases
            {
            hashValue <<= 13
            hashValue ^= aCase.argonHash
            }
        for type in self.generics
            {
            hashValue = hashValue << 13 ^ type.argonHash
            }
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
//    public override var type: Type?
//        {
//        get
//            {
//            let anEnum = TypeEnumeration(enumeration: self.enumeration,generics: self.generics.map{$0.type!})
//            anEnum.setParent(self.parent)
//            return(anEnum)
//            }
//        set
//            {
//            }
//        }
        
    public var cases: EnumerationCases = []
    public var rawType: Type?
    
    init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        super.init(label: label,generics: [])
        }
        
    required init(label: Label)
        {
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self.cases = coder.decodeObject(forKey: "cases") as! EnumerationCases
        self.rawType = coder.decodeObject(forKey: "rawType") as? Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.cases,forKey: "cases")
        coder.encode(self.rawType,forKey: "rawType")
        super.encode(with: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for aCase in self.cases
            {
            if aCase.label == label
                {
                return(aCase)
                }
            }
        return(self.container.lookup(label: label))
        }
        
    public func caseIndex(forSymbol: Argon.Symbol) -> Int?
        {
        for aCase in self.cases
            {
            if aCase.symbol == forSymbol
                {
                return(aCase.caseIndex)
                }
            }
        return(nil)
        }
        
    public func `case`(forSymbol: Argon.Symbol) -> EnumerationCase?
        {
        for aCase in self.cases
            {
            if aCase.symbol == forSymbol
                {
                return(aCase)
                }
            }
        return(nil)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? TypeEnumeration
            {
            return(self.fullName == second.fullName && self.generics == second.generics)
            }
        return(super.isEqual(object))
        }
        
    public func addCase(_ aCase: EnumerationCase)
        {
        self.cases.append(aCase)
        aCase.caseIndex = self.cases.count
        aCase.enumeration = self
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        let newClass = TypeEnumeration(label: self.label,isSystem: self.isSystemType,generics: types)
        newClass.ancestors.append(self)
        newClass.setModule(self.module)
        newClass.container = self.container
        newClass.setIndex(self.index.keyByIncrementingMinor())
        newClass.cases = self.cases
        newClass.rawType = self.rawType
        return(newClass)
        }
        
    public override func layoutObjectSlots()
        {
        }
        
   public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        for aCase in self.cases
            {
            aCase.allocateAddresses(using: allocator)
            }
        for type in self.generics
            {
            type.allocateAddresses(using: allocator)
            }
        }
        
    public func clone() -> Self
        {
        let new = Self.init(label: self.label)
        new.setIndex(self.index)
        new.rawType = self.rawType
        new.cases = self.cases
        return(new)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let enumType = ArgonModule.shared.enumeration
        let enumPointer = ClassBasedPointer(address: self.memoryAddress,type: enumType)
        enumPointer.objectType = .enumeration
        enumPointer.setClass(enumType)
        enumPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        if self.generics.isEmpty
            {
            enumPointer.setAddress(0,atSlot: "typeParameters")
            }
        else
            {
            if let arrayPointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.generics.count))
                {
                for type in self.generics
                    {
                    type.layoutInMemory(using: allocator)
                    arrayPointer.append(type.memoryAddress)
                    }
                enumPointer.setAddress(arrayPointer.cleanAddress,atSlot: "typeParameters")
                }
            }
        enumPointer.setAddress(self.module!.memoryAddress,atSlot: "module")
        enumPointer.setAddress(self.rawType?.memoryAddress,atSlot: "rawType")
        if let casePointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.cases.count))
            {
            for aCase in self.cases
                {
                aCase.layoutInMemory(using: allocator)
                casePointer.append(aCase.memoryAddress)
                }
            enumPointer.setAddress(casePointer.address,atSlot: "cases")
            }
        enumPointer.setBoolean(self.isSystemType,atSlot: "isSystemType")
//        MemoryPointer.dumpMemory(atAddress: self.memoryAddress,count: 100)
        }
        
    public func createRawValueMethod() -> MethodInstance
        {
        let rawValueInstance = PrimitiveMethodInstance(label: "rawValue")
        rawValueInstance.primitiveIndex = 200
        rawValueInstance.addParameterSlot(Parameter(label: "enumeration",type: self))
        rawValueInstance.returnType = ArgonModule.shared.symbol
        return(rawValueInstance)
        }
        
    public func cases(_ cases:String...) -> TypeEnumeration
        {
        self.cases(cases)
        }
        
    public func cases(_ cases:[String]) -> TypeEnumeration
        {
        var someCases = Array<EnumerationCase>()
        var caseIndex = 0
        for label in cases
            {
            let aCase = EnumerationCase(symbol: Argon.Symbol(label), types: [], enumeration: self)
            aCase.caseIndex = caseIndex
            caseIndex += 1
            someCases.append(aCase)
            }
        self.cases = self.cases + someCases
        return(self)
        }
        
    public func `case`(_ symbol: String,_ types:Types) -> TypeEnumeration
        {
        let someCase = EnumerationCase(symbol: Argon.Symbol(symbol), types: types, enumeration: self)
        self.cases.append(someCase)
        return(self)
        }
    }
