//
//  Class.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
import SwiftUI
import FFI

public class Class:ContainerSymbol,ObservableObject,Hashable,Displayable
    {
    public static var classesByAddress = Dictionary<Word,Class>()
    
//    public static let `class` = self.topModule.argonModule.class
//    public static let slot = self.topModule.argonModule.slot
    
    public static func == (lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.index == rhs.index)
        }
        
    public static func <(lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.isSubclass(of: rhs))
        }
    
    public static func <=(lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.isInclusiveSubclass(of: rhs))
        }
    ///
    ///
    /// Return the distance between this class and the
    /// Object class in the hieararchy.
    ///
    ///
    public var hierarchicalDepth: Int
        {
        var depth = 0
        var aClass = self
        while aClass != self.topModule.argonModule.object
            {
            depth += 1
            if depth > 2500
                {
                fatalError("Class '\(self.label)' has a depth in excess of 2500 which is likely incorrect, probably because Object is not in it's superclass tree.")
                }
            if aClass.superclasses.count < 1
                {
                break
                }
            aClass = aClass.superclasses.first!
            }
        return(depth)
        }
        
    public override func emitCode(using: CodeGenerator)
        {
        print("NEED TO WRITE OUT CLASS \(self.label)")
        }
        
//    public static var integer: Class = ArgonModule.argonModule.integer
//    public static var boolean: Class = ArgonModule.argonModule.boolean
//    public static var string: Class = ArgonModule.argonModule.string
//    public static var character: Class = ArgonModule.argonModule.character
//    public static var byte: Class = ArgonModule.argonModule.byte
//    public static var array: Class = ArgonModule.argonModule.array
//    public static var dictionary: Class = ArgonModule.argonModule.dictionary
//    public static var instruction: Class = ArgonModule.argonModule.instruction
//    public static var typeClass: Class = ArgonModule.argonModule.typeClass
//    public static var classClass: Class = ArgonModule.argonModule.class
//    public static var collection: Class = ArgonModule.argonModule.collection
//    public static var enumeration: Class = ArgonModule.argonModule.enumeration
    
    public override var isClass: Bool
        {
        return(true)
        }
        
    public var isGenericClassParameter: Bool
        {
        return(false)
        }
        
    public var innerClassPointer: InnerClassPointer
        {
        return(InnerClassPointer(address: self.memoryAddress))
        }
        
    public struct ClassOffset
        {
        let theClass:Class
        let offset:Int
        }
        
    public var parametricClasses: Classes?
        {
        return([])
        }
        
    public var displayString: String
        {
        if self.parametricClasses.isNil || self.parametricClasses!.count == 0
            {
            return("\(self.label)")
            }
        let list = "<" + self.parametricClasses!.map{$0.displayString}.joined(separator: ",") + ">"
        return("\(self.label)\(list)")
        }
        
    public var scalarClass: Bool
        {
        return(false)
        }
        
    public var internalClass: Class
        {
        return(self.topModule.argonModule.class)
        }
        
    public var metaclass: Metaclass?
        {
        if self._metaclass.isNil
            {
            self._metaclass = Metaclass(label: "\(self.label) class",class: self)
            self._metaclass?.setParent(self.parent)
            self._metaclass?.superclasses = self.superclasses.map{$0.metaclass!}
            }
        return(self._metaclass!)
        }
        
//    public static let number: Class = self.topModule.argonModule.lookup(label:"Number") as! Class
    
    public var ffiType: ffi_type
        {
        return(ffi_type_uint64)
        }
        
    public override var typeCode: TypeCode
        {
        switch(self.label)
            {
            case "Integer":
                return(.integer)
            case "UInteger":
                return(.uInteger)
            case "String":
                return(.string)
            case "Array":
                return(.array)
            case "Class":
                return(.class)
            case "Float":
                return(.float)
            case "Boolean":
                return(.boolean)
            case "Byte":
                return(.byte)
            case "Character":
                return(.character)
            case "Stream":
                return(.stream)
            case "Slot":
                return(.slot)
            case "Module":
                return(.module)
            case "Tuple":
                return(.tuple)
            case "Symbol":
                return(.symbol)
            default:
                return(.other)
            }
        }
        
    public var isVoidType: Bool
        {
        return(false)
        }
        
    public override var type:Class
        {
        return(self)
        }
        
    public var isClassClass: Bool
        {
        return(self.label == "Class")
        }
        
    public var isMetaclassClass: Bool
        {
        return(false)
        }
        
    public var isArrayClass: Bool
        {
        return(false)
        }
        
    public var isPrimitiveClass: Bool
        {
        return(false)
        }
        
    public var isObjectClass: Bool
        {
        return(true)
        }

    public var isStringClass: Bool
        {
        return(false)
        }
        
    public var isSystemClass: Bool
        {
        return(false)
        }
        
    public var isGenericClass: Bool
        {
        return(false)
        }
        
    public var containsUninstanciatedParameterics: Bool
        {
        return(false)
        }
        
    public var containedClassParameters: Array<GenericClassParameter>
        {
        return([])
        }
        
    public override var imageName: String
        {
        "IconClass"
        }
        
    public override var symbolColor: NSColor
        {
        .argonLime
        }
        
    public var `class`: Class
        {
        return(self)
        }
    
    public override var children: Symbols
        {
        return(self.symbols.values + self.subclasses.sorted{$0.label<$1.label})
        }
        
    public var sizeInBytes: Int
        {
        self.layoutSlots.count * MemoryLayout<UInt64>.size
        }
        
    public var sizeInWords: Int
        {
        self.sizeInBytes / MemoryLayout<Word>.size
        }
        
    public var localAndInheritedSlots: Slots
        {
        var slots:Slots = []
        for aClass in self.superclasses
            {
            slots += aClass.localAndInheritedSlots
            }
        slots += self.localSlots
        return(slots.removeDuplicates())
        }
        
    public var localSlots: Slots
        {
        return(self.symbols.values.compactMap{$0 as? Slot}.sorted{$0.label < $1.label})
        }
        
    public var localSystemSlots: Slots
        {
        var slots = Array<Slot>()
        let header = HeaderSlot(label: "_\(self.label)Header", type: self.topModule.argonModule.integer.type)
        slots.append(header)
        header.setOffset(0)
        let slot1 = Slot(label: "_\(self.label)MagicNumber", type: self.topModule.argonModule.integer.type)
        slots.append(slot1)
        slot1.setOffset(8)
        let slot2 = ObjectSlot(label: "_\(self.label)Class", type: self.topModule.argonModule.class.type)
        slots.append(slot2)
        slot2.setOffset(16)
        return(slots)
        }
        
    public override var weight: Int
        {
        1_000
        }
        
    public var allSubclasses: Array<Class>
        {
        var list = Array<Class>()
        for aClass in self.subclasses
            {
            if !list.contains(aClass)
                {
                list.append(aClass)
                list.append(contentsOf: aClass.allSubclasses)
                }
            }
        return(list.sorted{$0.label<$1.label})
        }
        
    internal var superclassReferences = Array<ForwardReferenceClass>()
    internal var subclasses = Classes()
    internal var superclasses = Classes()
    internal var layoutSlots: SlotList
    internal var magicNumber:Int
    internal var slotClassType:Slot.Type = Slot.self
    internal var isMemoryPreallocated = false
    internal var header = Header(0)
    internal var hasBytes = false
    internal var _metaclass: Metaclass?
    internal var mangledCode: Label
    internal var offsetOfClass: Dictionary<Class,Int> = [:]
    internal var hasBeenRealized = false
    internal private(set) var depth:Int = -1
    
    public override init(label:Label)
        {
        self.layoutSlots = SlotList()
        self.magicNumber = label.polynomialRollingHash
        self.mangledCode = label
        super.init(label: label)
        self.addDeclaration(.zero)
        self.layoutSlots.parent = self
        }
        
    ///
    ///
    /// Create a deepCopy of the receiver, this is used
    /// when a copy of a class needs to be made for the
    /// purposes of genric instanciation. A deepCopy of the
    /// class is taken then all the references to GenericClassParameters
    /// are replace with the actual classes the copy will need.
    /// The assumption is made that the class has been realized
    /// before the copy is made since the references to the classes
    /// are copied not the classes themselves. We do not deepCopy the
    /// superclasses or subclasses otherwise the entire hierarchy
    /// would end up being copied. Slots are deep copied though
    /// because they are the things affected by the substitutions
    /// that take place.
    ///
    ///
    public func deepCopy() -> Class
        {
        let newClass = Class(label: self.label)
        newClass.subclasses = Array(self.subclasses)
        newClass.superclasses = Array(self.superclasses)
        newClass.layoutSlots = SlotList(self.layoutSlots)
        newClass.magicNumber = self.magicNumber
        newClass.slotClassType = self.slotClassType
        newClass.isMemoryPreallocated = false
        newClass.header = self.header
        newClass.hasBytes = self.hasBytes
        newClass._metaclass = self._metaclass
        newClass.mangledCode = self.mangledCode
        newClass.offsetOfClass = self.offsetOfClass
        newClass.hasBeenRealized = self.hasBeenRealized
        newClass.depth = self.depth
        newClass.source = self.source
        newClass.addresses = self.addresses
        newClass.locations = self.locations
        return(newClass)
        }
        
    public func hash(into hasher:inout Hasher)
        {
        hasher.combine(self.index)
        hasher.combine(self.name)
        hasher.combine(self.label)
        }
        
    public func isSubclass(of superclass:Class) -> Bool
        {
        return(superclass.isSuperclass(of: self))
        }
        
    public func isInclusiveSubclass(of someClass:Class) -> Bool
        {
        print("TESTING WHETHER \(self.label) <= \(someClass.label)")
        if self == someClass
            {
            return(true)
            }
        for clazz in self.superclasses
            {
            if clazz.isInclusiveSubclass(of: someClass)
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func mcode(_ code:String) -> Class
        {
        self.mangledCode = code
        return(self)
        }
        
    public func isSuperclass(of subclass:Class) -> Bool
        {
        for aClass in self.subclasses
            {
            if aClass == subclass
                {
                return(true)
                }
            }
        return(false)
        }
        
    public override func superclass(_ string:String) -> Class
        {
        self.superclassReferences.append(ForwardReferenceClass(name: Name(string)))
        return(self)
        }
        
    public func slotClass(_ aClass:Slot.Type) -> Class
        {
        self.slotClassType = aClass
        return(self)
        }
        
    @discardableResult
    public func hasBytes(_ value:Bool) -> Class
        {
        self.hasBytes = value
        return(self)
        }

    ///
    ///
    /// Make an instance of this class in the specified segment and
    /// return the address of this instance. This is not the same as
    /// laying the class out in memory. Laying the class out in memory
    /// lays out an instance of Class class in memory not an instance
    /// of that class.
    ///
    ///
    public func makeInstance(in vm: VirtualMachine) -> Word
        {
        let instance = InnerInstancePointer.allocateInstance(ofClass: self,in: vm)
        return(instance.address)
        }
    ///
    ///
    /// Layout this class instance in memory. In other words take the Swift Class
    /// object instance and clone it into memory in the Argon RTTI format.
    /// THIS DOES NOT MAKE AN INSTANCE OF THE CLASS FOR THAT USE makeInstance(in:)
    /// THIS MERELY COPIES THIS CLASS INFORMATION INTO Argon RTTI format.
    ///
    ///
    public override func layoutInMemory(in vm: VirtualMachine)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        if !self.isMemoryPreallocated
            {
            let anAddress = vm.managedSegment.allocateObject(sizeInBytes: self.internalClass.sizeInBytes)
            self.addresses.append(.absolute(anAddress))
            }
        else if self.memoryAddress == 0
            {
            fatalError("Memory was preallocated but is nil")
            }
        var array = Words()
        for superclass in self.superclasses
            {
            superclass.layoutInMemory(in: vm)
            array.append(superclass.memoryAddress)
            }
        let pointer = InnerClassPointer(address: self.memoryAddress)
        if !self.isMetaclassClass
            {
            self.metaclass?.layoutInMemory(in: vm)
            pointer.setClass(self.topModule.argonModule.class)
            }
        pointer.setName(self.label,in: vm)
        let slotsArray = InnerArrayPointer.allocate(arraySize: self.layoutSlots.count, elementClass: vm.argonModule.slot,in: vm)
        pointer.slots = slotsArray
        for slot in self.layoutSlots.slots.sorted(by: {$0.offset < $1.offset})
            {
            slot.layoutSymbol(in: vm)
            slotsArray.append(slot.memoryAddress)
            }
        pointer.extraSizeInBytes = 0
        pointer.instanceSizeInBytes = self.sizeInBytes
        pointer.setSlotValue(self.hasBytes,atKey: "hasBytes")
        pointer.setSlotValue(false,atKey: "isValue")
        let superclassArray = InnerArrayPointer.allocate(arraySize: self.superclasses.count,elementClass: vm.argonModule.class,in: vm)
        for aClass in self.superclasses
            {
            superclassArray.append(aClass.memoryAddress)
            }
        pointer.setSlotValue(superclassArray.address,atKey:"superclasses")
        pointer.magicNumber = self.magicNumber
        for superclass in self.superclasses
            {
            pointer.assignSystemSlots(from: superclass)
            }
        self.depth = self.hierarchicalDepth
        self.isMemoryLayoutDone = true
        Self.classesByAddress[self.memoryAddress] = self
        print("LAID OUT CLASS \(self.label) AT ADDRESS \(self.memoryAddress.addressString)")
        print("CLASS \(self.label) MAGIC NUMBER IS \(self.magicNumber)")
        }
        
    public func preallocateMemory(size:Int,in vm: VirtualMachine)
        {
        guard !self.isMemoryPreallocated else
            {
            return
            }
        self.isMemoryPreallocated = true
        let address = vm.managedSegment.allocateObject(sizeInBytes: size)
        self.addresses.append(.absolute(address))
        InnerInstancePointer(address: self.memoryAddress).setClass(self.topModule.argonModule.class)
//        ObjectPointer(address: self.memoryAddress).setWord(self.topModule.argonModule.class.memoryAddress,atSlot:"_classPointer")
        let header = Header(WordPointer(address:self.memoryAddress)!.word(atByteOffset: 0))
        assert(header.sizeInWords == size / 8,"ALLOCATED SIZE DOES NOT EQUAL 512")
        }
        
    private func layoutSlot(atOffset: Int) -> Slot?
        {
        for slot in self.layoutSlots
            {
            if slot.offset == atOffset
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func rawDumpFromAddress(_ address:Word)
        {
        let pointer = WordPointer(address: address)!
        let allSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        for slot in allSlots
            {
            slot.printFormattedSlotContents(base: pointer)
            }
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localAndInheritedSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(super.lookup(label: label))
        }
        
    public func instanciate(withClass: Class) -> Class
        {
        fatalError("A non parametric class should not be instanciated")
        }
        
    public func lookupSlot(label: String) -> Slot?
        {
        for slot in self.localAndInheritedSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func allSuperclasses() -> Array<Class>
        {
        var set = Array<Class>()
        for aClass in self.superclasses
            {
            if !set.contains(aClass)
                {
                set.append(aClass)
                }
            let supers = aClass.allSuperclasses()
            for aSuper in supers
                {
                if !set.contains(aSuper)
                    {
                    set.append(aSuper)
                    }
                }
            }
        return(set)
        }
        
    public func layoutObjectSlots()
        {
        guard !self.isSlotLayoutDone else
            {
            return
            }
        print("LAYING OUT CLASS \(self.label) DIRECTLY")
        var offset:Int = 0
        var visitedClasses = Set<Class>()
        visitedClasses.insert(self)
        var slot:Slot = HeaderSlot(label: "_header",type: self.topModule.argonModule.integer)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        slot = Slot(label: "_magicNumber",type: self.topModule.argonModule.integer)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        slot = ObjectSlot(label: "_classPointer",type: self.topModule.argonModule.address)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        for aClass in self.superclasses
            {
            aClass.layoutObjectSlots(in: self,offset: &offset,visitedClasses: &visitedClasses)
            }
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                clonedSlot.setParent(self)
                self.layoutSlots.append(clonedSlot)
                offset += clonedSlot.size
                }
            }
        self.layoutSlots.slots = self.layoutSlots.slots.sorted{$0.offset < $1.offset}
        self.isSlotLayoutDone = true
        }
        
    public func layoutObjectSlots(in inClass:Class,offset: inout Int,visitedClasses: inout Set<Class>)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.insert(self)
        print("LAYING OUT CLASS \(self.label) INDIRECTLY")
        inClass.offsetOfClass[self] = offset
        var slot:Slot = HeaderSlot(label: "_\(self.label)Header",type: self.topModule.argonModule.integer)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        slot = Slot(label: "_\(self.label)MagicNumber",type: self.topModule.argonModule.integer)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        slot = ObjectSlot(label: "_\(self.label)ClassPointer",type: self.topModule.argonModule.address)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        for aClass in self.superclasses
            {
            aClass.layoutObjectSlots(in: inClass,offset: &offset,visitedClasses: &visitedClasses)
            }
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                if inClass.layoutSlots.slots.map({$0.label}).contains(clonedSlot.label)
                    {
                    print("halt")
                    }
                clonedSlot.setParent(self)
                inClass.layoutSlots.append(clonedSlot)
                offset += clonedSlot.size
                }
            }
        }
        
    public func printLayout()
        {
        print("-------------------------")
        print("CLASS \(self.name.description)")
        print("")
        print("SizeInBytes: \(self.sizeInBytes)")
        print("")
        let names = self.layoutSlots.slots.sorted(by: {$0.offset < $1.offset}).map{"\($0.label)"}
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
        for slot in self.layoutSlots.slots.sorted(by: {$0.offset < $1.offset})
            {
            let indexString = String(format:"%04d",index)
            let offsetString = String(format:"%06d",slot.offset)
            print("\(indexString) \(offsetString) \(slot.label)")
            index += 1
            }
        }
        
    public override func realizeSuperclasses(in vm: VirtualMachine)
        {
        guard !self.hasBeenRealized else
            {
            return
            }
        for reference in self.superclassReferences
            {
            reference.realizeClass(in: vm)
            if let symbol = reference.theClass
                {
                if !self.superclasses.contains(symbol)
                    {
                    self.superclasses.append(symbol)
                    }
                if !symbol.subclasses.contains(self)
                    {
                    symbol.subclasses.append(self)
                    }
                symbol.realizeSuperclasses(in: vm)
                }
            }
        self.superclassReferences = []
        for aClass in self.superclasses
            {
            _ = aClass.metaclass
            }
        self.hasBeenRealized = true
        }
        
    @discardableResult
    public func slot(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        let slot = theClass.slotClassType.init(labeled:slotLabel,ofType:theClass.type)
        self.addSymbol(slot)
        return(self)
        }
        
    @discardableResult
    public func hiddenSlot(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        self.addSymbol(HiddenSlot(label:slotLabel,type:theClass.type))
        return(self)
        }
        
    @discardableResult
    public func virtual(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        self.addSymbol(VirtualSlot(label:slotLabel,type:theClass.type))
        return(self)
        }
        
    public func layoutSlot(atLabel:Label) -> Slot?
        {
        for slot in self.layoutSlots
            {
            if slot.label == atLabel
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func hasSlot(atLabel:Label) -> Bool
        {
        for slot in self.layoutSlots
            {
            if slot.label == atLabel
                {
                return(true)
                }
            }
        return(false)
        }
    }

public typealias Classes = Array<Class>

extension Classes
    {
    public static func <=(lhs:Classes,rhs:Classes) -> Bool
        {
        if lhs.count != rhs.count
            {
            return(false)
            }
        for (left,right) in zip(lhs,rhs)
            {
            if !(left <= right)
                {
                return(false)
                }
            }
        return(true)
        }
        
    public static func <(lhs:Classes,rhs:Classes) -> Bool
        {
        if lhs.count != rhs.count
            {
            return(false)
            }
        for (left,right) in zip(lhs,rhs)
            {
            if !(left < right)
                {
                return(false)
                }
            }
        return(true)
        }
    }
