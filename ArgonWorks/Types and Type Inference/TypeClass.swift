//
//  TypeClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation
import FFI

public class TypeClass: TypeConstructor
    {
    public static func ==(lhs: TypeClass,rhs:TypeClass) -> Bool
        {
        return(lhs.index == rhs.index && lhs.generics == rhs.generics)
        }
        
    public var rawPrecedenceList: TypeClasses
        {
        var array = TypeClasses()
        array += [(self.supertype as! TypeClass)]
        array += (self.supertype as! TypeClass).rawPrecedenceList
        return(array)
        }
        
    public var allSupertypes: TypeClasses
        {
        var array = [self]
        array += (self.supertype as! TypeClass).allSupertypes
        return(array)
        }
        
    public func allSupertypes(inClass aClass: TypeClass) -> Array<(Int,TypeClass)>
        {
        var array = [(0,self)]
        array += (self.supertype as! TypeClass).allSupertypes(inClass: self)
        return(array)
        }
        
    public var precedenceList: TypeClasses
        {
        var array = [(0,self)]
        array += (self.supertype as! TypeClass).allSupertypes(inClass: self)
        var list = Array<(Int,TypeClass)>()
        for element in array
            {
            var found = false
            for item in list
                {
                if item.1 == element.1
                    {
                    found = true
                    break
                    }
                }
            if !found
                {
                list.append(element)
                }
            }
        let sorted = list.sorted{"\($0.1.depth).\($0.0)" >= "\($1.1.depth).\($1.0)"}
        let classes = sorted.map{$0.1}
        return(classes)
        }
        
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        else
            {
            names = "<none>"
            }
        if self.isSystemClass
            {
            return("TypeClass(SystemClass(\(self.label))\(names))")
            }
        return("TypeClass(\(self.label)\(names))")
        }
        
    public var isRootClass: Bool
        {
        return(false)
        }
        
    public var isValueClass: Bool
        {
        return(false)
        }
        
    public override var arrayElementType: Type
        {
        self.generics[0]
        }
        
    public override var sizeInBytes: Int
        {
        ArgonModule.shared.class.instanceSizeInBytes
        }
        
    public override var instanceSizeInBytes: Int
        {
        self.layoutSlots.count * Argon.kWordSizeInBytesInt
        }

    public var depth: Int
        {
        return(1 + (self.supertype as! TypeClass).depth)
        }
        
    public override var isSystemType: Bool
        {
        self._isSystemType
        }
        
    public var allSubclasses: Types
        {
        self.subtypes
        }
        
    public override  var isClass: Bool
        {
        true
        }
        
    public override var isVoidType: Bool
        {
        self.label == "Void"
        }
        
    public override var ffiType: ffi_type
        {
        fatalError()
        }
        
    public override var subtypes: Types
        {
        get
            {
            self._subtypes
            }
        set
            {
            self._subtypes = newValue
            }
        }
        
    public override var isGeneric: Bool
        {
        self.generics.count > 0
        }
        
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        for type in self.generics
            {
            hashValue = hashValue << 13 ^ type.argonHash
            }
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
    ///
    ///
    /// Types own their classes since types are added to the symbol table
    /// not classes, therefore it is legitimate to set the parent of a
    /// class to be a type.
    ///
    ///
    public var _isSystemType: Bool
    private var _subtypes = Types()
    public private(set) var magicNumber: Int = 0
    public private(set) var supertype: Type?
    private var localSlots = Slots()
    public private(set) var localSystemSlots = Slots()
    internal var objectType: Argon.ObjectType = .custom
    public private(set) var layoutSlots = Slots()
    private var hasBytes: Bool = false
    
    required init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        self.magicNumber = label.polynomialRollingHash
        self._isSystemType = false
        super.init(label: label,generics: [])
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE CLASS")
        self._isSystemType = coder.decodeBool(forKey: "isSystemType")
        self._subtypes = coder.decodeObject(forKey: "subtypes") as! Types
        self.magicNumber = coder.decodeInteger(forKey: "magicNumber")
        self.supertype = coder.decodeObject(forKey: "supertype") as? Type
        self.localSlots = coder.decodeObject(forKey: "localSlots") as! Slots
//        self.localAndInheritedSlots = coder.decodeObject(forKey: "localAndInheritedSlots") as! Slots
        self.layoutSlots = coder.decodeObject(forKey: "layoutSlots") as! Slots
        self.hasBytes = coder.decodeBool(forKey: "hasBytes")
        super.init(coder: coder)
        print("END DECODE TYPE CLASS")
        }
    
    required init(label: Label)
        {
        self._isSystemType = false
        super.init(label: label)
        }
    
    public override func of(_ type: Type) -> Type
        {
        TypeClassInstance(archetype: self,generics: [type])
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self._isSystemType,forKey: "isSystemType")
        coder.encode(self.hasBytes,forKey: "hasBytes")
        coder.encode(self._subtypes,forKey: "subtypes")
        coder.encode(self.magicNumber,forKey: "magicNumber")
        coder.encode(self.supertype,forKey: "supertype")
        coder.encode(self.localSlots,forKey: "localSlots")
//        coder.encode(self.localAndInheritedSlots,forKey: "localAndInheritedSlots")
        coder.encode(self.layoutSlots,forKey: "layoutSlots")
        super.encode(with: coder)
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        let newClass = Self(label: self.label,isSystem: self.isSystemType,generics: self.generics + types)
        newClass.setIndex(self.index)
        newClass.hasBytes = self.hasBytes
        newClass._subtypes = self._subtypes
        newClass.magicNumber = self.magicNumber
        newClass.supertype = self.supertype
        newClass.localSlots = self.localSlots
        newClass.layoutSlots = self.layoutSlots
        return(Argon.addType(newClass))
        }
        
    public func setSupertype(_ type: Type)
        {
        self.supertype = type
        type.addSubtype(self)
        }
        
    public override func addSubtype(_ type: Type)
        {
        guard !self.subtypes.contains(type) else
            {
            return
            }
        self.subtypes.append(type)
        }
        
    public override func setType(_ objectType:Argon.ObjectType) -> Type
        {
        self.objectType = objectType
        return(self)
        }
        
    public func isSubclass(of superclass: TypeClass) -> Bool
        {
        if self.fullName == superclass.fullName
            {
            return(true)
            }
        if self.supertype.isNil
            {
            return(false)
            }
        return((self.supertype as! TypeClass).isSubclass(of: superclass))
        }
        
    public override func isSubtype(of type: Type) -> Bool
        {
        type is TypeClass && (self.isSubclass(of: (type as! TypeClass)))
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for slot in self.layoutSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.container.lookup(label: label))
        }
        
    public override func addLayoutSlot(_ slot: Slot)
        {
        for oldSlot in self.layoutSlots
            {
            if oldSlot.label == slot.label
                {
                fatalError("Duplicate slot")
                }
            }
        self.layoutSlots.append(slot)
        }
        
    public func layoutInMemory(atAddress: Address,isGenericInstance: Bool,generics: Types,using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let classType = allocator.argonModule.lookup(label: "Class") as! Type
        let classPointer = ClassBasedPointer(address: atAddress.cleanAddress,type: classType)
        classPointer.setClass(classType)
        classPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
        self.supertype?.layoutInMemory(using: allocator)
        classPointer.setAddress(self.supertype?.memoryAddress ?? 0,atSlot: "superclass")
        for subtype in self.subtypes
            {
            subtype.layoutInMemory(using: allocator)
            }
        let subs = self.subtypes.map{$0.memoryAddress}
        let subSize = max(100,subs.count * 4)
        let subAddress = segment.allocateArray(size: subSize,elements: subs)
        classPointer.setAddress(subAddress,atSlot: "subclasses")
        for slot in self.layoutSlots
            {
            slot.memoryAddress = segment.allocateObject(ofType: (allocator.argonModule.lookup(label: "Slot") as! Type),extraSizeInBytes: 0)
            slot.layoutInMemory(using: allocator)
            }
        let slotsArray = segment.allocateArray(size: self.layoutSlots.count,elements: self.layoutSlots.map{$0.memoryAddress})
        classPointer.setAddress(slotsArray,atSlot: "slots")
        classPointer.setAddress(self.module!.memoryAddress,atSlot: "container")
        classPointer.setBoolean(self.isSystemClass,atSlot: "isSystemType")
        classPointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
        classPointer.setBoolean(self.isValueClass,atSlot: "isValue")
        classPointer.setInteger(self.magicNumber,atSlot: "magicNumber")
        classPointer.setInteger(self.argonHash,atSlot: "hash")
        classPointer.setBoolean(isGenericInstance,atSlot: "isGenericInstance")
        classPointer.setBoolean(!isGenericInstance,atSlot: "isArchetype")
        if generics.isEmpty
            {
            classPointer.setAddress(0,atSlot: "typeParameters")
            }
        else
            {
            if let typesArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: generics.count))
                {
                for type in generics
                    {
                    type.layoutInMemory(using: allocator)
                    typesArray.append(type.memoryAddress)
                    }
                classPointer.setArrayPointer(typesArray,atSlot: "typeParameters")
                }
            }
        if self.label == "Object"
            {
            print("OBJECT CLASS ADDRESS IS \(String(format: "%12X",self.memoryAddress)) \(self.memoryAddress.bitString)")
            MemoryPointer.dumpMemory(atAddress: atAddress,count: 100)
            }
        }
        
    internal func layoutBaseSlots(inClass: TypeClass,slotPrefix: String,offset: inout Int)
        {
        var systemSlots = Slots()
        let name1 = slotPrefix.isEmpty ? "header" : "Header"
        var slot:Slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        inClass.addLayoutSlot(slot)
        systemSlots.append(slot)
        offset += Argon.kWordSizeInBytesInt
        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name3 = slotPrefix.isEmpty ? "class" : "Class"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
        }

    public override func layoutObjectSlots()
        {
        guard !self.wasSlotLayoutDone else
            {
            return
            }
        self.wasSlotLayoutDone = true
        var offset = 0
        self.layoutBaseSlots(inClass: self,slotPrefix: "",offset: &offset)
        var visitedClasses = Set<TypeClass>()
        visitedClasses.insert(self)
        (self.supertype as? TypeClass)?.layoutObjectSlots(inClass: self,offset: &offset,visitedClasses: &visitedClasses)
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                self.addLayoutSlot(clonedSlot)
                offset += clonedSlot.size
                }
            }
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        print("LAID OUT OBJECT SLOTS FOR \(self.label)")
        for slot in self.layoutSlots
            {
            print("\t\(slot.label)")
            }
        }
        
    public func layoutObjectSlots(inClass: TypeClass,offset: inout Int,visitedClasses: inout Set<TypeClass>)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.insert(self)
        self.layoutBaseSlots(inClass: inClass,slotPrefix: self.label,offset: &offset)
        (self.supertype as? TypeClass)?.layoutObjectSlots(inClass: inClass,offset: &offset,visitedClasses: &visitedClasses)
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                inClass.addLayoutSlot(clonedSlot)
                offset += clonedSlot.size
                }
            }
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
//        print("ABOUT TO ALLOCATE ADDRESS FOR CLASS \(self.label), SIZE IN BYTES IS \(self.sizeInBytes)")
//        allocator.allocateAddress(for: self)
//        print("AFTER ALLOCATE ADDRESS FOR CLASS, ADDRESS IS \(self.memoryAddress)")
//        let header = Header(atAddress: self.memoryAddress)
//        print("HEADER SIZE IN WORDS IS \(header.sizeInWords) SHOULD BE \(self.sizeInBytes / 8)")
        try self.supertype?.allocateAddresses(using: allocator)
        for type in self.subtypes
            {
            try type.allocateAddresses(using: allocator)
            }
        for slot in self.layoutSlots
            {
            try slot.allocateAddresses(using: allocator)
            }
        }
        
    public override func hasBytes(_ bool:Bool) -> Type
        {
        self.hasBytes = true
        return(self)
        }
        
    public override func superclass(_ type:Type) -> Type
        {
        self.setSupertype(type)
        return(self)
        }
        
    public override func slot(_ label: Label,_ type: Type) -> Type
        {
        let slot = InstanceSlot(labeled:label,ofType: type)
        self.localSlots.append(slot)
        return(self)
        }
        
    public override func printLayout()
        {
        print("-------------------------")
        print("CLASS \(self.fullName.description)")
        print("")
        print("SizeInBytes: \(self.sizeInBytes)")
        print("")
        let names = self.layoutSlots.sorted(by: {$0.offset < $1.offset}).map{"\($0.label)"}
        let mappedNames = names.map{"\"\($0)\""}.joined(separator: ",")
        print("[\(mappedNames)]")
        print()
        print("typedef struct _\(self.label)")
        print("\t{")
        for name in names
            {
            print("\tCWord \(name);")
            }
        print("\t}")
        print("\t\(self.label);")
        print()
        print("typedef \(self.label)* \(self.label)Pointer;")
        var index = 0
        for slot in self.layoutSlots.sorted(by: {$0.offset < $1.offset})
            {
            let indexString = String(format:"%04d",index)
            let offsetString = String(format:"%06d",slot.offset)
            print("\(indexString) \(offsetString) \(slot.label)")
            index += 1
            }
        }
    }

public class TypeRootClass: TypeClass
    {
    public override var isRootClass: Bool
        {
        return(true)
        }
        
    public init()
        {
        super.init(label: "Object",isSystem: true,generics: [])
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
    required init(label: Label) {
        fatalError("init(label:) has not been implemented")
    }
    
    required init(label: Label, isSystem: Bool = false, generics: Types = []) {
        fatalError("init(label:isSystem:generics:) has not been implemented")
    }
}

public class TypeValueClass: TypeClass
    {
    public override var isValueClass: Bool
        {
        return(true)
        }
    }

public class TypePrimitiveClass: TypeClass
    {
    }

public class TypeArrayClass: TypeClass
    {
    }

public typealias TypeClasses = Array<TypeClass>

public class TypeClassClass: TypeClass
    {
    }
