//
//  TypeClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Cocoa
import FFI
import MachMemory

public class TypeClass: TypeConstructor
    {
//    public static func ==(lhs: TypeClass,rhs:TypeClass) -> Bool
//        {
//        return(lhs.fullName == rhs.fullName && lhs.generics == rhs.generics)
//        }
//

    public static func ==(lhs:TypeClass,rhs:TypeClass) -> Bool
        {
        return(lhs.isEqual(rhs))
        }
        
    public var objectType: Argon.ObjectType
        {
        .class
        }
        
    public override var symbolType: SymbolType
        {
        .class
        }
        
    public override var displayName: String
        {
        self.label
        }
        
    public override var children: Symbols
        {
        self.instanceSlots.sorted{$0.label < $1.label} + self.subtypes.map{$0 as! TypeClass}.sorted{$0.label < $1.label }
        }
        
    public override var isRootClass: Bool
        {
        self.typeFlags.contains(.kRootTypeFlag)
        }
        
    public var allInstanceSlots: Array<InstanceSlot>
        {
        var slots = Array<InstanceSlot>()
        slots.append(contentsOf: self.instanceSlots)
        for aClass in self.superclasses
            {
            slots.append(contentsOf: aClass.allInstanceSlots)
            }
        return(slots)
        }
        
    public var superclassHierarchy: TypeClasses
        {
        var classes = TypeClasses()
        return(self.findSuperclassHierarchy(visitedClasses: &classes))
        }
        
    public override var isSetClass: Bool
        {
        self.label == "Set" && self.typeFlags.contains(.kSystemTypeFlag) && self.module.label == "Argon"
        }
        
    public override var isArrayClass: Bool
        {
        self.label == "Array" && self.typeFlags.contains(.kSystemTypeFlag) && self.module.label == "Argon"
        }
        
    public override var isListClass: Bool
        {
        self.label == "List" && self.typeFlags.contains(.kSystemTypeFlag) && self.module.label == "Argon"
        }
        
    public override var isDictionaryClass: Bool
        {
        self.label == "Dictionary" && self.typeFlags.contains(.kSystemTypeFlag) && self.module.label == "Argon"
        }
        
    public override var isBitSetClass: Bool
        {
        self.label == "BitSet" && self.typeFlags.contains(.kSystemTypeFlag) && self.module.label == "Argon"
        }
        
    public var lastSuperclass: TypeClass
        {
        if self.superclasses.isEmpty
            {
            return(self)
            }
        return(self.superclasses.last!)
        }
        
    public func relativeDepth(of: TypeClass) -> Int
        {
        var found = false
        return(self.relativeDepth(of: of,found: &found))
        }
        
    public func relativeDepth(of: TypeClass,found: inout Bool) -> Int
        {
        var depth = 1
        if self == of
            {
            found = true
            return(1)
            }
        for aClass in self.superclasses
            {
            depth += aClass.relativeDepth(of: of,found: &found)
            if found
                {
                break
                }
            }
        return(depth)
        }
        
    public var classPrecedenceList: TypeClasses
        {
        TopologicalSorter(class: self).sortedClasses()
        }
        
    public override var classValue: TypeClass
        {
        self
        }
        
    public var superclasses: TypeClasses
        {
        self.supertypes.map{$0 as! TypeClass}
        }

    public var allSupertypes: TypeClasses
        {
        self.allSuperclasses
        }
        
    public var allSuperclasses: TypeClasses
        {
        var visited = Set<TypeClass>()
        return(self.allSuperclasses(visited: &visited))
        }
        
    public func allSuperclasses(visited: inout Set<TypeClass>) -> TypeClasses
        {
        guard !visited.contains(self) else
            {
            return([])
            }
        visited.insert(self)
        var array = [self]
        array += self.superclasses.flatMap{$0.allSuperclasses(visited: &visited)}
        return(array)
        }
        
    public func allSupertypes(inClass aClass: TypeClass) -> Array<(Int,TypeClass)>
        {
        var array = [(0,self)]
        array += self.superclasses.flatMap{$0.allSupertypes(inClass: self)}
        return(array)
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
        
    public override var isFloatType: Bool
        {
        self.label == "Float"
        }
        
    public override var isArray: Bool
        {
        self.typeFlags.contains(.kArrayTypeFlag)
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
        self.container.argonModule.classType.instanceSizeInBytes
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
        return(1 + (self.superclasses.first?.depth ?? 0))
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
        self.typeFlags.contains(.kSystemTypeFlag)
        }
        
    public override var isVoidType: Bool
        {
        self.label == "Void"
        }
        
    public override func setModule(_ aModule: Module)
        {
        super.setModule(aModule)
        for slot in self.instanceSlots
            {
            slot.setModule(aModule)
            }
        for slot in self.layoutSlots
            {
            slot.setModule(aModule)
            }
        }
        
    public override var ffiType: ffi_type
        {
        fatalError()
        }
        
    public override var containsTypeVariable: Bool
        {
        for aType in self.generics
            {
            if aType.containsTypeVariable
                {
                return(true)
                }
            }
        return(false)
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
        
    public override var isClassType: Bool
        {
        true
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
        self.container.argonModule.classType as! TypeClass
        }
        
    public override var iconName: String
        {
        "IconClass"
        }
        
    public override var identityHash: Int
        {
        var hash = super.identityHash
        for aType in self.generics
            {
            hash = hash << 13 ^ aType.identityHash
            }
        return(hash)
        }
        
    public override var iconTint: NSColor
        {
        SyntaxColorPalette.classColor
        }
        
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        for type in self.generics
            {
            hashValue = hashValue << 13 ^ type.argonHash
            }
        return(hashValue)
        }
    ///
    ///
    /// Types own their classes since types are added to the symbol table
    /// not classes, therefore it is legitimate to set the parent of a
    /// class to be a type.
    ///
    ///
    private var _objectType: Argon.ObjectType = .object
    public var _subtypes = Types()
    public var supertypes = Types()
    public var instanceSlots = InstanceSlots()
    public var metaclass:TypeClass!
    public var layoutSlots = LayoutSlots()
    public private(set) var hasBytes: Bool = false
    private var classLayoutOffsets = Dictionary<TypeClass,Int>()
    public private(set) var slotIndexCache = Dictionary<Label,Int>()
    
    public func substitute(substitution: TypeContext.Substitution) -> Self
        {
        let newClass = Self(label: self.label)
        newClass.generics = self.generics.map{substitution.substitute($0)}
        newClass.setModule(substitution.symbols[self.module.argonHash] as! Module)
        newClass._objectType = self._objectType
        newClass._subtypes = self._subtypes.map{$0 as! TypeClass}.map{substitution.substitute($0)}
        newClass.supertypes = self.supertypes.map{$0 as! TypeClass}.map{substitution.substitute($0)}
        newClass.instanceSlots = self.instanceSlots.map{substitution.substitute($0) as! InstanceSlot}
        newClass.metaclass = substitution.substitute(self.metaclass) as? TypeClass
        newClass.layoutSlots = self.layoutSlots.map{substitution.substitute($0) as! LayoutSlot}
        newClass.hasBytes = self.hasBytes
        newClass.classLayoutOffsets = self.classLayoutOffsets
        newClass.slotIndexCache = self.slotIndexCache
        return(newClass)
        }
        
    required init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        super.init(label: label,generics: generics)
        }
        
    required init?(coder: NSCoder)
        {
        self._subtypes = coder.decodeObject(forKey: "subtypes") as! Types
        self.supertypes = coder.decodeObject(forKey: "supertypes") as! Types
        self.instanceSlots = coder.decodeObject(forKey: "instanceSlots") as! InstanceSlots
        self.layoutSlots = coder.decodeObject(forKey: "layoutSlots") as! LayoutSlots
        self.hasBytes = coder.decodeBool(forKey: "hasBytes")
        self.metaclass = coder.decodeObject(forKey: "metaclassClass") as? TypeClass
        super.init(coder: coder)
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
        let supertypeSurrogates = self.supertypes.map{TypeSurrogate(type: $0)}
        coder.encode(self._subtypes,forKey: "subtypes")
        coder.encode(supertypeSurrogates,forKey: "supertypes")
        coder.encode(self.instanceSlots,forKey: "instanceSlots")
        coder.encode(self.layoutSlots,forKey: "layoutSlots")
        coder.encode(self.metaclass,forKey: "metaclassClass")
        super.encode(with: coder)
        }
        
    public override func patchSymbols(topModule: TopModule)
        {
        guard !self.wasSymbolPatchingDone else
            {
            return
            }
        super.patchSymbols(topModule: topModule)
        self.supertypes = self.supertypes.map{$0 as! TypeSurrogate}.map{$0.patchClass(topModule: topModule)}
        for slot in self.instanceSlots
            {
            slot.patchSymbols(topModule: topModule)
            }
        for slot in self.layoutSlots
            {
            slot.patchSymbols(topModule: topModule)
            }
        for aType in self.supertypes
            {
            aType.patchSymbols(topModule: topModule)
            }
        }
        
    public override func lookup(name inName: Name) -> Symbol?
        {
        if inName.isEmpty
            {
            return(nil)
            }
        let first = inName.car
        for symbol in self.instanceSlots
            {
            if symbol.label == first
                {
                if inName.isEmpty
                    {
                    return(symbol)
                    }
                return(nil)
                }
            }
        return(nil)
        }
        
    public func relinkSupertypes(topModule: TopModule)
        {
        self.supertypes = self.supertypes.map{($0 as! SurrogateType).actualType(topModule: topModule)}
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        let newClass = Self(label: self.label,isSystem: self.isSystemType,generics: types)
        newClass.setModule(self.module)
//        newClass.container = self.container
        newClass.setIndex(self.index.keyByIncrementingMinor())
        newClass.flags(self.typeFlags.subtracting(.kArcheTypeFlag))
        newClass.hasBytes = self.hasBytes
        newClass._subtypes = self._subtypes
        newClass.supertypes = self.supertypes
        newClass.instanceSlots = self.instanceSlots
        newClass.layoutSlots = self.layoutSlots
        newClass.issues = self.issues
        newClass.makeMetaclass()
        newClass.configureMetaclass(argonModule: self.container.argonModule)
        return(newClass)
        }
        
    public func removeFromHierarchy()
        {
        for aClass in self.superclasses
            {
            aClass.subtypes.remove(self)
            }
        self.subtypes = []
        }
        
    public func configureMetaclass(argonModule: ArgonModule)
        {
        self.metaclass.generics = self.generics.compactMap{$0 as? TypeClass}.map{$0.metaclass}
        self.metaclass.supertypes = self.superclasses.map{$0.metaclass}
        self.metaclass.subtypes = self.subtypes.compactMap{$0 as? TypeClass}.map{$0.metaclass}
        self.metaclass.metaclass = argonModule.metaclassType as? TypeClass
        self.metaclass.type = argonModule.metaclassType
        }
        
    public override func setType(_ type: Argon.ObjectType) -> Type
        {
        self._objectType = type
        return(self)
        }
        
    public override func removeFromParentSymbol()
        {
        super.removeFromParentSymbol()
        for aClass in self.superclasses
            {
            aClass.removeSubclass(self)
            }
        }
        
    public override func insertInHierarchy()
        {
        for aClass in self.superclasses
            {
            aClass.addSubtype(self)
            }
        }
        
    public func addSupertype(_ type: Type)
        {
        guard !self.supertypes.contains(type) else
            {
            return
            }
        self.supertypes.append(type)
        type.addSubtype(self)
        }
        
    public func addSuperclassWithoutUpdatingSuperclass(_ type: Type)
        {
        guard !self.supertypes.contains(type) else
            {
            return
            }
        self.supertypes.append(type)
        }
        
    public func removeSubclass(_ typeClass: TypeClass)
        {
        if self.subtypes.contains(typeClass)
            {
            let index = self.subtypes.firstIndex(of: typeClass)!
            self.subtypes.remove(at: index)
            }
        }
        
    public override func addSubtype(_ type: Type)
        {
        guard !self.subtypes.contains(type) else
            {
            return
            }
        self.subtypes.append(type)
        }
        
    public func allInstanceSlotsContainsSlotWithLabel(_ label: Label) -> Bool
        {
        let allSlots = self.allInstanceSlots
        for slot in allSlots
            {
            if slot.label == label
                {
                return(true)
                }
            }
        return(false)
        }
        
    @discardableResult
    public func makeMetaclass() -> TypeClass
        {
        self.metaclass = TypeMetaclass(label: self.label + "Class")
        self.metaclass.setModule(self.module)
        self.type = self.metaclass
        return(self.metaclass)
        }
        
//    public override func setType(_ objectType:Argon.ObjectType) -> Type
//        {
//        self.objectType = objectType
//        return(self)
//        }
        
    public func cacheIndices()
        {
        guard self.slotIndexCache.isEmpty else
            {
            return
            }
        for slot in self.allInstanceSlots
            {
            let index = self.offsetInObject(ofSlot: slot) / Argon.kWordSizeInBytesInt
            self.slotIndexCache[slot.label] = index
            }
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? TypeClass
            {
            return(self.identityHash == second.identityHash && self.generics.count == second.generics.count && self.generics == second.generics)
            }
        return(super.isEqual(object))
        }
        
    public override func isSubclass(of ofType: Type) -> Bool
        {
        if !(ofType is TypeClass)
            {
            return(false)
            }
        let superclass = ofType as! TypeClass
        if self.generics.count != superclass.generics.count
            {
            return(false)
            }
        let results = zip(self.generics,superclass.generics).map{$0.0.isSubclass(of: $0.1)}
        let result = results.reduce(true,{$0 && $1})
        if self == superclass && result
            {
            return(true)
            }
            
        if self.supertypes.isEmpty
            {
            return(false)
            }
        for supertype in self.supertypes
            {
            if (supertype as! TypeClass).isSubclass(of: superclass)
                {
                return(true)
                }
            }
        return(false)
        }
        
    public override func isSubtype(of type: Type) -> Bool
        {
        type is TypeClass && (self.isSubclass(of: (type as! TypeClass)))
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for generic in self.generics
            {
            if generic.label == label
                {
                return(generic)
                }
            }
        if label.hasPrefix("_")
            {
            for slot in self.layoutSlots
                {
                if slot.label == label
                    {
                    return(slot)
                    }
                }
            return(nil)
            }
        for slot in self.instanceSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        for aClass in self.superclasses
            {
            if let slot = aClass.lookup(label: label)
                {
                return(slot)
                }
            }
        return(self.module.lookup(label: label))
        }
        
    public override func addInstanceSlot(_ slot: InstanceSlot)
        {
        for oldSlot in self.instanceSlots
            {
            if oldSlot.label == slot.label
                {
                fatalError("Duplicate instance slot \(slot.label)")
                }
            }
        slot.offset = Argon.kWordSizeInBytesInt * self.instanceSlots.count
        slot.owningType = self
        self.instanceSlots.append(slot)
        slot.container = .symbol(self)
        slot.setModule(self.module)
        }
        
    public override func addLayoutSlot(_ slot: LayoutSlot)
        {
        for oldSlot in self.layoutSlots
            {
            if oldSlot.label == slot.label
                {
                fatalError("Duplicate slot")
                }
            }
        self.layoutSlots.append(slot)
        slot.container = .symbol(self)
        slot.setModule(self.module)
        }
        
    public func layoutObject(atAddress: Address)
        {
        let someClasses = self.allSuperclasses
//        print("LAYING OUT OBJECT OF cLASS \(self.label)")
//        print("CLASS LIST: \(someClasses)")
        let slots = self.virtualTableSlots
        if someClasses.count > 2
            {
            print(slots)
            }
        self.layoutObject(inClass: self,atAddress: atAddress,writeInnerHeader: false)
        }
        
    private func layoutObject(inClass: TypeClass,atAddress: Address,writeInnerHeader: Bool)
        {
        var address = atAddress
        if writeInnerHeader
            {
            let header = Header(atAddress: address)
            header.tag = .header
            header.sizeInBytes = Word(self.instanceSizeInBytes)
            header.hasBytes = false
            header.isForwarded = false
            header.flipCount = 0
            header.objectType = self.objectType
//            let someWord = WordAtAddress(address)
//            print("INNER HEADER FOR OBJECT OF CLASS \(self.label) \(someWord.bitString)")
            }
        address += Argon.kWordSizeInBytesWord
        let word1 = Word(integer: self.magicNumber)
        SetWordAtAddress(word1,address)
//        let someWord1 = WordAtAddress(address)
//        print("MAGIC NUMBER: \(someWord1.bitString)")
        address += Argon.kWordSizeInBytesWord
        let word2 = Word(pointer: self.memoryAddress)
        SetWordAtAddress(word2,address)
//        let someWord2 = WordAtAddress(address)
//        print("CLASS POINTER: \(someWord2.bitString)")
        address += Argon.kWordSizeInBytesWord
        let virtualTable = inClass.virtualTable(forClass: self)
        ///
        ///
        /// THE VT ADDRESS NEEDS TO BE OFFSET BY A WORD BECAUSE THE VT HAS A HEADER RECORD
        ///
        ///
        let word3 = Word(pointer: virtualTable.memoryAddress + Argon.kWordSizeInBytesWord)
        SetWordAtAddress(word3,address)
//        let someWord3 = WordAtAddress(address)
//        print("VT POINTER: \(someWord3.bitString)")
        address += Argon.kWordSizeInBytesWord
        for aClass in self.superclasses
            {
            aClass.layoutObject(inClass: inClass,atAddress: address,writeInnerHeader: true)
            }
        }
        
    private func virtualTable(forClass: TypeClass) -> VirtualTable
        {
        let slots = self.layoutSlots.compactMap{$0 as? VirtualTableSlot}
        for slot in slots
            {
            if slot.virtualTable.forClass == forClass
                {
                return(slot.virtualTable)
                }
            }
        fatalError("VirtualTable not found for class \(forClass.label)")
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        ///
        /// WE USED TO CHECK TO SEE WHETHER THE SYMBOL WAS A PRIMITIVE OR NOT AND THEN WE
        /// DID NOT LAYOUT THE TYPE IF IT WAS, BUT WE NEED THE PRIMITIVE CLASSES EVEN IF
        /// THE NORMAL METHODS OF ACCESSING A CLASS OF AN OBJECT ARE MAGICKED IN.
        ///
        guard self.wasAddressAllocationDone else
            {
            fatalError("Address allocation should have been done")
            }
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        self.metaclass.layoutInMemory(using: allocator)
        let classPointer = ClassBasedPointer(address: self.memoryAddress.cleanAddress,type: self.classType,argonModule: self.container.argonModule)
        classPointer.objectType = self.objectType
        classPointer.setClass(self.classType)
        classPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        for type in self.supertypes
            {
            type.layoutInMemory(using: allocator)
            }
        let superArray = segment.allocateArray(size: self.supertypes.count)
        let superPointer = ArrayPointer(dirtyAddress: superArray,argonModule: self.container.argonModule)!
        for type in self.supertypes
            {
            superPointer.append(Word(pointer: type.memoryAddress))
            }
        classPointer.setAddress(superArray,atSlot: "superclasses")
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
            slot.layoutInMemory(using: allocator)
            }
        let slotsArray = segment.allocateArray(size: self.layoutSlots.count,elements: self.layoutSlots.map{$0.memoryAddress})
        classPointer.setAddress(slotsArray,atSlot: "slots")
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
            if let typesArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: generics.count),argonModule: self.container.argonModule)
                {
                for type in generics
                    {
                    type.layoutInMemory(using: allocator)
                    typesArray.append(type.memoryAddress)
                    }
                classPointer.setAddress(typesArray.address,atSlot: "typeParameters")
                }
            }
//        MemoryPointer.dumpMemory(atAddress: self.memoryAddress, count: 20)
        }
        
    internal func layoutBaseSlots(inClass: TypeClass,slotPrefix: String,offset: inout Int,visitedClasses: inout TypeClasses)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.append(self)
        let name1 = slotPrefix.isEmpty ? "header" : "Header"
        var slot = LayoutSlot(labeled: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",ofType: self.container.argonModule.integer)
        slot.setOffset(offset)
//        print("SETTING \(name1) OFFSET TO \(offset)")
        slot.slotType = .kSystemHeaderSlot
        slot.owningType = self
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
        slot = LayoutSlot(labeled: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",ofType: self.container.argonModule.integer)
        slot.setOffset(offset)
        slot.slotType = .kSystemMagicNumberSlot
        slot.owningType = self
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name3 = slotPrefix.isEmpty ? "class" : "Class"
        slot = LayoutSlot(labeled: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",ofType: self.container.argonModule.address)
        slot.setOffset(offset)
        slot.slotType = .kSystemClassSlot
        slot.owningType = self
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name4 = slotPrefix.isEmpty ? "virtualTable" : "VirtualTable"
        let tableSlot = VirtualTableSlot(labeled: "_\(slotPrefix.lowercasingFirstLetter)\(name4)",ofType: self.container.argonModule.address)
        tableSlot.virtualTable = VirtualTable(forClass: self)
        tableSlot.setOffset(offset)
        tableSlot.slotType = .kSystemVirtualTableSlot
        tableSlot.owningType = self
        inClass.addLayoutSlot(tableSlot)
        offset += Argon.kWordSizeInBytesInt
        for aClass in self.superclasses
            {
            let prefix = aClass.label.lowercasingFirstLetter
            aClass.layoutBaseSlots(inClass: inClass,slotPrefix: prefix,offset: &offset,visitedClasses: &visitedClasses)
            }
        }

    public func instanceSlot(atLabel: Label) -> InstanceSlot
        {
        for slot in self.instanceSlots
            {
            if slot.label == atLabel
                {
                return(slot)
                }
            }
        fatalError("SLOT \(atLabel) NOT FOUND")
        }
        
//    public func systemSlot(atLabel: Label) -> Slot
//        {
//        for slot in self.localSystemSlots
//            {
//            if slot.label == atLabel
//                {
//                return(slot)
//                }
//            }
//        fatalError("SLOT \(atLabel) NOT FOUND")
//        }
        
    public func findSuperclassHierarchy(visitedClasses: inout TypeClasses) -> TypeClasses
        {
        guard !visitedClasses.contains(self) else
            {
            return([])
            }
        visitedClasses.append(self)
        var classes = TypeClasses()
        classes += [self]
        for aClass in self.superclasses
            {
            classes += aClass.findSuperclassHierarchy(visitedClasses: &visitedClasses)
            }
        return(classes)
        }
        
    public override func layoutObjectSlots()
        {
        guard !self.wasSlotLayoutDone else
            {
            return
            }
        self.wasSlotLayoutDone = true
        var offset = 0
        var visitedClasses = TypeClasses()
        self.layoutBaseSlots(inClass: self,slotPrefix: "",offset: &offset,visitedClasses: &visitedClasses)
        visitedClasses = []
        self.layoutInstanceSlots(inClass: self,offset: &offset,visitedClasses: &visitedClasses)
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        var start = 0
        while start < self.layoutSlots.count && !self.layoutSlots[start].slotType.contains(.kInstanceSlot)
            {
            start += 1
            }
        if start < self.layoutSlots.count
            {
            var aClass = self.layoutSlots[start].owningClass
            self.classLayoutOffsets[aClass] = self.layoutSlots[start].offset
            for index in start..<self.layoutSlots.count
                {
                let slot = self.layoutSlots[index]
                if slot.owningClass != aClass
                    {
                    self.classLayoutOffsets[slot.owningClass] = slot.offset
                    aClass = slot.owningClass
                    }
                }
            }
        var headerSlots = Dictionary<TypeClass,Slot>()
        var virtualSlots = Dictionary<TypeClass,Slot>()
        let listOfSuperclasses = self.allSuperclasses
        for slot in self.layoutSlots
            {
            let index = listOfSuperclasses.firstIndex(of: slot.owningClass)!
            slot.classIndexInVirtualTable = index
            if slot.slotType.contains(.kSystemHeaderSlot)
                {
                headerSlots[slot.owningClass] = slot
                }
            else if slot.slotType.contains(.kSystemVirtualTableSlot)
                {
                virtualSlots[slot.owningClass] = slot
                }
            }
        if start < self.layoutSlots.count
            {
            let startSlot = self.layoutSlots[start]
            for tableSlot in virtualSlots.values
                {
                let virtualTable = (tableSlot as! VirtualTableSlot).virtualTable!
                let classes = virtualTable.forClass.superclassHierarchy
                for someClass in classes
                    {
                    let headerSlot = headerSlots[virtualTable.forClass]!
                    var delta = 0
                    if let firstSlot = self.firstInstanceSlotOwned(byClass: someClass)
                        {
                        delta = firstSlot.offset - headerSlot.offset
                        }
                    virtualTable.entries.append(VirtualTable.VirtualTableEntry(class: someClass, offset: delta))
                    }
                }
            for index in start..<self.layoutSlots.count
                {
                let slot = layoutSlots[index]
                slot.virtualOffset = slot.offset - startSlot.offset
                }
            }
        self.cacheIndices()
        }
        
    private func firstInstanceSlotOwned(byClass: TypeClass) -> Slot?
        {
        for slot in self.layoutSlots
            {
            if slot.slotType.contains(.kInstanceSlot) && slot.owningClass == byClass
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func layoutInstanceSlots(inClass: TypeClass,offset: inout Int,visitedClasses: inout TypeClasses)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.append(self)
        var localOffset = 0
        for slot in self.instanceSlots
            {
            slot.offset = localOffset
            localOffset += Argon.kWordSizeInBytesInt
            let clonedSlot = LayoutSlot(instanceSlot: slot)
            clonedSlot.setOffset(offset)
            clonedSlot.owningType = self
            offset += clonedSlot.size
            inClass.addLayoutSlot(clonedSlot)
            }
        for aClass in self.superclasses
            {
            aClass.layoutInstanceSlots(inClass: inClass,offset: &offset,visitedClasses: &visitedClasses)
            }
        }
        
    private var virtualTableSlots: Array<VirtualTableSlot>
        {
        self.layoutSlots.compactMap({$0 as? VirtualTableSlot})
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        for slot in self.virtualTableSlots
            {
            slot.virtualTable.allocateAddresses(using: allocator)
            }
        allocator.allocateAddress(for: self)
        self.metaclass.allocateAddresses(using: allocator)
        for aClass in self.superclasses
            {
            aClass.allocateAddresses(using: allocator)
            }
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
        self.addSupertype(type)
        return(self)
        }
        
    @discardableResult
    public override func slot(_ label: Label,_ type: Type) -> Type
        {
        let slot = InstanceSlot(labeled:label,ofType: type)
        self.addInstanceSlot(slot)
        return(self)
        }
        
    @discardableResult
    public override func slot(_ label: Label,mandatory:Argon.Symbol,_ type: Type) -> Type
        {
        let slot = InstanceSlot(labeled:label,ofType: type)
        slot.slotMandatorySelector = Argon.addStatic(StaticSymbol(string: mandatory))
        self.addInstanceSlot(slot)
        return(self)
        }
        
    public func slotReader(forSlot slot: Slot) -> MethodInstance
        {
//        let instance = SlotAccessorMethodInstance(label: slot.label,classType: self)
//        instance.parameters = [Parameter(label: "object", relabel: nil, type: self, isVisible: false, isVariadic: false)]
//        instance.returnType = slot.type
//        return(instance)
        fatalError()
        }
        
   public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        if self.generics.isEmpty
            {
            return(self)
            }
        return(self.withGenerics(self.generics.map{$0.freshTypeVariable(inContext: context)}) as! Self)
        }
        
    public func offsetInVirtualTable(forSlot: MemberSlot) -> Int
        {
        var found = false
        var offset = 0
        self.virtualTableOffset(forSlot: forSlot, offset: &offset, found: &found)
        return(offset)
        }
        
    private func virtualTableOffset(forSlot: MemberSlot,offset: inout Int,found: inout Bool)
        {
        if found
            {
            return
            }
        let slotClass = forSlot.owningClass
        if slotClass == self
            {
            found = true
            return
            }
        offset = 0
        for aSuper in self.superclasses
            {
            aSuper.virtualTableOffset(forSlot: forSlot,offset: &offset,found: &found)
            offset += 1
            if found
                {
                return
                }
            }
        }
        
    public func offsetInObject(ofSlot slot: MemberSlot) -> Int
        {
        let offsetInTable = self.offsetInVirtualTable(forSlot: slot)
//        print("OFFSET FROM TOP OF TABLE FOR SLOT IS \(offsetInTable)")
        let virtualTable = (self.layoutSlots[3] as! VirtualTableSlot).virtualTable!
//        print("TABLE IS")
//        for entry in virtualTable.entries
//            {
//            print("\(entry.offset)")
//            }
        let entry = virtualTable.entries[offsetInTable]
//        print("OFFSET IN OBJECT \(self.label) SLOT \(slot.label) IS \(entry.offset)")
        return(entry.offset + slot.offset)
        }
        
    public override func printLayout()
        {
        if self.label == "TestClass"
            {
            print("")
            }
        print("-------------------------")
        print("CLASS \(self.fullName.description)")
        print("")
        print("SizeInBytes: \(self.instanceSizeInBytes)")
        print("")
        print()
        var index = 0
        for slot in self.layoutSlots.sorted(by: {$0.offset < $1.offset})
            {
            let indexString = String(format:"%04d",index)
            let offsetString = String(format:"%06d",slot.offset)
            let virtual = slot.slotType.isInstanceSlot ? String(format: "%06d",slot.virtualOffset) : ""
            print("\(indexString) \(offsetString) \(slot.label) \(virtual)")
            if slot.slotType.contains(.kSystemVirtualTableSlot)
                {
                let vslot = slot as! VirtualTableSlot
                let table = vslot.virtualTable!
                let lastSuper = table.forClass.lastSuperclass
                print("\t\t\t\tVirtual Table for \(table.forClass.label) LAST: \(lastSuper.label) \(table.forClass.depth)")
                for entry in table.entries
                    {
                    let depth = table.forClass.relativeDepth(of: entry.clazz)
                    print("\t\t\t\t\(entry.clazz.label) \(entry.offset) \(depth)")
                    }
                let list = table.forClass.superclassHierarchy
                var index = 1
                for item in list
                    {
                    print("\(item.label) \(index) \(item.depth) \(table.forClass.relativeDepth(of: item))")
                    index += 1
                    }
                }
            index += 1
            }
        for aClass in self.superclassHierarchy
            {
            for slot in aClass.instanceSlots
                {
                var offset = 0
                var found = false
                self.virtualTableOffset(forSlot: slot, offset: &offset, found: &found)
                print("\(slot.label) \(offset)")
                }
            }
        print("LAYOUT FOR \(self.fullName.description)")
        print("-------------------------------------")
        var offset = 0
        for slot in self.layoutSlots
            {
            let string = String(format: "%06d",offset)
            print("\(string) \(slot.label) \(slot.slotType.displayString)")
            offset += Argon.kWordSizeInBytesInt
            }
        }
        
    @discardableResult
    public override func typeVar(_ label: Label) -> TypeVariable
        {
        let typeVariable = TypeContext.freshTypeVariable(named: label)
        self.generics.append(typeVariable)
        return(typeVariable)
        }
        
    @discardableResult
    public override func typeVar(_ typeVar: TypeVariable) -> Type
        {
        self.generics.append(typeVar)
        return(self)
        }
        
    public override func typeVar(atId: Int) -> TypeVariable?
        {
        for element in self.generics
            {
            if let typeVar = element as? TypeVariable
                {
                if typeVar.id == atId
                    {
                    return(typeVar)
                    }
                }
            }
        return(nil)
        }
        
    public override func isEquivalent(_ type: Type) -> Bool
        {
        if self.label != type.label
            {
            return(false)
            }
        if let rhs = type as? TypeClass
            {
            if self.generics.count != rhs.generics.count
                {
                return(false)
                }
            for (left,right) in zip(self.generics,rhs.generics)
                {
                if !left.isEquivalent(right)
                    {
                    return(false)
                    }
                }
            return(true)
            }
        return(false)
        }
    }

public typealias TypeClasses = Array<TypeClass>

