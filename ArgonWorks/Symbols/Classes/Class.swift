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

public class Class:ContainerSymbol
    {
    public override var argonHash: Int
        {
        var hasher = Hasher()
        hasher.combine(super.argonHash)
        for slot in self.layoutSlots
            {
            hasher.combine(slot.label)
            }
        for type in self.genericTypes
            {
            hasher.combine(type.argonHash)
            }
        let hashValue = hasher.finalize()
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public var genericSourceClass: Class
        {
        return(self)
        }
        
    public override var enclosingClass: Class?
        {
        return(self)
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        return(LiteralExpression(Literal.class(self)))
        }
        
    public var rawPrecedenceList: Classes
        {
        var array = Classes()
        array += self.superclasses.map{($0 as! TypeClass).theClass}
        for superclass in self.superclasses
            {
            array += (superclass as! TypeClass).theClass.rawPrecedenceList
            }
        return(array)
        }
        
    public var allSuperclasses: Classes
        {
        var array = [self]
        for superclass in self.superclasses
            {
            array += (superclass as! TypeClass).theClass.allSuperclasses
            }
        return(array)
        }
        
    public func allSuperclasses(inClass aClass: Class) -> Array<(Int,Class)>
        {
        let index = aClass.superclasses.firstIndex(of: self.type!)!
        var array = [(aClass.superclasses.count - index - 1,self)]
        for superclass in self.superclasses
            {
            array += (superclass as! TypeClass).theClass.allSuperclasses(inClass: self)
            }
        return(array)
        }
        
    public var precedenceList: Classes
        {
        var array = [(0,self)]
        for superclass in self.superclasses
            {
            array += (superclass as! TypeClass).theClass.allSuperclasses(inClass: self)
            }
        var list = Array<(Int,Class)>()
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
        
    public override var sizeInBytes: Int
        {
        ArgonModule.shared.class.instanceSizeInBytes
        }
        
    public override var isType: Bool
        {
        return(true)
        }
        
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public var isSuperclassListEmpty: Bool
        {
        return(self.superclasses.count == 0)
        }
        
    public override var classValue: Class
        {
        self
        }
        
    public var completeName: String
        {
        return(self.label)
        }
        
    public override var canBecomeAClass: Bool
        {
        return(true)
        }
        
    public var isValueClass: Bool
        {
        false
        }
        
    public override var canBecomeAType: Bool
        {
        return(true)
        }
        
    public static var classesByAddress = Dictionary<Word,Class>()
    
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
        
    public override func emitCode(using: CodeGenerator) throws
        {
        for initializer in self.initializers
            {
            try initializer.emitCode(using: using)
            }
        }

    public override var isClass: Bool
        {
        return(true)
        }
        
    public override var defaultColor: NSColor
        {
        Palette.shared.classColor
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
        
    public var nativeCType: NativeCType
        {
        return(NativeCPointer(target: NativeCType(type: "\(self.label)")))
        }
        
    public override var displayString: String
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
        
    public override var allChildren: Symbols
        {
        return(self.localSlots.sorted{$0.label<$1.label} + self.subclasses.sorted{$0.label<$1.label})
        }
        
//    public var internalClass: Class
//        {
//        return(ArgonModule.shared.class)
//        }
        
    public var metaclass: Metaclass?
        {
        if self._metaclass.isNil
            {
            self._metaclass = Metaclass(label: "\(self.label) class",class: self)
            self._metaclass?.setParent(self.parent)
            self._metaclass?.superclasses = self.superclasses.map{($0 as! TypeClass).theClass.metaclass!.type!}
            }
        return(self._metaclass!)
        }
        
//    public static let number: Class = ArgonModule.shared.lookup(label:"Number") as! Class
    
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
        
    public var isGenericClass: Bool
        {
        return(false)
        }
        
    public var containsUninstanciatedParameterics: Bool
        {
        return(false)
        }
        
//    public var containedClassParameters: Array<GenericType>
//        {
//        return([])
//        }
        
    public override var iconName: String
        {
        "IconClass"
        }
        
    public override var symbolColor: NSColor
        {
        .argonLime
        }
        
    public var laidOutSlots: Array<Slot>
        {
        return(self.layoutSlots)
        }
        
    public var mangledName: String
        {
        return(self.label)
        }
        
    public var `class`: Class
        {
        return(self)
        }
    
    public override var isExpandable: Bool
        {
        return(self.children.count > 0)
        }
        
    public override var children: Symbols
        {
        return(self.localSlots.sorted{$0.label < $1.label} + self.subclasses.sorted{$0.label<$1.label})
        }
        
    public override var childName: (String,String)
        {
        return(("item","items"))
        }
        
    public var sizeInWords: Int
        {
        self.sizeInBytes / MemoryLayout<Word>.size
        }
        
    public override func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        let count = self.subclasses.count
        var text = ""
        if count == 0
            {
            }
        else if count == 1
            {
            text = "1 item"
            }
        else
            {
            text = "\(count) items"
            }
        leaderCell.textField?.stringValue = text
        }
        
    public var instanceSizeInBytes: Int
        {
        return(self.layoutSlots.count * Argon.kWordSizeInBytesInt)
        }
        
    public var localSuperclasses: Types
        {
        return(self.superclasses)
        }
        
    public var localSubclasses: Types
        {
        return(self.subclasses)
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
        return(self.symbols.compactMap{$0 as? Slot}.sorted{$0.label < $1.label})
        }
        
//    public var localSystemSlots: Slots
//        {
//        var slots = Array<Slot>()
//        let namePrefix = self.label.lowercasingFirstLetter
//        let header = Slot(label: "_\(namePrefix)Header", type: ArgonModule.shared.integer.type)
//        header.slotType = .header
//        slots.append(header)
//        header.setOffset(0)
//        let slot1 = Slot(label: "_\(namePrefix)MagicNumber", type: ArgonModule.shared.integer.type)
//        slot1.slotType = .magicNumber
//        slots.append(slot1)
//        slot1.setOffset(8)
//        let slot2 = Slot(label: "_\(namePrefix)Class", type: ArgonModule.shared.class.type)
//        slot2.slotType = .class
//        slots.append(slot2)
//        slot2.setOffset(16)
//        return(slots)
//        }
        
    public override var weight: Int
        {
        1_000
        }
        
    ///
    ///
    /// This looks like it doesn't work but the Object class ( the only instance
    /// of RootClass in the system ) overrides depth to return 1. So this will recurse
    /// until it hits the RootClass and then unwind with the correct answer. All object
    /// hierarchies are expected to be rooted in the Object class so it should work for
    /// all correctly contituted hierarchies. If a hierarchy is NOT rooted in Object for
    /// some reason the answer will be incorrect.
    ///
    /// Because we have multiple inheritance there could be different answers to this query
    /// depending upon what route is take to get to the RootClass. However this algorithm
    /// will always take the first route it finds, which will depend on the order in
    /// which superclasses are added to class. This uses the route recursively defined
    /// defined by the FIRST superclass.
    ///
    ///
    public var depth: Int
        {
        assert(!self.superclasses.isEmpty,"Superclasses should not be empty ( except for Object class) and it is empty in \(self.label) class.")
        return(1 + self.superclasses[0].depth)
        }
        
    public var isRootClass: Bool
        {
        return(false)
        }
        
    public var allSubclasses: Types
        {
        var list = Types()
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
        
    internal var isForwardReferenced: Bool = false
    internal var localSystemSlots: Slots!
    internal var subclasses = Types()
    internal var superclasses = Types()
    internal var layoutSlots = Slots()
    internal var magicNumber:Int
    internal var isMemoryPreallocated = false
    internal var hasBytes = false
    internal var _metaclass: Metaclass?
    internal var mangledCode: Label
    internal var initializers = Array<Initializer>()
    internal var objectType: Argon.ObjectType = .custom
    
    public required init(label:Label)
        {
        self.layoutSlots = Slots()
        self.magicNumber = label.polynomialRollingHash
        self.mangledCode = label
        super.init(label: label)
        self.type = self.createType()
        self.addDeclaration(.zero)
        if classesAreLocked && self.label == "Void"
            {
            fatalError()
            }
        }
        
    public required init?(coder: NSCoder)
        {
        print("START DECODE \(Swift.type(of: self))")
        self.subclasses = coder.decodeObject(forKey: "subclasses") as! Types
        self.superclasses = coder.decodeObject(forKey: "superclasses") as! Types
        self.layoutSlots = coder.decodeObject(forKey: "layoutSlots") as! Slots
        self.magicNumber = coder.decodeInteger(forKey: "magicNumber")
        self.isMemoryPreallocated = false
        self.hasBytes = coder.decodeBool(forKey: "hasBytes")
        self._metaclass = coder.decodeObject(forKey: "_metaclass") as? Metaclass
        self.mangledCode = coder.decodeObject(forKey: "mangledCode") as! String
        super.init(coder: coder)
        self.type = self.createType()
        print("END DECODE SYMBOL \(self.label)")
        }

    public override func encode(with coder:NSCoder)
        {
        print("ENCODE CLASS \(self.label)")
        coder.encode(self.subclasses,forKey: "subclasses")
        coder.encode(self.superclasses,forKey: "superclasses")
        coder.encode(self.layoutSlots,forKey: "layoutSlots")
        coder.encode(self.magicNumber,forKey: "magicNumber")
        coder.encode(self.hasBytes,forKey: "hasBytes")
        coder.encode(self._metaclass,forKey: "_metaclass")
        coder.encode(self.mangledCode,forKey: "mangledCode")
        super.encode(with: coder)
        }
        
    internal func createType() -> Type
        {
        TypeClass(class: self,generics: [])
        }
        
    public func initializer(_ primitiveIndex: Int,_ args:[Type])
        {
        let initializer = Initializer(label: Argon.nextName("1INIT"))
        let parameters = args.map{Parameter(label: Argon.nextName("1PARM"),relabel: nil,type: $0,isVisible: false,isVariadic: false)}
        self.initializers.append(initializer)
        initializer.setParent(self)
        initializer.declaringType = self.type!
        initializer.parameters = parameters
        initializer.block.addBlock(PrimitiveBlock(primitiveIndex: primitiveIndex))
        }
        
    public func setType(_ objectType: Argon.ObjectType) -> Class
        {
        self.objectType = objectType
        return(self)
        }
        
    public func addInitializer(_ initializer: Initializer)
        {
        self.initializers.append(initializer)
        initializer.setParent(self)
        }
        
    public func addSubclass(_ aClass: Class)
        {
        if !self.subclasses.contains(aClass.type!)
            {
            self.subclasses.append(aClass.type!)
            }
        if !aClass.superclasses.contains(self.type!)
            {
            aClass.superclasses.append(self.type!)
            }
        }
        
        
    public override func display(indent: String)
        {
        print("\(indent)CLASS \(self.label)")
        for initter in self.initializers
            {
            initter.display(indent: indent + "\t")
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        self
        }
        
    public override func typeCheck() throws
        {
        for initializer in self.initializers
            {
            try initializer.typeCheck()
            }
        }
        
   public override func initializeType(inContext context: TypeContext)
        {
        for slot in self.localSlots
            {
            slot.initializeType(inContext: context)
            }
        }
        
    public override func analyzeSemantics(using: SemanticAnalyzer)
        {
        for slot in self.layoutSlots
            {
            slot.analyzeSemantics(using: using)
            }
        }
        
    private var subclassList: Classes
        {
        self.subclasses.map{($0 as! TypeClass).theClass}
        }
        
    public var genericTypes: Types
        {
        []
        }
        
    internal var classType: Type
        {
        self.type!
        }
        
    public func addSuperclass(_ type: Type)
        {
        if !self.superclasses.contains(type)
            {
            self.superclasses.append(type)
            }
        if !(type as! TypeClass).theClass.subclassList.contains(self)
            {
            (type as! TypeClass).theClass.subclasses.append(self.classType)
            }
        }
        
    public func removeSuperclass(_ type: Type)
        {
        let aClass = (type as! TypeClass).theClass
        self.superclasses.removeAll(where: { type == $0})
        if aClass.subclasses.contains(self.type!)
            {
            aClass.subclasses.removeAll(where: { self == $0})
            }
        }
        
    public func mostSpecificInitializer(forArguments arguments: Arguments,inContext context: TypeContext) -> Initializer?
        {
        let arity = arguments.count
        let types = arguments.map{$0.value.type!}
        var possibles = self.initializers.filter{$0.arity == arity && $0.parameterTypesAreSupertypes(ofTypes: types)}
        if possibles.isEmpty
            {
            return(nil)
            }
        possibles.sort{$0.moreSpecific(than: $1, forTypes: types)}
        return(possibles.last)
        }
        
    public func removeSubclass(_ type: Type)
        {
        let aClass = (type as! TypeClass).theClass
        self.subclasses.removeAll(where: { type == $0})
        if aClass.superclasses.contains(self.type!)
            {
            aClass.superclasses.removeAll(where: { self == $0})
            }
        }
        
    public func isSubclass(of superclass:Class) -> Bool
        {
        if self.fullName == superclass.fullName
            {
            return(true)
            }
        for aClass in self.superclasses
            {
            if aClass.fullName == superclass.fullName
                {
                return(true)
                }
            if (aClass as! TypeClass).theClass.isSubclass(of: superclass)
                {
                return(true)
                }
            }
        return(false)
        }

    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(ofType == .class)
        }
        
    public func isInclusiveSubclass(of someClass:Class) -> Bool
        {
        if self == someClass
            {
            return(true)
            }
        for clazz in self.superclasses
            {
            if (clazz as! TypeClass).theClass.isInclusiveSubclass(of: someClass)
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func inherits(from: Class) -> Bool
        {
        self.isInclusiveSubclass(of: from)
        }
        
    public func slotWithLabel(_ label: Label) -> Slot?
        {
        for slot in self.localSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public override func replacementObject(for archiver: NSKeyedArchiver) -> Any?
        {
        return(super.replacementObject(for: archiver))
        }
        
    public override func printContents(_ offset: String = "")
        {
        var indent = offset
        let typeName = Swift.type(of: self)
        print("\(indent)\(typeName): \(self.label)")
        print("\(indent)INDEX: \(self.index)")
        if self.symbols.count > 0
            {
            indent += "\t"
            print("\(indent)\(self.symbols.count) symbols")
            print("\(indent)============================================")
            for element in self.symbols
                {
                element.printContents(indent)
                }
            }
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
            if aClass.fullName == subclass.fullName
                {
                return(true)
                }
            }
        for aClass in self.superclasses
            {
            if (aClass as! TypeClass).theClass.isSuperclass(of: subclass)
                {
                return(true)
                }
            }
        return(false)
        }

    public func superclass(_ type:Type) -> Class
        {
        self.addSuperclass(type)
        return(self)
        }
        
    @discardableResult
    public func hasBytes(_ value:Bool) -> Class
        {
        self.hasBytes = value
        return(self)
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
        
//    public func rawDumpFromAddress(_ address:Word)
//        {
//        let pointer = WordPointer(address: address)!
//        let allSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
//        for slot in allSlots
//            {
//            slot.printFormattedSlotContents(base: pointer)
//            }
//        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.layoutSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(super.lookup(label: label))
        }
        
    public func localLookup(label: String) -> Symbol?
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
        
    public func instanciate(withType: Type) -> Type
        {
        fatalError("A non parametric class should not be instanciated")
        }
        
    public func instanciate(withTypes: Types,reportingContext: Reporter) -> Type
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
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self)
        let classType = allocator.argonModule.lookup(label: "Class") as! Type
        let classPointer = ClassBasedPointer(address: self.memoryAddress.cleanAddress,type: classType)
        classPointer.setClass(classType)
        classPointer.setStringAddress(segment.allocateString(self.label),atSlot: "name")
        for supertype in self.superclasses
            {
            supertype.layoutInMemory(using: allocator)
            }
        let supers = self.superclasses.map{$0.memoryAddress}
        let superArray = segment.allocateArray(size: supers.count,elements: supers)
        classPointer.setAddress(superArray,atSlot: "superclasses")
        for subtype in self.subclasses
            {
            subtype.layoutInMemory(using: allocator)
            }
        let subs = self.subclasses.map{$0.memoryAddress}
        let subSize = max(100,subs.count * 4)
        let subAddress = segment.allocateArray(size: subSize,elements: subs)
        classPointer.setAddress(subAddress,atSlot: "subclasses")
        for slot in self.layoutSlots
            {
            slot.memoryAddress = segment.allocateObject(ofClass: (allocator.argonModule.lookup(label: "Slot") as! Type),sizeOfExtraBytesInBytes: 0)
            slot.layoutInMemory(using: allocator)
            }
        let slotsArray = segment.allocateArray(size: self.layoutSlots.count,elements: self.layoutSlots.map{$0.memoryAddress})
        classPointer.setAddress(slotsArray,atSlot: "slots")
        classPointer.setAddress(self.parent.memoryAddress,atSlot: "container")
        classPointer.setBoolean(self.isSystemClass,atSlot: "isSystemType")
        classPointer.setInteger(self.instanceSizeInBytes,atSlot: "instanceSizeInBytes")
        classPointer.setBoolean(self.isValueClass,atSlot: "isValue")
        classPointer.setInteger(self.magicNumber,atSlot: "magicNumber")
        classPointer.setInteger(self.argonHash,atSlot: "hash")
        if let typesArray = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.genericTypes.count))
            {
            for type in self.genericTypes
                {
                type.layoutInMemory(using: allocator)
                typesArray.append(type.memoryAddress)
                }
            classPointer.setArrayPointer(typesArray,atSlot: "typeParameters")
            }
        if self.label == "Object"
            {
            print("OBJECT CLASS ADDRESS IS \(String(format: "%12X",self.memoryAddress)) \(self.memoryAddress.bitString)")
            MemoryPointer.dumpMemory(atAddress: self.memoryAddress,count: 100)
            }
        }
        
    internal func layoutBaseSlots(inClass: Class,slotPrefix: String,offset: inout Int,withArgonModule argonModule: ArgonModule)
        {
        var systemSlots = Slots()
        let name1 = slotPrefix.isEmpty ? "header" : "Header"
        var slot:Slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name1)",type: argonModule.integer)
        slot.setOffset(offset)
        slot.setParent(inClass)
        inClass.layoutSlots.append(slot)
        systemSlots.append(slot)
        offset += Argon.kWordSizeInBytesInt
        let name2 = slotPrefix.isEmpty ? "magicNumber" : "MagicNumber"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name2)",type: argonModule.integer)
        slot.setParent(inClass)
        slot.setOffset(offset)
        systemSlots.append(slot)
        inClass.layoutSlots.append(slot)
        offset += Argon.kWordSizeInBytesInt
        let name3 = slotPrefix.isEmpty ? "class" : "Class"
        slot = Slot(label: "_\(slotPrefix.lowercasingFirstLetter)\(name3)",type: argonModule.integer)
        slot.setParent(inClass)
        slot.setOffset(offset)
        systemSlots.append(slot)
        inClass.layoutSlots.append(slot)
        offset += Argon.kWordSizeInBytesInt
        inClass.localSystemSlots = slotPrefix.isEmpty ? systemSlots : inClass.localSystemSlots
        }
        
    public override func layoutObjectSlots(using allocator: AddressAllocator)
        {
        guard !self.wasSlotLayoutDone else
            {
            return
            }
        self.wasSlotLayoutDone = true
        let argonModule = allocator.argonModule
        var offset = 0
        self.layoutBaseSlots(inClass: self,slotPrefix: "",offset: &offset,withArgonModule: argonModule)
        var visitedClasses = Set<Class>()
        visitedClasses.insert(self)
        for type in self.superclasses
            {
            type.classValue.layoutObjectSlots(withArgonModule: argonModule,inClass: self,offset: &offset,visitedClasses: &visitedClasses)
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
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        print("LAID OUT OBJECT SLOTS FOR \(self.label)")
        for slot in self.layoutSlots
            {
            print("\t\(slot.label)")
            }
        }
        
    public func layoutObjectSlots(withArgonModule argonModule: ArgonModule,inClass: Class,offset: inout Int,visitedClasses: inout Set<Class>)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.insert(self)
        self.layoutBaseSlots(inClass: inClass,slotPrefix: self.label,offset: &offset,withArgonModule: argonModule)
        for type in self.superclasses
            {
            type.classValue.layoutObjectSlots(withArgonModule: argonModule,inClass: inClass,offset: &offset,visitedClasses: &visitedClasses)
            }
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                clonedSlot.setParent(self)
                inClass.layoutSlots.append(clonedSlot)
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
        print("ABOUT TO ALLOCATE ADDRESS FOR CLASS \(self.label), SIZE IN BYTES IS \(self.sizeInBytes)")
        allocator.allocateAddress(for: self)
        print("AFTER ALLOCATE ADDRESS FOR CLASS, ADDRESS IS \(self.memoryAddress)")
        let header = Header(atAddress: self.memoryAddress)
        print("HEADER SIZE IN WORDS IS \(header.sizeInWords) SHOULD BE \(self.sizeInBytes / 8)")
        for type in self.superclasses
            {
            try  type.allocateAddresses(using: allocator)
            }
        for type in self.subclasses
            {
            try type.allocateAddresses(using: allocator)
            }
        for slot in self.layoutSlots
            {
            allocator.allocateAddress(for: slot)
            }
        }
        
    public func printLayout()
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
        
    @discardableResult
    public func slot(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        let slot = InstanceSlot(labeled:slotLabel,ofType:theClass.type!)
        self.addSymbol(slot)
        return(self)
        }
        
    @discardableResult
    public func slot(_ slotLabel:Label,_ type:Type) -> Class
        {
        let slot = InstanceSlot(labeled:slotLabel,ofType: type)
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
    public func virtual(_ slotLabel:Label,_ type:Type) -> Class
        {
        self.addSymbol(VirtualSlot(label:slotLabel,type: type))
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
