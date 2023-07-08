//
//  Enumeration.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/10/21.
//

import AppKit

//public class Enumeration:Symbol
//    {
//    public static let kEnumerationCaseMask: Word = 0b11111111_11111111
//    public static let kEnumerationCaseShift: Word = 44
//    public static let kEnumerationPointerMask: Word = 0b00001111_11111111_11111111_11111111_11111111_11111111
//    
//    public override var argonHash: Int
//        {
//        var hashValue = super.argonHash
//        for slot in self.cases
//            {
//            hashValue = hashValue << 13 ^ slot.argonHash
//            }
//        for type in self.genericTypes
//            {
//            hashValue = hashValue << 13 ^ type.argonHash
//            }
//        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
//        return(Int(bitPattern: word))
//        }
//        
//    public var metaclass: Class
//        {
//        if self._metaclass.isNil
//            {
//            self._metaclass = EnumerationMetaclass(label: "\(self.label)Class",enumeration: self)
//            }
//        return(self._metaclass!)
//        }
//        
//    public var isSystemEnumeration: Bool
//        {
//        false
//        }
//        
//    public override var isLiteral: Bool
//        {
//        return(true)
//        }
//        
//    public override var sizeInBytes: Int
//        {
//        let type = ArgonModule.shared.enumeration
//        return(type.instanceSizeInBytes)
//        }
//        
//    public override var asLiteralExpression: LiteralExpression?
//        {
//        LiteralExpression(Literal.enumeration(self))
//        }
//        
//    public override var isType: Bool
//        {
//        return(true)
//        }
//        
//    public var instanceSizeInBytes: Int
//        {
//        var size = Argon.kWordSizeInBytesInt
//        self.cases.forEach{size = max(size,$0.instanceSizeInBytes)}
//        return(size)
//        }
//        
//    public override var canBecomeAType: Bool
//        {
//        return(true)
//        }
//
//    private var _metaclass: Metaclass!
//    private var cases: EnumerationCases = []
//    public var rawType: Type?
//    public var genericTypes: Types = []
//    
//    public required init(label: Label)
//        {
//        super.init(label: label)
//        self.type = Argon.addType(TypeEnumeration(enumeration: self,generics: []))
//        }
//    
//    public required init?(coder: NSCoder)
//        {
//        self.rawType = coder.decodeObject(forKey: "rawType") as? Type
//        self.cases = coder.decodeObject(forKey: "cases") as! EnumerationCases
//        super.init(coder: coder)
//        self.type = Argon.addType(TypeEnumeration(enumeration: self,generics: []))
//        }
//    
//    public override var isEnumeration: Bool
//        {
//        return(true)
//        }
//        
//    public override var iconName: String
//        {
//        return("IconEnumeration")
//        }
//        
//    public override var children: Array<Symbol>
//        {
//        return(self.cases)
//        }
//        
//    public override var childName: (String,String)
//        {
//        return(("case","cases"))
//        }
//        
//    public override var typeCode:TypeCode
//        {
//        .enumeration
//        }
//        
//    public func addCase(_ enumerationCase: EnumerationCase)
//        {
//        self.cases.append(enumerationCase)
//        enumerationCase.enumeration = self
//        }
//        
//    public override func isElement(ofType: Group.ElementType) -> Bool
//        {
//        return(ofType == .enumeration)
//        }
//        
//   public override func allocateAddresses(using allocator: AddressAllocator) throws
//        {
//        guard !self.wasAddressAllocationDone else
//            {
//            return
//            }
//        self.wasAddressAllocationDone = true
//        allocator.allocateAddress(for: self)
//        for aCase in self.cases
//            {
//            try aCase.allocateAddresses(using: allocator)
//            }
//        for type in self.genericTypes
//            {
//            try type.allocateAddresses(using: allocator)
//            }
//        }
//        
//    public override func layoutInMemory(using allocator: AddressAllocator)
//        {
//        fatalError()
//        }
//        
//    public func layoutInMemory(atAddress: Address,isGenericInstance: Bool,using allocator: AddressAllocator)
//        {
//        guard !self.wasMemoryLayoutDone else
//            {
//            return
//            }
//        self.wasMemoryLayoutDone = true
//        let segment = allocator.segment(for: self.segmentType)
//        let enumType = ArgonModule.shared.enumeration
//        let enumPointer = ClassBasedPointer(address: atAddress,type: enumType)
//        enumPointer.setClass(enumType)
//        enumPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
//        if self.genericTypes.isEmpty
//            {
//            enumPointer.setAddress(0,atSlot: "typeParameters")
//            }
//        else
//            {
//            if let arrayPointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.genericTypes.count))
//                {
//                for type in self.genericTypes
//                    {
//                    type.layoutInMemory(using: allocator)
//                    arrayPointer.append(type.memoryAddress)
//                    }
//                enumPointer.setAddress(arrayPointer.cleanAddress,atSlot: "typeParameters")
//                }
//            }
//        enumPointer.setAddress(self.module!.memoryAddress,atSlot: "container")
//        enumPointer.setInteger(self.typeCode.rawValue,atSlot: "typeCode")
//        enumPointer.setAddress(self.rawType?.memoryAddress,atSlot: "rawType")
//        if let casePointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.cases.count))
//            {
//            for aCase in self.cases
//                {
//                aCase.layoutInMemory(using: allocator)
//                casePointer.append(aCase.memoryAddress)
//                }
//            enumPointer.setArrayPointer(casePointer,atSlot: "cases")
//            }
//        enumPointer.setBoolean(self.isSystemEnumeration,atSlot: "isSystemType")
//        }
//        
//    public func caseAtSymbol(_ symbol: Argon.Symbol) -> EnumerationCase?
//        {
//        for someCase in self.cases
//            {
//            if someCase.symbol == symbol
//                {
//                return(someCase)
//                }
//            }
//        return(nil)
//        }
//        
//    public func caseAtSymbol(_ address: Address) -> EnumerationCase?
//        {
//        for someCase in self.cases
//            {
//            if someCase.symbolMemoryAddress == address
//                {
//                return(someCase)
//                }
//            }
//        return(nil)
//        }
//        
//    public override func substitute(from substitution: TypeContext.Substitution) -> Self
//        {
//        let copy = super.substitute(from: substitution)
//        copy.cases = self.cases.map{substitution.substitute($0) as! EnumerationCase}
//        copy.cases.forEach{$0.enumeration = self}
//        if self.rawType.isNotNil
//            {
//            copy.rawType = substitution.substitute(self.rawType!)
//            }
//        copy.genericTypes = self.genericTypes.map{substitution.substitute($0)!}
//        return(copy)
//        }
//        
//    public override func encode(with coder:NSCoder)
//        {
//        super.encode(with: coder)
//        coder.encode(self.rawType,forKey: "rawType")
//        coder.encode(self.cases,forKey: "cases")
//        }
//        
//    public func caseWithLabel(_ label: Label) -> EnumerationCase?
//        {
//        for aCase in self.cases
//            {
//            if aCase.label == label
//                {
//                return(aCase)
//                }
//            }
//        return(nil)
//        }
//        
//    public func cases(_ cases:String...) -> Enumeration
//        {
//        var someCases = Array<EnumerationCase>()
//        var caseIndex = 0
//        for label in cases
//            {
//            let aCase = EnumerationCase(symbol: Argon.Symbol(label), types: [], enumeration: self)
//            aCase.caseIndex = caseIndex
//            caseIndex += 1
//            someCases.append(aCase)
//            }
//        self.cases = self.cases + someCases
//        return(self)
//        }
//        
//    public func `case`(_ symbol: String,_ types:Types) -> Enumeration
//        {
//        let someCase = EnumerationCase(symbol: Argon.Symbol(symbol), types: types, enumeration: self)
//        self.cases.append(someCase)
//        return(self)
//        }
//    }
