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

public var classesAreLocked = false
//
//public class Class:ContainerSymbol
//    {
//    public override var argonHash: Int
//        {
//        var hashValue = super.argonHash
//        for slot in self.layoutSlots
//            {
//            hashValue = hashValue << 13 ^ slot.label.polynomialRollingHash
//            }
//        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
//        return(Int(bitPattern: word))
//        }
//        
////    public var localSizeInBytes: Int
////        {
////        self.localSlots.count * Argon.kWordSizeInBytesInt
////        }
//        
//    public var rawPrecedenceList: Classes
//        {
//        var array = TypeClasses()
//        array += [(self.supertype as! TypeClass)]
//        array += (self.supertype as! TypeClass).rawPrecedenceList
//        return(array)
//        }
//        
//    public var allSuperclasses: Classes
//        {
//        var array = [self]
//        array += (self.superclassType as! TypeClass).theClass.allSuperclasses
//        return(array)
//        }
//        
//    public func allSuperclasses(inClass aClass: Class) -> Array<(Int,Class)>
//        {
//        var array = [(0,self)]
//        array += (self.superclassType as! TypeClass).theClass.allSuperclasses(inClass: self)
//        return(array)
//        }
//        
//    public var precedenceList: Classes
//        {
//        var array = [(0,self)]
//        array += (self.superclassType as! TypeClass).theClass.allSuperclasses(inClass: self)
//        var list = Array<(Int,Class)>()
//        for element in array
//            {
//            var found = false
//            for item in list
//                {
//                if item.1 == element.1
//                    {
//                    found = true
//                    break
//                    }
//                }
//            if !found
//                {
//                list.append(element)
//                }
//            }
//        let sorted = list.sorted{"\($0.1.depth).\($0.0)" >= "\($1.1.depth).\($1.0)"}
//        let classes = sorted.map{$0.1}
//        return(classes)
//        }
//        
//    public override var sizeInBytes: Int
//        {
//        ArgonModule.shared.class.instanceSizeInBytes
//        }
////
////    public override var isType: Bool
////        {
////        return(true)
////        }
////
////    public override var isLiteral: Bool
////        {
////        return(true)
////        }
//        
//    public override var classValue: Class
//        {
//        self
//        }
//        
//    public var isValueClass: Bool
//        {
//        false
//        }
//    
//    public static func == (lhs: Class, rhs: Class) -> Bool
//        {
//        return(lhs.index == rhs.index)
//        }
//        
//    public static func <(lhs: Class, rhs: Class) -> Bool
//        {
//        return(lhs.isSubclass(of: rhs))
//        }
//    
//    public static func <=(lhs: Class, rhs: Class) -> Bool
//        {
//        return(lhs.isInclusiveSubclass(of: rhs))
//        }
//        
//    public override func emitCode(using: CodeGenerator) throws
//        {
////        for initializer in self.initializers
////            {
////            try initializer.emitCode(using: using)
////            }
//        }
//
//    public override var isClass: Bool
//        {
//        return(true)
//        }
//        
//    public override var defaultColor: NSColor
//        {
//        Palette.shared.classColor
//        }
//
////    public struct ClassOffset
////        {
////        let theClass:Class
////        let offset:Int
////        }
////
////    public var nativeCType: NativeCType
////        {
////        return(NativeCPointer(target: NativeCType(type: "\(self.label)")))
////        }
////
//    public override var displayString: String
//        {
//        return("Array(\(self.label))")
//        }
//        
////    public var scalarClass: Bool
////        {
////        return(false)
////        }
////
////    public override var allChildren: Symbols
////        {
////        return(self.localSlots.sorted{$0.label<$1.label} + self.subclasses.sorted{$0.label<$1.label})
////        }
//        
////    public var internalClass: Class
////        {
////        return(ArgonModule.shared.class)
////        }
//        
//        
////    public static let number: Class = ArgonModule.shared.lookup(label:"Number") as! Class
//    
//    public var ffiType: ffi_type
//        {
//        return(ffi_type_uint64)
//        }
//        
//    public override var typeCode: TypeCode
//        {
//        switch(self.label)
//            {
//            case "Integer":
//                return(.integer)
//            case "UInteger":
//                return(.uInteger)
//            case "String":
//                return(.string)
//            case "Array":
//                return(.array)
//            case "Class":
//                return(.class)
//            case "Float":
//                return(.float)
//            case "Boolean":
//                return(.boolean)
//            case "Byte":
//                return(.byte)
//            case "Character":
//                return(.character)
//            case "Stream":
//                return(.stream)
//            case "Slot":
//                return(.slot)
//            case "Module":
//                return(.module)
//            case "Tuple":
//                return(.tuple)
//            case "Symbol":
//                return(.symbol)
//            default:
//                return(.other)
//            }
//        }
//        
//    public var isVoidType: Bool
//        {
//        return(false)
//        }
//        
////    public var isClassClass: Bool
////        {
////        return(self.label == "Class")
////        }
//        
////    public var isMetaclassClass: Bool
////        {
////        return(false)
////        }
//        
////    public var isArrayClass: Bool
////        {
////        return(false)
////        }
//        
//    public var isPrimitiveClass: Bool
//        {
//        return(false)
//        }
////
////    public var isObjectClass: Bool
////        {
////        return(true)
////        }
//
//    public var isStringClass: Bool
//        {
//        return(false)
//        }
//        
//    public var isGenericClass: Bool
//        {
//        return(false)
//        }
//        
////    public var containsUninstanciatedParameterics: Bool
////        {
////        return(false)
////        }
//        
////    public var containedClassParameters: Array<GenericType>
////        {
////        return([])
////        }
//        
//    public override var iconName: String
//        {
//        "IconClass"
//        }
//        
//    public override var symbolColor: NSColor
//        {
//        .argonLime
//        }
//        
//    public var laidOutSlots: Array<Slot>
//        {
//        return(self.layoutSlots)
//        }
//        
//    public var mangledName: String
//        {
//        return(self.label)
//        }
//        
//    public var `class`: Class
//        {
//        return(self.metaclass)
//        }
//    
//    public override var isExpandable: Bool
//        {
//        return(self.children.count > 0)
//        }
//        
//    public override var children: Symbols
//        {
//        return(self.localSlots.sorted{$0.label < $1.label} + self.subclasses.sorted{$0.label<$1.label})
//        }
//        
//    public override var childName: (String,String)
//        {
//        return(("item","items"))
//        }
//        
//    public var sizeInWords: Int
//        {
//        self.sizeInBytes / MemoryLayout<Word>.size
//        }
//        
//    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
//        {
//        let count = self.subclasses.count
//        var text = ""
//        if count == 0
//            {
//            }
//        else if count == 1
//            {
//            text = "1 item"
//            }
//        else
//            {
//            text = "\(count) items"
//            }
//        leaderCell.textField?.stringValue = text
//        }
//        
//    public var instanceSizeInBytes: Int
//        {
//        return(self.layoutSlots.count * Argon.kWordSizeInBytesInt)
//        }
//
//    public var localSubclasses: Types
//        {
//        return(self.subclasses)
//        }
//        
//    public var localAndInheritedSlots: Slots
//        {
//        var slots:Slots = []
//        slots += (self.superclassType as! TypeClass).localAndInheritedSlots
//        slots += self.localSlots
//        return(slots.removeDuplicates())
//        }
//        
//    public var localSlots: Slots
//        {
//        return(self.symbols.compactMap{$0 as? Slot}.sorted{$0.label < $1.label})
//        }
//        
////    public var localSystemSlots: Slots
////        {
////        var slots = Array<Slot>()
////        let namePrefix = self.label.lowercasingFirstLetter
////        let header = Slot(label: "_\(namePrefix)Header", type: ArgonModule.shared.integer.type)
////        header.slotType = .header
////        slots.append(header)
////        header.setOffset(0)
////        let slot1 = Slot(label: "_\(namePrefix)MagicNumber", type: ArgonModule.shared.integer.type)
////        slot1.slotType = .magicNumber
////        slots.append(slot1)
////        slot1.setOffset(8)
////        let slot2 = Slot(label: "_\(namePrefix)Class", type: ArgonModule.shared.class.type)
////        slot2.slotType = .class
////        slots.append(slot2)
////        slot2.setOffset(16)
////        return(slots)
////        }
//        
////    public override var weight: Int
////        {
////        1_000
////        }
//        
//    ///
//    ///
//    /// This looks like it doesn't work but the Object class ( the only instance
//    /// of RootClass in the system ) overrides depth to return 1. So this will recurse
//    /// until it hits the RootClass and then unwind with the correct answer. All object
//    /// hierarchies are expected to be rooted in the Object class so it should work for
//    /// all correctly contituted hierarchies. If a hierarchy is NOT rooted in Object for
//    /// some reason the answer will be incorrect.
//    ///
//    /// Because we have multiple inheritance there could be different answers to this query
//    /// depending upon what route is take to get to the RootClass. However this algorithm
//    /// will always take the first route it finds, which will depend on the order in
//    /// which superclasses are added to class. This uses the route recursively defined
//    /// defined by the FIRST superclass.
//    ///
//    ///
//    public var depth: Int
//        {
//        assert(self.superclassType.isNotNil)
//        return(1 + (self.superclassType as! TypeClass).theClass.depth)
//        }
//        
//    public var isRootClass: Bool
//        {
//        return(false)
//        }
//        
//    public var allSubclasses: Types
//        {
//        var list = Types()
//        for aClass in self.subclasses
//            {
//            if !list.contains(aClass)
//                {
//                list.append(aClass)
//                list.append(contentsOf: aClass.allSubclasses)
//                }
//            }
//        return(list.sorted{$0.label<$1.label})
//        }
//
//    internal lazy var metaclass: Type =
//        {
//        let aClass = Metaclass(label: self.label + "Class", class: self)
//        aClass.superclassType = self.superclassType?.metaclass
//        let metaclassType = TypeClass(class: aClass,generics: [])
//        return(metaclassType)
//        }()
//        
////    internal var isForwardReferenced: Bool = false
//    internal var localSystemSlots: Slots!
//    internal var subclasses = Types()
//    internal var superclassType: Type!
//    internal var layoutSlots = Slots()
//    internal var magicNumber:Int
//    internal var hasBytes = false
//    internal var mangledCode: Label
//    internal var objectType: Argon.ObjectType = .custom
//    internal var isInnerClass: Bool = false
//    
//    public required init(label:Label)
//        {
//        self.layoutSlots = Slots()
//        self.magicNumber = label.polynomialRollingHash
//        self.mangledCode = label
//        super.init(label: label)
//        self.type = self.createType()
//        self.addDeclaration(.zero)
//        if classesAreLocked && self.label == "Void"
//            {
//            fatalError()
//            }
//        }
//        
//    public required init?(coder: NSCoder)
//        {
//        print("START DECODE \(Swift.type(of: self))")
//        self.subclasses = coder.decodeObject(forKey: "subclasses") as! Types
//        self.superclassType = coder.decodeObject(forKey: "superclassType") as? Type
//        self.layoutSlots = coder.decodeObject(forKey: "layoutSlots") as! Slots
//        self.magicNumber = coder.decodeInteger(forKey: "magicNumber")
//        self.hasBytes = coder.decodeBool(forKey: "hasBytes")
//        self.mangledCode = coder.decodeObject(forKey: "mangledCode") as! String
//        self.isInnerClass = coder.decodeBool(forKey: "isInnerClass")
//        super.init(coder: coder)
//        self.metaclass = coder.decodeObject(forKey: "metaclass") as! Metaclass
//        self.type = self.createType()
//        print("END DECODE SYMBOL \(self.label)")
//        }
//
//    public override func encode(with coder:NSCoder)
//        {
//        print("ENCODE CLASS \(self.label)")
//        coder.encode(self.subclasses,forKey: "subclasses")
//        coder.encode(self.superclassType,forKey: "superclassType")
//        coder.encode(self.layoutSlots,forKey: "layoutSlots")
//        coder.encode(self.magicNumber,forKey: "magicNumber")
//        coder.encode(self.hasBytes,forKey: "hasBytes")
//        coder.encode(self.metaclass,forKey: "metaclass")
//        coder.encode(self.mangledCode,forKey: "mangledCode")
//        coder.encode(self.isInnerClass,forKey: "isInnerClass")
//        super.encode(with: coder)
//        }
//        
//    internal func createType() -> Type
//        {
//        Argon.addType(TypeClass(class: self,generics: []))
//        }
//        
//    public override func addSymbol(_ symbol: Symbol)
//        {
//        for aSymbol in self.symbols
//            {
//            if aSymbol.label == symbol.label
//                {
//                fatalError()
//                }
//            }
//        super.addSymbol(symbol)
//        }
//        
////    public func initializer(_ primitiveIndex: Int,_ args:[Type])
////        {
////        let initializer = Initializer(label: Argon.nextName("1INIT"))
////        let parameters = args.map{Parameter(label: Argon.nextName("1PARM"),relabel: nil,type: $0,isVisible: false,isVariadic: false)}
////        self.initializers.append(initializer)
////        initializer.declaringType = self.type!
////        initializer.parameters = parameters
////        initializer.block.addBlock(PrimitiveBlock(primitiveIndex: primitiveIndex))
////        }
//        
//    public func addSlot(_ slot: Slot)
//        {
//        self.symbols.append(slot)
//        slot.setContainer(.symbol(self))
//        let getter = SlotGetterMethodInstance(slot: slot,classType: self.type)
//        let setter = SlotSetterMethodInstance(slot: slot,classType: self.type)
//        }
//        
//    public func setType(_ objectType: Argon.ObjectType) -> Class
//        {
//        self.objectType = objectType
//        return(self)
//        }
////
////    public func addInitializer(_ initializer: Initializer)
////        {
////        self.initializers.append(initializer)
////        }
//        
//    public func addSubclass(_ aClass: Class)
//        {
//        if !self.subclasses.contains(aClass.type!)
//            {
//            self.subclasses.append(aClass.type!)
//            }
//        }
//        
//        
//    public override func display(indent: String)
//        {
//        print("\(indent)CLASS \(self.label)")
////        for initter in self.initializers
////            {
////            initter.display(indent: indent + "\t")
////            }
//        }
//        
//    public override func substitute(from substitution: TypeContext.Substitution) -> Self
//        {
//        self
//        }
//        
//    public override func typeCheck() throws
//        {
////        for initializer in self.initializers
////            {
////            try initializer.typeCheck()
////            }
//        }
//        
//   public override func initializeType(inContext context: TypeContext)
//        {
//        for slot in self.localSlots
//            {
//            slot.initializeType(inContext: context)
//            }
//        }
//        
//    public override func analyzeSemantics(using: SemanticAnalyzer)
//        {
//        for slot in self.layoutSlots
//            {
//            slot.analyzeSemantics(using: using)
//            }
//        }
//        
//    private var subclassList: Classes
//        {
//        self.subclasses.map{($0 as! TypeClass).theClass}
//        }
//        
//    internal var classType: Type
//        {
//        self.type!
//        }
//        
//    public func isSubclass(of superclass:Class) -> Bool
//        {
//        if self.fullName == superclass.fullName
//            {
//            return(true)
//            }
//        if self.superclassType.isNil
//            {
//            return(false)
//            }
//        return((self.superclassType as! TypeClass).theClass.isSubclass(of: superclass))
//        }
//
//    public override func isElement(ofType: Group.ElementType) -> Bool
//        {
//        return(ofType == .class)
//        }
//        
//    public func isInclusiveSubclass(of someClass:Class) -> Bool
//        {
//        if self == someClass
//            {
//            return(true)
//            }
//        return((self.superclassType as! TypeClass).theClass.isInclusiveSubclass(of: someClass))
//        }
//        
//    public func inherits(from: Class) -> Bool
//        {
//        self.isInclusiveSubclass(of: from)
//        }
//        
//    public func slotWithLabel(_ label: Label) -> Slot?
//        {
//        for slot in self.localSlots
//            {
//            if slot.label == label
//                {
//                return(slot)
//                }
//            }
//        return(nil)
//        }
//        
//    public override func replacementObject(for archiver: NSKeyedArchiver) -> Any?
//        {
//        return(super.replacementObject(for: archiver))
//        }
//        
//    public override func printContents(_ offset: String = "")
//        {
//        var indent = offset
//        let typeName = Swift.type(of: self)
//        print("\(indent)\(typeName): \(self.label)")
//        print("\(indent)INDEX: \(self.index)")
//        if self.symbols.count > 0
//            {
//            indent += "\t"
//            print("\(indent)\(self.symbols.count) symbols")
//            print("\(indent)============================================")
//            for element in self.symbols
//                {
//                element.printContents(indent)
//                }
//            }
//        }
//        
//    public func mcode(_ code:String) -> Class
//        {
//        self.mangledCode = code
//        return(self)
//        }
//        
//    public func isSuperclass(of subclass:Class) -> Bool
//        {
//        for aClass in self.subclasses
//            {
//            if aClass.fullName == subclass.fullName
//                {
//                return(true)
//                }
//            }
//        return((self.superclassType as! TypeClass).theClass.isSuperclass(of: subclass))
//        }
//
//    public func superclass(_ type:Type) -> Class
//        {
//        self.superclassType = type
//        return(self)
//        }
//        
//    @discardableResult
//    public func hasBytes(_ value:Bool) -> Class
//        {
//        self.hasBytes = value
//        return(self)
//        }
//        
////    private func layoutSlot(atOffset: Int) -> Slot?
////        {
////        for slot in self.layoutSlots
////            {
////            if slot.offset == atOffset
////                {
////                return(slot)
////                }
////            }
////        return(nil)
////        }
//        
////    public func rawDumpFromAddress(_ address:Word)
////        {
////        let pointer = WordPointer(address: address)!
////        let allSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
////        for slot in allSlots
////            {
////            slot.printFormattedSlotContents(base: pointer)
////            }
////        }
//        
////    public override func lookup(label: String) -> Symbol?
////        {
////        for slot in self.layoutSlots
////            {
////            if slot.label == label
////                {
////                return(slot)
////                }
////            }
////        return(super.lookup(label: label))
////        }
////
////    public func localLookup(label: String) -> Symbol?
////        {
////        for slot in self.layoutSlots
////            {
////            if slot.label == label
////                {
////                return(slot)
////                }
////            }
////        return(nil)
////        }
////
////    public func instanciate(withType: Type) -> Type
////        {
////        fatalError("A non parametric class should not be instanciated")
////        }
////
////    public func instanciate(withTypes: Types,reportingContext: Reporter) -> Type
////        {
////        fatalError("A non parametric class should not be instanciated")
////        }
//        
//    public func lookupSlot(label: String) -> Slot?
//        {
//        for slot in self.layoutSlots
//            {
//            if slot.label == label
//                {
//                return(slot)
//                }
//            }
//        return(nil)
//        }
//        
////    public override func layoutInMemory(using allocator: AddressAllocator)
////        {
////        fatalError()
////        }
//        
//    public func layoutInMemory(atAddress: Address,isGenericInstance: Bool,generics: Types,using allocator: AddressAllocator)
//        {
//        guard !self.wasMemoryLayoutDone else
//            {
//            return
//            }
//        self.wasMemoryLayoutDone = true
//        let segment = allocator.segment(for: self.segmentType)
//        let classType = allocator.argonModule.lookup(label: "Class") as! Type
//        let classPointer = ClassBasedPointer(address: atAddress.cleanAddress,type: classType)
//        classPointer.setClass(classType)
//        classPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
//        self.superclassType?.layoutInMemory(using: allocator)
//        classPointer.setAddress(self.superclassType?.memoryAddress ?? 0,atSlot: "superclass")
//        for subtype in self.subclasses
//            {
//            subtype.layoutInMemory(using: allocator)
//            }
//        let subs = self.subclasses.map{$0.memoryAddress}
//        let subSize = max(100,subs.count * 4)
//        let subAddress = segment.allocateArray(size: subSize,elements: subs)
//        classPointer.setAddress(subAddress,atSlot: "subclasses")
//        for slot in self.layoutSlots
//            {
//            slot.memoryAddress = segment.allocateObject(ofType: (allocator.argonModule.lookup(label: "Slot") as! Type),extraSizeInBytes: 0)
//            slot.layoutInMemory(using: allocator)
//            }
//        let slotsArray = segment.allocateArray(size: self.layoutSlots.count,elements: self.layoutSlots.map{$0.memoryAddress})
//        classPointer.setAddress(slotsArray,atSlot: "slots")
//        classPointer.setAddress(self.module!.memoryAddress,atSlot: "container")
//        classPointer.setBoolean(self.isSystemClass,atSlot: "isSystemType")
//        classPointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
//        classPointer.setBoolean(self.isValueClass,atSlot: "isValue")
//        classPointer.setInteger(self.magicNumber,atSlot: "magicNumber")
//        classPointer.setInteger(self.argonHash,atSlot: "hash")
//        classPointer.setBoolean(isGenericInstance,atSlot: "isGenericInstance")
//        classPointer.setBoolean(!isGenericInstance,atSlot: "isArchetype")
//        if generics.isEmpty
//            {
//            classPointer.setAddress(0,atSlot: "typeParameters")
//            }
//        else
//            {
//            if let typesArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: generics.count))
//                {
//                for type in generics
//                    {
//                    type.layoutInMemory(using: allocator)
//                    typesArray.append(type.memoryAddress)
//                    }
//                classPointer.setArrayPointer(typesArray,atSlot: "typeParameters")
//                }
//            }
//        if self.label == "Object"
//            {
//            print("OBJECT CLASS ADDRESS IS \(String(format: "%12X",self.memoryAddress)) \(self.memoryAddress.bitString)")
//            MemoryPointer.dumpMemory(atAddress: atAddress,count: 100)
//            }
//        }
//        
//    internal func layoutBaseSlots(inClass: Class,slotPrefix: String,offset: inout Int)
//        {
//        var systemSlots = Slots()
//        let name1 = slotPrefix.isEmpty ? "header" : "Header"
//        var slot:Slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        inClass.addLayoutSlot(slot)
//        systemSlots.append(slot)
//        offset += Argon.kWordSizeInBytesInt
//        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
//        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        systemSlots.append(slot)
//        inClass.addLayoutSlot(slot)
//        offset += Argon.kWordSizeInBytesInt
//        let name3 = slotPrefix.isEmpty ? "class" : "Class"
//        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: ArgonModule.shared.integer)
//        slot.setOffset(offset)
//        systemSlots.append(slot)
//        inClass.addLayoutSlot(slot)
//        offset += Argon.kWordSizeInBytesInt
//        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
//        }
//        
//    private func addLayoutSlot(_ slot: Slot)
//        {
//        for aSlot in self.layoutSlots
//            {
//            if aSlot.label == slot.label
//                {
//                fatalError()
//                }
//            }
//        self.layoutSlots.append(slot)
//        }
//        
//    public override func layoutObjectSlots()
//        {
//        guard !self.wasSlotLayoutDone else
//            {
//            return
//            }
//        self.wasSlotLayoutDone = true
//        var offset = 0
//        self.layoutBaseSlots(inClass: self,slotPrefix: "",offset: &offset)
//        var visitedClasses = Set<Class>()
//        visitedClasses.insert(self)
//        self.superclassType?.classValue.layoutObjectSlots(inClass: self,offset: &offset,visitedClasses: &visitedClasses)
//        for slot in self.localSlots
//            {
//            if !slot.isVirtual
//                {
//                let clonedSlot = slot.cloned
//                clonedSlot.setOffset(offset)
//                self.addLayoutSlot(clonedSlot)
//                offset += clonedSlot.size
//                }
//            }
//        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
//        print("LAID OUT OBJECT SLOTS FOR \(self.label)")
//        for slot in self.layoutSlots
//            {
//            print("\t\(slot.label)")
//            }
//        }
//        
//    public func layoutObjectSlots(inClass: Class,offset: inout Int,visitedClasses: inout Set<Class>)
//        {
//        guard !visitedClasses.contains(self) else
//            {
//            return
//            }
//        visitedClasses.insert(self)
//        self.layoutBaseSlots(inClass: inClass,slotPrefix: self.label,offset: &offset)
//        self.superclassType?.classValue.layoutObjectSlots(inClass: inClass,offset: &offset,visitedClasses: &visitedClasses)
//        for slot in self.localSlots
//            {
//            if !slot.isVirtual
//                {
//                let clonedSlot = slot.cloned
//                clonedSlot.setOffset(offset)
//                inClass.addLayoutSlot(clonedSlot)
//                offset += clonedSlot.size
//                }
//            }
//        }
//        
//    public override func allocateAddresses(using allocator: AddressAllocator) throws
//        {
//        if self.label == "Module"
//            {
//            print("halt")
//            }
//        guard !self.wasAddressAllocationDone else
//            {
//            return
//            }
//        self.wasAddressAllocationDone = true
////        print("ABOUT TO ALLOCATE ADDRESS FOR CLASS \(self.label), SIZE IN BYTES IS \(self.sizeInBytes)")
////        allocator.allocateAddress(for: self)
////        print("AFTER ALLOCATE ADDRESS FOR CLASS, ADDRESS IS \(self.memoryAddress)")
////        let header = Header(atAddress: self.memoryAddress)
////        print("HEADER SIZE IN WORDS IS \(header.sizeInWords) SHOULD BE \(self.sizeInBytes / 8)")
//        try self.superclassType?.allocateAddresses(using: allocator)
//        for type in self.subclasses
//            {
//            try type.allocateAddresses(using: allocator)
//            }
//        for slot in self.layoutSlots
//            {
//            try slot.allocateAddresses(using: allocator)
//            }
//        }
//        
//    public func printLayout()
//        {
//        print("-------------------------")
//        print("CLASS \(self.fullName.description)")
//        print("")
//        print("SizeInBytes: \(self.sizeInBytes)")
//        print("")
//        let names = self.layoutSlots.sorted(by: {$0.offset < $1.offset}).map{"\($0.label)"}
//        let mappedNames = names.map{"\"\($0)\""}.joined(separator: ",")
//        print("[\(mappedNames)]")
//        print()
//        print("typedef struct _\(self.label)")
//        print("\t{")
//        for name in names
//            {
//            print("\tCWord \(name);")
//            }
//        print("\t}")
//        print("\t\(self.label);")
//        print()
//        print("typedef \(self.label)* \(self.label)Pointer;")
//        var index = 0
//        for slot in self.layoutSlots.sorted(by: {$0.offset < $1.offset})
//            {
//            let indexString = String(format:"%04d",index)
//            let offsetString = String(format:"%06d",slot.offset)
//            print("\(indexString) \(offsetString) \(slot.label)")
//            index += 1
//            }
//        }
//        
//    @discardableResult
//    public func slot(_ slotLabel:Label,_ theClass:Class) -> Class
//        {
//        let slot = InstanceSlot(labeled:slotLabel,ofType:theClass.type!)
//        self.addSymbol(slot)
//        return(self)
//        }
//        
//    @discardableResult
//    public func slot(_ slotLabel:Label,_ type:Type) -> Class
//        {
//        let slot = InstanceSlot(labeled:slotLabel,ofType: type)
//        self.addSymbol(slot)
//        return(self)
//        }
//        
//    @discardableResult
//    public func hiddenSlot(_ slotLabel:Label,_ theClass:Class) -> Class
//        {
//        self.addSymbol(HiddenSlot(label:slotLabel,type:theClass.type))
//        return(self)
//        }
////        
////    @discardableResult
////    public func virtual(_ slotLabel:Label,_ type:Type) -> Class
////        {
////        self.addSymbol(VirtualSlot(label:slotLabel,type: type))
////        return(self)
////        }
//        
//    public func layoutSlot(atLabel:Label) -> Slot?
//        {
//        for slot in self.layoutSlots
//            {
//            if slot.label == atLabel
//                {
//                return(slot)
//                }
//            }
//        return(nil)
//        }
//        
//    public func hasSlot(atLabel:Label) -> Bool
//        {
//        for slot in self.layoutSlots
//            {
//            if slot.label == atLabel
//                {
//                return(true)
//                }
//            }
//        return(false)
//        }
//    }
//
//public typealias Classes = Array<Class>
//
//extension Classes
//    {
//    public static func <=(lhs:Classes,rhs:Classes) -> Bool
//        {
//        if lhs.count != rhs.count
//            {
//            return(false)
//            }
//        for (left,right) in zip(lhs,rhs)
//            {
//            if !(left <= right)
//                {
//                return(false)
//                }
//            }
//        return(true)
//        }
//        
//    public static func <(lhs:Classes,rhs:Classes) -> Bool
//        {
//        if lhs.count != rhs.count
//            {
//            return(false)
//            }
//        for (left,right) in zip(lhs,rhs)
//            {
//            if !(left < right)
//                {
//                return(false)
//                }
//            }
//        return(true)
//        }
//    }
