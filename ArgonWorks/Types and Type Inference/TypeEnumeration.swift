//
//  TypeEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeEnumeration: TypeConstructor
    {
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
        var size = Argon.kWordSizeInBytesInt
        self.cases.forEach{size = max(size,$0.instanceSizeInBytes)}
        return(size)
        }
    
    public override var isEnumeration: Bool
        {
        true
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
        
    public var _isSystemType: Bool
    private var cases: EnumerationCases = []
    public var rawType: Type?
    
    init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        self._isSystemType = isSystem
        super.init(label: label,generics: [])
        }
        
    required init(label: Label)
        {
        self._isSystemType = false
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self._isSystemType = coder.decodeBool(forKey: "isSystemType")
        self.cases = coder.decodeObject(forKey: "cases") as! EnumerationCases
        self.rawType = coder.decodeObject(forKey: "rawType") as? Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self._isSystemType,forKey: "isSystemType")
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
        
    public func addCase(_ aCase: EnumerationCase)
        {
        self.cases.append(aCase)
        aCase.enumeration = self
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        let newClass = TypeEnumeration(label: self.label,isSystem: self.isSystemType,generics: self.generics + types)
        newClass.cases = self.cases
        newClass.rawType = self.rawType
        return(newClass)
        }
        
    public override func layoutObjectSlots()
        {
        }
        
   public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        for aCase in self.cases
            {
            try aCase.allocateAddresses(using: allocator)
            }
        for type in self.generics
            {
            try type.allocateAddresses(using: allocator)
            }
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
//        print("ENUMERATION NEEDS TO BE LAID OUT IN MEMORY")
//        }
//
//    public func layoutInMemory(atAddress: Address,isGenericInstance: Bool,using allocator: AddressAllocator)
//        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let enumType = ArgonModule.shared.enumeration
        let enumPointer = ClassBasedPointer(address: self.memoryAddress,type: enumType)
        enumPointer.setClass(enumType)
        enumPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
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
        enumPointer.setAddress(self.module!.memoryAddress,atSlot: "container")
        enumPointer.setInteger(self.typeCode.rawValue,atSlot: "typeCode")
        enumPointer.setAddress(self.rawType?.memoryAddress,atSlot: "rawType")
        if let casePointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.cases.count))
            {
            for aCase in self.cases
                {
                aCase.layoutInMemory(using: allocator)
                casePointer.append(aCase.memoryAddress)
                }
            enumPointer.setArrayPointer(casePointer,atSlot: "cases")
            }
        enumPointer.setBoolean(self.isSystemType,atSlot: "isSystemType")
        }
        
    public func cases(_ cases:String...) -> TypeEnumeration
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
