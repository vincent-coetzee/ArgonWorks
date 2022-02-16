//
//  TypeClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation
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
        
    public var isRootClass: Bool
        {
        self.typeFlags.contains(.kRootTypeFlag)
        }
        
    public var allInstanceSlots: Array<Slot>
        {
        var slots = Array<Slot>()
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
        
    public override var classValue: TypeClass
        {
        self
        }
        
    public var superclasses: TypeClasses
        {
        self.supertypes.map{$0 as! TypeClass}
        }
        
    public var rawPrecedenceList: TypeClasses
        {
        var array = TypeClasses()
        array += self.superclasses
        array += self.superclasses.flatMap{$0.rawPrecedenceList}
        return(array)
        }
        
    public var allSupertypes: TypeClasses
        {
        var array = [self]
        array += self.superclasses.flatMap{$0.allSupertypes}
        return(array)
        }
        
    public func allSupertypes(inClass aClass: TypeClass) -> Array<(Int,TypeClass)>
        {
        var array = [(0,self)]
        array += self.superclasses.flatMap{$0.allSupertypes(inClass: self)}
        return(array)
        }
        
    public var precedenceList: TypeClasses
        {
        var array = [(0,self)]
        array += self.superclasses.flatMap{$0.allSupertypes(inClass: self)}
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
        let sorted = list.sorted{"\($0.1.depth).\($0.0)" > "\($1.1.depth).\($1.0)"}
        let classes = sorted.map{$0.1}
        return(classes)
        }
        
//    public func isDirectSuperclass(of aClass: Type) -> Bool
//        {
//        aClass.superclasses.contains(self)
//        }
//        
//    public var classPrecedenceList: Array<TypeClass>
//        {
//        var classes = Array(Set(self.allSupertypes))
//        var list = TypeClasses()
//        list.append(self)
//        classes.remove(self)
//        var currentClass:TypeClass = self
//        while !classes.isEmpty
//            {
//            let classList = classes
//            for aClass in classList
//                {
//                if currentClass.superclasses.contains(aClass)
//                    {
//                    list.append(aClass)
//                    classes.remove(aClass)
//                    }
//                }
//            }
//        }
        
    private class ClassNode
        {
        internal static var classNodes = Dictionary<TypeClass,ClassNode>()
        
        internal static func classNode(forClass: TypeClass) -> ClassNode
            {
            if let node = self.classNodes[forClass]
                {
                return(node)
                }
            let node = ClassNode(class: forClass)
            self.classNodes[forClass] = node
            return(node)
            }
            
        internal var adjacents: Array<ClassNode>
            {
            return(self.theClass.superclasses.map{ClassNode.classNode(forClass: $0)})
            }
            
        internal let theClass: TypeClass
        internal var number: Int = 0
        internal var label: Int = 0
        
        init(class aClass: TypeClass)
            {
            self.theClass = aClass
            }
        }
        
    public func topologicalSort() -> TypeClasses
        {
        var nodes = Array<ClassNode>()
        for type in self.allSupertypes
            {
            nodes.append(ClassNode.classNode(forClass: type))
            }
        var j = nodes.count + 1
        var i = 0
        for node in nodes
            {
            if node.number == 0
                {
                self.topSort(node,i: &i,j: &j)
                }
            }
        return(nodes.sorted{$0.label < $1.label}.map{$0.theClass})
        }
        
    private func topSort(_ node: ClassNode,i:inout Int,j:inout Int)
        {
        i = i + 1
        node.number = i
        for vertex in node.adjacents
            {
            if vertex.number == 0
                {
                self.topSort(vertex,i:&i,j: &j)
                }
            else if vertex.label == 0
                {
                fatalError("Circular class hierarchy")
                }
            j = j - 1
            node.label = j
            }
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
    public var _subtypes = Types()
    public var supertypes = Types()
    public var instanceSlots = Slots()
    public var localSystemSlots = Slots()
    public var layoutSlots = Slots()
    public private(set) var hasBytes: Bool = false
    private var classLayoutOffsets = Dictionary<TypeClass,Int>()
    public private(set) var slotIndexCache = Dictionary<Label,Int>()
    
    required init(label: Label,isSystem: Bool = false,generics: Types = [])
        {
        super.init(label: label,generics: generics)
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE CLASS")
        self._subtypes = coder.decodeObject(forKey: "subtypes") as! Types
        self.supertypes = coder.decodeObject(forKey: "supertypes") as! Types
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
        coder.encode(self.supertypes,forKey: "supertypes")
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
        newClass.supertypes = self.supertypes
        newClass.instanceSlots = self.instanceSlots
        newClass.layoutSlots = self.layoutSlots
        return(newClass)
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
            return(self.fullName == second.fullName && self.generics.count == second.generics.count && self.generics == second.generics)
            }
        return(super.isEqual(object))
        }
        
    public func isSubclass(of superclass: TypeClass) -> Bool
        {
        if self == superclass
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
        return(nil)
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
        slot.offset = Argon.kWordSizeInBytesInt * self.instanceSlots.count
        slot.owningClass = self
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
        
    public func layoutObject(atAddress: Address)
        {
        self.layoutObject(inClass: self,atAddress: atAddress,writeInnerHeader: false)
        }
        
    private func layoutObject(inClass: TypeClass,atAddress: Address,writeInnerHeader: Bool)
        {
        var address = atAddress
        if writeInnerHeader
            {
            let header = Header(word: 0)
            header.tag = .header
            header.sizeInBytes = Word(self.instanceSizeInBytes)
            header.hasBytes = false
            header.isForwarded = false
            header.flipCount = 0
            SetWordAtAddress(header.bytes,address)
            }
        address += Argon.kWordSizeInBytesWord
        let word1 = Word(integer: self.magicNumber)
        SetWordAtAddress(word1,atAddress)
        address += Argon.kWordSizeInBytesWord
        let word2 = Word(pointer: self.memoryAddress)
        SetWordAtAddress(word2,address)
        address += Argon.kWordSizeInBytesWord
        let virtualTable = inClass.virtualTable(forClass: self)
        let word3 = virtualTable.memoryAddress
        SetWordAtAddress(word3,address)
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
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let classPointer = ClassBasedPointer(address: self.memoryAddress.cleanAddress,type: self.classType)
        classPointer.objectType = self.objectType
        classPointer.setClass(classType)
        classPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        for type in self.supertypes
            {
            type.layoutInMemory(using: allocator)
            }
        let superArray = segment.allocateArray(size: self.supertypes.count)
        let superPointer = ArrayPointer(dirtyAddress: superArray)!
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
        for slot in self.instanceSlots
            {
            slot.setMemoryAddress(segment.allocateObject(ofType: ArgonModule.shared.slot,extraSizeInBytes: 0))
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
            if let typesArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: generics.count))
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
        
    public func initMetatype(inModule: Module)
        {
        guard self.type.isNil else
            {
            return
            }
//        for type in self.superclasses
//            {
//            if type.type.isNil
//                {
//                type.initMetatype(inModule: inModule)
//                }
//            }
        if let aType = self.module.lookup(label: self.label + "Class") as? TypeMetaclass
            {
            self.type = aType
            }
        else
            {
            let typeMetaclass = TypeMetaclass(label: self.label + "Class",isSystem: self.isSystemType,generics: self.generics)
            typeMetaclass.type = ArgonModule.shared.metaclassType
            for type in self.supertypes
                {
                typeMetaclass.addSupertype(type.type)
                }
            typeMetaclass.flags([.kSystemTypeFlag,.kMetaclassFlag])
            inModule.addSymbol(typeMetaclass)
            self.type = typeMetaclass
//            for type in self.subtypes
//                {
//                (type as! TypeClass).initMetatype(inModule: inModule)
//                }
            }
        }
        
    internal func layoutBaseSlots(inClass: TypeClass,slotPrefix: String,offset: inout Int,visitedClasses: inout TypeClasses)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.append(self)
        var systemSlots = Slots()
        let name1 = slotPrefix.isEmpty ? "header" : "Header"
        var slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
//        print("SETTING \(name1) OFFSET TO \(offset)")
        slot.slotType = .kSystemHeaderSlot
        slot.owningClass = self
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        slot.slotType = .kSystemMagicNumberSlot
        slot.owningClass = self
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name3 = slotPrefix.isEmpty ? "class" : "Class"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: ArgonModule.shared.integer)
        slot.setOffset(offset)
        slot.slotType = .kSystemClassSlot
        slot.owningClass = self
        systemSlots.append(slot)
        inClass.addLayoutSlot(slot)
        offset += Argon.kWordSizeInBytesInt
        let name4 = slotPrefix.isEmpty ? "virtualTable" : "VirtualTable"
        let tableSlot = VirtualTableSlot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name4)",type: ArgonModule.shared.integer)
        tableSlot.virtualTable = VirtualTable(forClass: self)
        tableSlot.setOffset(offset)
        tableSlot.slotType = .kSystemVirtualTableSlot
        tableSlot.owningClass = self
        systemSlots.append(tableSlot)
        inClass.addLayoutSlot(tableSlot)
        offset += Argon.kWordSizeInBytesInt
        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
        for aClass in self.superclasses
            {
            let prefix = aClass.label.lowercasingFirstLetter
            aClass.layoutBaseSlots(inClass: inClass,slotPrefix: prefix,offset: &offset,visitedClasses: &visitedClasses)
            }
        }

    public func instanceSlot(atLabel: Label) -> Slot
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
        
    public func systemSlot(atLabel: Label) -> Slot
        {
        for slot in self.localSystemSlots
            {
            if slot.label == atLabel
                {
                return(slot)
                }
            }
        fatalError("SLOT \(atLabel) NOT FOUND")
        }
        
//    private func layoutClass(inClass: TypeClass,slotPrefix: String,offset: inout Int)
//        {
//        var systemSlots = Slots()
//        let name1 = slotPrefix.isEmpty ? "header" : "Header"
//        var slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        print("SETTING \(name1) OFFSET TO \(offset)")
//        slot.slotType = .kSystemHeaderSlot
//        systemSlots.append(slot)
//        inClass.addLayoutSlot(slot)
//        offset += Argon.kWordSizeInBytesInt
//        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
//        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        slot.slotType = .kSystemMagicNumberSlot
//        systemSlots.append(slot)
//        inClass.addLayoutSlot(slot)
//        offset += Argon.kWordSizeInBytesInt
//        let name3 = slotPrefix.isEmpty ? "class" : "Class"
//        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        slot.slotType = .kSystemClassSlot
//        systemSlots.append(slot)
//        inClass.addLayoutSlot(slot)
//        offset += Argon.kWordSizeInBytesInt
//        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
//        for aClass in self.supertypes.map({$0 as! TypeClass})
//            {
//            aClass.layoutOffsetSlots(inClass: inClass,offset: &offset)
//            }
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
        self.layoutObjectSlots(inClass: self,offset: &offset,visitedClasses: &visitedClasses)
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        var start = 0
        while start < self.layoutSlots.count && !self.layoutSlots[start].slotType.contains(.kInstanceSlot)
            {
            start += 1
            }
        if start < self.layoutSlots.count
            {
            var aClass = self.layoutSlots[start].owningClass!
            self.classLayoutOffsets[aClass] = self.layoutSlots[start].offset
            for index in start..<self.layoutSlots.count
                {
                let slot = self.layoutSlots[index]
                if slot.owningClass! != aClass
                    {
                    self.classLayoutOffsets[slot.owningClass!] = slot.offset
                    aClass = slot.owningClass!
                    }
                }
            }
        var headerSlots = Dictionary<TypeClass,Slot>()
        var virtualSlots = Dictionary<TypeClass,Slot>()
        for slot in self.layoutSlots
            {
            if slot.slotType.contains(.kSystemHeaderSlot)
                {
                headerSlots[slot.owningClass!] = slot
                }
            else if slot.slotType.contains(.kSystemVirtualTableSlot)
                {
                virtualSlots[slot.owningClass!] = slot
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
                    var delta = -1
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
        
    public func layoutObjectSlots(inClass: TypeClass,offset: inout Int,visitedClasses: inout TypeClasses)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.append(self)
//        self.layoutBaseSlots(inClass: inClass,slotPrefix: self.label,offset: &offset)
        var localOffset = 0
        for slot in self.instanceSlots
            {
            slot.offset = localOffset
            localOffset += Argon.kWordSizeInBytesInt
            let clonedSlot = slot.cloned
            clonedSlot.setOffset(offset)
            clonedSlot.owningClass = self
            offset += clonedSlot.size
            inClass.addLayoutSlot(clonedSlot)
            }
        for aClass in self.superclasses
            {
            aClass.layoutObjectSlots(inClass: inClass,offset: &offset,visitedClasses: &visitedClasses)
            }
        }
        
    private var virtualTableSlots: Array<VirtualTableSlot>
        {
        self.localSystemSlots.compactMap({$0 as? VirtualTableSlot})
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
//        print("ABOUT TO ALLOCATE ADDRESS FOR CLASS \(self.label), SIZE IN BYTES IS \(self.sizeInBytes)")
        allocator.allocateAddress(for: self)
//        print("AFTER ALLOCATE ADDRESS FOR CLASS, ADDRESS IS \(self.memoryAddress)")
//        let header = Header(atAddress: self.memoryAddress)
//        print("HEADER SIZE IN WORDS IS \(header.sizeInWords) SHOULD BE \(self.sizeInBytes / 8)")
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
        
    public override func slot(_ label: Label,_ type: Type) -> Type
        {
        let slot = InstanceSlot(labeled:label,ofType: type)
        self.addInstanceSlot(slot)
        return(self)
        }
        
    public func slotReader(forSlot slot: Slot) -> MethodInstance
        {
        let instance = SlotAccessorMethodInstance(label: slot.label,classType: self)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self, isVisible: false, isVariadic: false)]
        instance.returnType = slot.type
        return(instance)
        }
        
   public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        if self.generics.isEmpty
            {
            return(self)
            }
        return(self.withGenerics(self.generics.map{$0.freshTypeVariable(inContext: context)}) as! Self)
        }
        
    public func offsetInVirtualTable(forSlot: Slot) -> Int
        {
        var found = false
        var offset = 0
        self.virtualTableOffset(forSlot: forSlot, offset: &offset, found: &found)
        return(offset)
        }
        
    private func virtualTableOffset(forSlot: Slot,offset: inout Int,found: inout Bool)
        {
        if found
            {
            return
            }
        let slotClass = forSlot.owningClass!
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
        
    public func offsetInObject(ofSlot slot: Slot) -> Int
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
