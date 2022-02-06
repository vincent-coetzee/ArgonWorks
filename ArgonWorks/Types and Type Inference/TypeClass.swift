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
//    public static func ==(lhs: TypeClass,rhs:TypeClass) -> Bool
//        {
//        return(lhs.fullName == rhs.fullName && lhs.generics == rhs.generics)
//        }
//

    public static func ==(lhs:TypeClass,rhs:TypeClass) -> Bool
        {
        return(lhs.fullName == rhs.fullName && lhs.generics == rhs.generics)
        }
        
    public var objectType: Argon.ObjectType
        {
        .class
        }
        
    public override var classValue: TypeClass
        {
        self
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
        array += (self.supertype as? TypeClass)?.allSupertypes(inClass: self) ?? []
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
        return("TypeClass(\(self.label)\(names))")
        }
        
    public var isRootClass: Bool
        {
        return(false)
        }
        
    public override var isFloatType: Bool
        {
        self.label == "Float"
        }
        
    public override var isIntegerType: Bool
        {
        self.label == "Integer" || self.label == "UInteger" || self.label == "Byte" || self.label == "Character"
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
        ArgonModule.shared.classType.instanceSizeInBytes
        }
        
    public override var instanceSizeInBytes: Int
        {
        (self.layoutSlots.count) * Argon.kWordSizeInBytesInt
        }

    public override var slotCount: Int
        {
        self.layoutSlots.count
        }
        
    public var depth: Int
        {
        return(1 + ((self.supertype as? TypeClass)?.depth ?? 0))
        }
        
    public var allSubclasses: Types
        {
        self.subtypes
        }
        
    public override  var isClass: Bool
        {
        true
        }
        
    public override  var isSystemClass: Bool
        {
        ArgonModule.shared.systemClassNames.contains(self.label)
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
        
    public override var magicNumber: Int
        {
        var genericsHash = 0
        self.generics.forEach{ genericsHash = genericsHash << 13 | $0.magicNumber }
        return(self.label.polynomialRollingHash << 13 | genericsHash)
        }
        
    public override var layoutSlotCount: Int
        {
        self.layoutSlots.count
        }
        
    public override var isGeneric: Bool
        {
        self.generics.count > 0
        }
        
    public var classType: TypeClass
        {
        ArgonModule.shared.classType as! TypeClass
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
    private var _subtypes = Types()
    public private(set) var supertype: Type?
    private var instanceSlots = Slots()
    public private(set) var localSystemSlots = Slots()
    public private(set) var layoutSlots = Slots()
    public private(set) var hasBytes: Bool = false
    
    required init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        super.init(label: label,generics: generics)
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE CLASS")
        self._subtypes = coder.decodeObject(forKey: "subtypes") as! Types
        self.supertype = coder.decodeObject(forKey: "supertype") as? Type
        self.instanceSlots = coder.decodeObject(forKey: "instanceSlots") as! Slots
        self.layoutSlots = coder.decodeObject(forKey: "layoutSlots") as! Slots
        self.hasBytes = coder.decodeBool(forKey: "hasBytes")
        super.init(coder: coder)
        print("END DECODE TYPE CLASS")
        }
    
    required init(label: Label)
        {
        super.init(label: label)
        }
    
    public override func of(_ type: Type) -> Type
        {
        self.withGenerics([type])
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.hasBytes,forKey: "hasBytes")
        coder.encode(self._subtypes,forKey: "subtypes")
        coder.encode(self.supertype,forKey: "supertype")
        coder.encode(self.instanceSlots,forKey: "instanceSlots")
        coder.encode(self.layoutSlots,forKey: "layoutSlots")
        super.encode(with: coder)
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        let newClass = Self(label: self.label,isSystem: self.isSystemType,generics: types)
        newClass.ancestors.append(self)
        newClass.setModule(self.module)
        newClass.container = self.container
        newClass.setIndex(self.index.keyByIncrementingMinor())
        newClass.flags(self.typeFlags.subtracting(.kArcheTypeFlag))
        newClass.hasBytes = self.hasBytes
        newClass._subtypes = self._subtypes
        newClass.supertype = self.supertype
        newClass.instanceSlots = self.instanceSlots
        newClass.layoutSlots = self.layoutSlots
        return(newClass)
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
        
//    public override func setType(_ objectType:Argon.ObjectType) -> Type
//        {
//        self.objectType = objectType
//        return(self)
//        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? TypeClass
            {
            return(self.index == second.index && self.generics == second.generics)
            }
        return(super.isEqual(object))
        }
        
    public func isSubclass(of superclass: TypeClass) -> Bool
        {
        if self.index == superclass.index
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
        
    public override func addInstanceSlot(_ slot: Slot)
        {
        for oldSlot in self.instanceSlots
            {
            if oldSlot.label == slot.label
                {
                fatalError("Duplicate instance slot \(slot.label)")
                }
            }
        self.instanceSlots.append(slot)
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
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        ///
        /// WE USED TO CHECK TO SEE WHETHER THE SYMBOL WAS A PRIMITIVE OR NOT AND THEN WE
        /// DID NOT LAYOUT THE TYPE IF IT WAS, BUT WE NEED THE PRIMITIVE CLASSES EVEN IF
        /// THE NORMAL METHODS OF ACCESSING A CLASS OF AN OBJECT ARE MAGICKED IN.
        ///
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let classPointer = ClassBasedPointer(address: self.memoryAddress.cleanAddress,type: self.classType)
        classPointer.objectType = self.objectType
        classPointer.setClass(classType)
        classPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
        self.supertype?.layoutInMemory(using: allocator)
        classPointer.setClassAddress(self.supertype?.memoryAddress,atSlot: "superclass")
        for subtype in self.subtypes
            {
            subtype.layoutInMemory(using: allocator)
            }
        let subs = self.subtypes.map{$0.memoryAddress}
        let subSize = max(100,subs.count * 4)
        let subAddress = segment.allocateArray(size: subSize,elements: subs)
        classPointer.setArrayAddress(subAddress,atSlot: "subclasses")
        for slot in self.layoutSlots
            {
            slot.setMemoryAddress(segment.allocateObject(ofType: ArgonModule.shared.slot,extraSizeInBytes: 0))
            slot.layoutInMemory(using: allocator)
            }
        let slotsArray = segment.allocateArray(size: self.layoutSlots.count,elements: self.layoutSlots.map{$0.memoryAddress})
        classPointer.setArrayAddress(slotsArray,atSlot: "slots")
        classPointer.setAddress(self.module?.memoryAddress,atSlot: "module")
        classPointer.setBoolean(self.isSystemClass,atSlot: "isSystemType")
        classPointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
        classPointer.setBoolean(self.isValueClass,atSlot: "isValue")
        classPointer.setInteger(self.magicNumber,atSlot: "magicNumber")
        classPointer.setInteger(self.argonHash,atSlot: "hash")
        classPointer.setBoolean(!self.isArcheType,atSlot: "isGenericInstance")
        classPointer.setBoolean(self.isArcheType,atSlot: "isArchetype")
        if generics.isEmpty
            {
            classPointer.setAddress(nil,atSlot: "typeParameters")
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
//        MemoryPointer.dumpMemory(atAddress: self.memoryAddress, count: 20)
        }
        
    public func initMetatype(inModule: Module)
        {
        guard self.type == nil else
            {
            return
            }
        if self.supertype.isNotNil && self.supertype!.type.isNil
            {
            (self.supertype as! TypeClass).initMetatype(inModule: inModule)
            }
        let typeMetaclass = TypeMetaclass(label: self.label + "Class",isSystem: self.isSystemType,generics: self.generics)
        if self.supertype.isNotNil
            {
            typeMetaclass.setSupertype(self.supertype!.type)
            }
        typeMetaclass.flags([.kSystemTypeFlag,.kMetaclassFlag])
        inModule.addSymbol(typeMetaclass)
        self.type = typeMetaclass
        self.type.type = ArgonModule.shared.metaclassType
        for type in self.subtypes
            {
            (type as! TypeClass).initMetatype(inModule: inModule)
            }
        }
        
    internal func layoutBaseSlots(inClass: TypeClass,slotPrefix: String,offset: inout Int)
        {
        var systemSlots = Slots()
        let name1 = slotPrefix.isEmpty ? "header" : "Header"
        var slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        print("SETTING \(name1) OFFSET TO \(offset)")
        slot.slotType = .kSystemHeaderSlot
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        slot.slotType = .kSystemMagicNumberSlot
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name3 = slotPrefix.isEmpty ? "class" : "Class"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        slot.slotType = .kSystemClassSlot
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
        }

    public func layoutSlot(atLabel: Label) -> Slot
        {
        for slot in self.layoutSlots
            {
            if slot.label == atLabel
                {
                return(slot)
                }
            }
        fatalError("SLOT \(atLabel) NOT FOUND")
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
        (self.supertype as? TypeClass)?.layoutObjectSlots(inClass: self,offset: &offset)
        for slot in self.instanceSlots
            {
            let clonedSlot = slot.cloned
            clonedSlot.setOffset(offset)
            offset += clonedSlot.size
            self.addLayoutSlot(clonedSlot)
            }
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        }
        
    public func layoutObjectSlots(inClass: TypeClass,offset: inout Int)
        {
        self.layoutBaseSlots(inClass: inClass,slotPrefix: self.label,offset: &offset)
        (self.supertype as? TypeClass)?.layoutObjectSlots(inClass: inClass,offset: &offset)
        for slot in self.instanceSlots
            {
            let clonedSlot = slot.cloned
            clonedSlot.setOffset(offset)
            offset += clonedSlot.size
            inClass.addLayoutSlot(clonedSlot)
            }
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
//        print("ABOUT TO ALLOCATE ADDRESS FOR CLASS \(self.label), SIZE IN BYTES IS \(self.sizeInBytes)")
        allocator.allocateAddress(for: self)
//        print("AFTER ALLOCATE ADDRESS FOR CLASS, ADDRESS IS \(self.memoryAddress)")
//        let header = Header(atAddress: self.memoryAddress)
//        print("HEADER SIZE IN WORDS IS \(header.sizeInWords) SHOULD BE \(self.sizeInBytes / 8)")
        self.supertype?.allocateAddresses(using: allocator)
        for type in self.subtypes
            {
            type.allocateAddresses(using: allocator)
            }
        for slot in self.layoutSlots
            {
            slot.allocateAddresses(using: allocator)
            }
        }
        
    @discardableResult
    public override func setHasBytes(_ bool:Bool) -> Type
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
        self.addInstanceSlot(slot)
        return(self)
        }
        
    public func slotReader(forSlot slot: Slot) -> MethodInstance
        {
        let instance = SlotReaderMethodInstance(label: slot.label)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self, isVisible: false, isVariadic: false)]
        instance.returnType = slot.type
        return(instance)
        }
        
    public func slotWriter(forSlot slot: Slot) -> MethodInstance
        {
        let instance = SlotWriterMethodInstance(label: slot.label)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: slot.type, isVisible: false, isVariadic: false)]
        instance.returnType = ArgonModule.shared.void
        return(instance)
        }
        
    public override func printLayout()
        {
        print("-------------------------")
        print("CLASS \(self.fullName.description)")
        print("")
        print("SizeInBytes: \(self.instanceSizeInBytes)")
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

//public class TypeRootClass: TypeClass
//    {
//    public override var isRootClass: Bool
//        {
//        return(true)
//        }
//
//    public init()
//        {
//        super.init(label: "Object",isSystem: true,generics: [])
//        }
//
//    required init?(coder: NSCoder)
//        {
//        super.init(coder: coder)
//        }
//
//    required init(label: Label) {
//        fatalError("init(label:) has not been implemented")
//    }
//
//    required init(label: Label, isSystem: Bool = false, generics: Types = []) {
//        fatalError("init(label:isSystem:generics:) has not been implemented")
//    }
//}
//
//public class TypeValueClass: TypeClass
//    {
//    public override var isValueClass: Bool
//        {
//        return(true)
//        }
//    }
//
//public class TypePrimitiveClass: TypeClass
//    {
//    }
//
//public class TypeArrayClass: TypeClass
//    {
//    }
//
public typealias TypeClasses = Array<TypeClass>
//
//public class TypeClassClass: TypeClass
//    {
//    }
