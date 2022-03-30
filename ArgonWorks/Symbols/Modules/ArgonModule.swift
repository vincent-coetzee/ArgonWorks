//
//  ArgonModule.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

///
///
/// The ArgonModule contains all the standard types and methods
/// defined by the Argon language. There is only a single instance
/// of the ArgonModule in any system running Argon, it can be accessed
/// via the accessor variable on the ArgonModule class.
///
///
public class ArgonModule: SystemModule
    {
    public private(set) var systemClassNames: Array<String>!
    
    public static var shared: ArgonModule!
    
    public override var typeCode:TypeCode
        {
        .argonModule
        }
        
    public override var isArgonModule: Bool
        {
        return(true)
        }
        
    public var null: Type
        {
        return(self.lookupType(label:  "Null")!)
        }
        
    public var number: Type
        {
        return(self.lookupType(label:  "Number")!)
        }

    public var date: Type
        {
        return(self.lookupType(label:  "Date")!)
        }
        
    public var time: Type
        {
        return(self.lookupType(label:  "Time")!)
        }
        
    public var byte: Type
        {
        return(self.lookupType(label:  "Byte")!)
        }
        
    public var symbol: Type
        {
        return(self.lookupType(label:  "Symbol")!)
        }
        
    public var void: Type
        {
        return(self.lookupType(label:  "Void")!)
        }
        
    public var float: Type
        {
        return(self.lookupType(label:  "Float")!)
        }
        
    public var uInteger: Type
        {
        return(self.lookupType(label:  "UInteger")!)
        }
        
    public var writeStream: Type
        {
        return(self.lookupType(label:  "WriteStream")!)
        }
        
    public var boolean: Type
        {
        return(self.lookupType(label:  "Boolean")!)
        }
        
    public var collection: Type
        {
        return(self.lookupType(label:  "Collection")!)
        }
        
    public var string: Type
        {
        return(self.lookupType(label:  "String")!)
        }
        
    public var methodInstance: Type
        {
        return(self.lookupType(label:  "MethodInstance")!)
        }
        
    public var classType: Type
        {
        return(self.lookupType(label:  "Class")!)
        }
        
    public var metaclassType: Type
        {
        return(self.lookupType(label:  "Metaclass")!)
        }
        
    public var array: Type
        {
        return(self.lookupType(label:  "Array")!)
        }
        
    public var vector: Type
        {
        return(self.lookupType(label:  "Vector")!)
        }
        
    public var dictionary: Type
        {
        return(self.lookupType(label:  "Dictionary")!)
        }
        
    public var slot: Type
        {
        return(self.lookupType(label:  "Slot")!)
        }
        
    public var parameter: Type
        {
        return(self.lookupType(label:  "Parameter")!)
        }
        
    public var pointer:Type
        {
        return(self.lookupType(label:  "Pointer")!)
        }
        
    public var object: Type
        {
        return(self.lookupType(label:  "Object")!)
        }
        
    public var function: Type
        {
        return(self.lookupType(label:  "Function")!)
        }
        
    public var invokable: Type
        {
        return(self.lookupType(label:  "Invokable")!)
        }
        
    public var list: Type
        {
        return(self.lookupType(label:  "List")!)
        }
        
    public var listNode: Type
        {
        return(self.lookupType(label:  "ListNode")!)
        }
        
    public var typeType: Type
        {
        return(self.lookupType(label:  "Type")!)
        }
        
    public var block: Type
        {
        return(self.lookupType(label:  "Block")!)
        }
        
    public var integer: Type
        {
        return(self.lookupType(label:  "Integer")!)
        }
        
    public var address: Type
        {
        return(self.lookupType(label:  "Address")!)
        }
        
    public var bucket: Type
        {
        return(self.lookupType(label:  "Bucket")!)
        }
        
    public var generic: Type
        {
        return(self.lookupType(label:  "GenericClass")!)
        }
        
    public var genericInstance: Type
        {
        return(self.lookupType(label:  "GenericClassInstance")!)
        }
        
    public var enumerationCase: Type
        {
        return(self.lookupType(label:  "EnumerationCase")!)
        }
        
    public var behavior: Type
        {
        return(self.lookupType(label:  "Behavior")!)
        }
        
    public var tuple: Type
        {
        return(self.lookupType(label:  "Tuple")!)
        }
        
    public var dateTime: Type
        {
        return(self.lookupType(label:  "DateTime")!)
        }
        
    public var iterable: Type
        {
        return(self.lookupType(label:  "Iterable")!)
        }
        
    public var magnitude: Type
        {
        return(self.lookupType(label:  "Magnitude")!)
        }
        
    public var classParameter: Type
        {
        return(self.lookupType(label:  "ClassParameter")!)
        }
        
    public var moduleType: Type
        {
        return(self.lookupType(label:  "Module")!)
        }
        
    public var opcode: Type
        {
        return(self.lookupType(label:  "Opcode")!)
        }
        
    public var instruction: Type
        {
        return(self.lookupType(label:  "Instruction")!)
        }
        
    public var closure: Type
        {
        return(self.lookupType(label:  "Closure")!)
        }
        
    public var character: Type
        {
        return(self.lookupType(label:  "Character")!)
        }
        
    public var dateComponent: Type
        {
        return(self.lookupType(label:  "DateComponent")!)
        }
        
    public var timeComponent: Type
        {
        return(self.lookupType(label:  "TimeComponent")!)
        }
        
    public var variadicParameter: Type
        {
        return(self.lookupType(label:  "VariadicParameter")!)
        }
        
    public var enumeration: Type
        {
        return(self.lookupType(label:  "Enumeration")!)
        }
        
    public var treeNode: Type
        {
        return(self.lookupType(label:  "TreeNode")!)
        }
        
    public var literal: Type
        {
        return(self.lookupType(label:  "Literal")!)
        }
        
    public var operand: Type
        {
        return(self.lookupType(label:  "Operand")!)
        }
        
    public var slotType: Type
        {
        return(self.lookupType(label:  "SlotType")!)
        }
        
    public var set: Type
        {
        return(self.lookupType(label:  "Set")!)
        }
        
    public var objectClass: Type
        {
        return(self.lookupType(label:  "ObjectClass")!)
        }
        
    public var instructionBlock: Type
        {
        return(self.lookupType(label:  "InstructionBlock")!)
        }
        
    public var enumerationCaseInstance: Type
        {
        return(self.lookupType(label:  "EnumerationCaseInstance")!)
        }
        
    public var virtualMachine: TypeClass
        {
        return(self.lookupType(label:  "VirtualMachine") as! TypeClass)
        }
        
    public var segment: TypeClass
        {
        return(self.lookupType(label:  "Segment") as! TypeClass)
        }
        
    public var staticSegment: TypeClass
        {
        return(self.lookupType(label:  "StaticSegment") as! TypeClass)
        }
        
    public var codeSegment: TypeClass
        {
        return(self.lookupType(label:  "CodeSegment") as! TypeClass)
        }
        
    public var managedSegment: TypeClass
        {
        return(self.lookupType(label:  "ManagedSegment") as! TypeClass)
        }
        
    public var stackSegment: TypeClass
        {
        return(self.lookupType(label:  "StackSegment") as! TypeClass)
        }
        
    public var register: TypeClass
        {
        return(self.lookupType(label:  "Register") as! TypeClass)
        }

        
//    private var systemClassInLoadingOrder = Classes()
    private let instanceNumber: Int
        
    public init(instanceNumber: Int)
        {
        self.instanceNumber = instanceNumber
        super.init(label: "Argon")
        }
        
    public func initialize()
        {
        TopModule.shared._argonModule = self
        self.initTypes()
        self.initMetaclasses()
        self.initBaseMethods()
        self.initSlots()
        self.initVariables()
        self.layoutObjectSlots()
        self.postProcessTypes()
        self.systemClassNames = self.allSymbols.compactMap{$0 as? TypeClass}.map{$0.label}
        }
    
    required init?(coder: NSCoder)
        {
        self.instanceNumber = -1
        super.init(coder: coder)
        }
        
     public required init(label: Label)
        {
        self.instanceNumber = -1
        super.init(label: label)
        }

    @discardableResult
    public func addSystemClass(_ aClass: Type) -> TypeClass
        {
        aClass.isSystemType = true
        aClass.flags([.kSystemTypeFlag])
        self.addSymbol(aClass)
        return(aClass as! TypeClass)
        }
        
    public func addSystemEnumeration(_ anEnum: Type)
        {
        anEnum.isSystemType = true
        anEnum.flags([.kSystemTypeFlag])
        self.addSymbol((anEnum as! TypeEnumeration).createRawValueMethod())
        self.addSymbol(anEnum)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        }
        
    public override func lookupType(label: Label) -> Type?
        {
        for symbol in self.allSymbols
            {
            if symbol.label == label,let aSymbol = symbol as? Type
                {
                return(aSymbol)
                }
            }
        return(nil)
        }
        
    private func initTypes()
        {
        self.addSystemClass(TypeClass(label: "Object").flags([.kRootTypeFlag,.kSystemTypeFlag]).mcode("o").setType(.object))
        self.addSystemClass(TypeClass(label: "Bucket").flags([.kSystemTypeFlag]).superclass(self.object).setType(.bucket))
        self.addSystemClass(TypeClass(label: "TreeNode").flags([.kSystemTypeFlag]).superclass(self.object).setType(.treeNode))
        self.addSystemClass(TypeClass(label: "Type").flags([.kSystemTypeFlag]).superclass(self.object).setType(.type))
        self.addSystemClass(TypeClass(label: "Class").flags([.kSystemTypeFlag]).superclass(self.typeType).mcode("c").setType(.class))
        self.addSystemClass(TypeClass(label: "Enumeration").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.typeType).mcode("e").setType(.enumeration))
        self.addSystemClass(TypeClass(label: "EnumerationCase").flags([.kSystemTypeFlag]).superclass(self.object).mcode("q").setType(.enumerationCase))
        self.addSystemClass(TypeClass(label: "Iterable").flags([.kSystemTypeFlag]).superclass(self.object).mcode("d").setType(.iterable))
        self.addSystemClass(TypeClass(label: "Collection").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).superclass(self.iterable).mcode("f").setType(.collection))
        self.addSystemClass(TypeClass(label: "Array").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("a").setType(.array))
        self.addSystemClass(TypeClass(label: "Magnitude").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.magnitude))
        self.addSystemClass(TypeClass(label: "Number").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.magnitude).setType(.number))
        self.addSystemClass(TypeClass(label: "Integer").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).setType(.integer))
        self.addSystemClass(TypeClass(label: "UInteger").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).mcode("u").setType(.uInteger))
        self.addSystemClass(TypeClass(label: "Boolean").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.boolean))
        self.addSystemClass(TypeClass(label: "String").flags([.kSystemTypeFlag]).superclass(self.object).setType(.string))
        self.addSystemClass(TypeClass(label: "Slot").flags([.kSystemTypeFlag]).superclass(self.object).mcode("l").setType(.slot))
        self.addSystemClass(TypeClass(label: "Error").flags([.kSystemTypeFlag]).superclass(self.object).setType(.error))
        self.addSystemClass(TypeClass(label: "Block").flags([.kSystemTypeFlag]).superclass(self.object).setType(.block))
        self.addSystemClass(TypeClass(label: "Index").flags([.kSystemTypeFlag]).superclass(self.object).setType(.index))
        self.addSystemClass(TypeClass(label: "Float").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.number).mcode("f").setType(.float))
        self.addSystemClass(TypeClass(label: "Void").superclass(self.object).mcode("v").setType(.void))
        self.addSystemClass(TypeClass(label: "Character").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.magnitude).mcode("c").setType(.character))
        self.addSystemClass(TypeClass(label: "Time").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.magnitude).mcode("t").setType(.time))
        self.addSystemClass(TypeClass(label: "Date").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.magnitude).mcode("d").setType(.date))
        self.addSystemClass(TypeClass(label: "DateTime").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.date).superclass(self.time).mcode("z").setType(.dateTime))
        self.addSystemClass(TypeClass(label: "Address").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.uInteger).mcode("h").setType(.address))
        self.addSystemClass(TypeClass(label: "Symbol").flags([.kSystemTypeFlag]).superclass(self.string).mcode("x").setType(.symbol))
        self.addSystemClass(TypeClass(label: "Byte").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.magnitude).mcode("b").setType(.byte))
        self.addSystemClass(TypeClass(label: "Tuple").flags([.kSystemTypeFlag]).superclass(self.typeType).mcode("p").setType(.tuple))
        self.addSystemClass(TypeClass(label: "Module").flags([.kSystemTypeFlag]).superclass(self.typeType).setType(.module))
        self.addSystemClass(TypeClass(label: "Parameter").flags([.kSystemTypeFlag]).superclass(self.slot).setType(.parameter))
        self.addSystemClass(TypeClass(label: "Null").flags([.kSystemTypeFlag]).superclass(self.object).mcode("a").setType(.nil))
        self.addSystemClass(TypeClass(label: "Invokable").flags([.kSystemTypeFlag]).superclass(self.object).setType(.invokable))
        self.addSystemClass(TypeClass(label: "Function").flags([.kSystemTypeFlag]).superclass(self.invokable).mcode("f").setType(.function))
        self.addSystemClass(TypeClass(label: "MethodInstance").flags([.kSystemTypeFlag]).superclass(self.invokable).setType(.methodInstance))
        self.addSystemClass(TypeClass(label: "Instruction").flags([.kSystemTypeFlag]).superclass(self.object).setType(.instruction))
        self.addSystemClass(TypeClass(label: "Dictionary").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("j").setType(.dictionary))
        self.addSystemClass(TypeClass(label: "List").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("n").setType(.list))
        self.addSystemClass(TypeClass(label: "ListNode").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("N").setType(.listNode))
        self.addSystemClass(TypeClass(label: "Pointer").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("P").setType(.pointer))
        self.addSystemClass(TypeClass(label: "Set").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("S").setType(.set))
        self.addSystemClass(TypeClass(label: "Vector").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("V").setType(.vector))
        self.addSystemClass(TypeClass(label: "Closure").flags([.kSystemTypeFlag]).superclass(self.invokable).mcode("C").setType(.closure))
        self.addSystemClass(TypeClass(label: "Metaclass").flags([.kSystemTypeFlag]).superclass(self.classType).mcode("t").setType(.metaclass))
        self.addSystemClass(TypeClass(label: "InstructionBlock").flags([.kSystemTypeFlag]).superclass(self.object).mcode("i").setType(.instructionBlock))
        self.addSystemClass(TypeClass(label: "EnumerationCaseInstance").flags([.kSystemTypeFlag]).superclass(self.object).setType(.enumerationCaseInstance))
        self.addSystemClass(TypeClass(label: "VirtualMachine").flags([.kSystemTypeFlag]).superclass(self.object))
        self.addSystemClass(TypeClass(label: "Segment").flags([.kSystemTypeFlag]).superclass(self.object))
        self.addSystemClass(TypeClass(label: "ManagedSegment").flags([.kSystemTypeFlag]).superclass(self.lookupClass(label: "Segment")))
        self.addSystemClass(TypeClass(label: "StackSegment").flags([.kSystemTypeFlag]).superclass(self.lookupClass(label: "Segment")))
        self.addSystemClass(TypeClass(label: "StaticSegment").flags([.kSystemTypeFlag]).superclass(self.lookupClass(label: "Segment")))
        self.addSystemClass(TypeClass(label: "CodeSegment").flags([.kSystemTypeFlag]).superclass(self.lookupClass(label: "Segment")))
        self.addSystemClass(TypeClass(label: "Register").flags([.kSystemTypeFlag]).superclass(self.object))
        let a = self.addClass(TypeClass(label: "ClassA").superclass(self.object).setType(.enumerationCaseInstance))
        let b = self.addClass(TypeClass(label: "ClassB").superclass(a).setType(.enumerationCaseInstance))
        let c = self.addClass(TypeClass(label: "ClassC").superclass(a).setType(.enumerationCaseInstance))
        let d = self.addClass(TypeClass(label: "ClassD").superclass(b).superclass(c).setType(.enumerationCaseInstance))
        let lifeForm = self.addClass(TypeClass(label: "LifeForm").superclass(self.object).setType(.enumerationCaseInstance))
        let sentient = self.addClass(TypeClass(label: "Sentient").superclass(lifeForm).setType(.enumerationCaseInstance))
        let bipedal = self.addClass(TypeClass(label: "Bipedal").superclass(lifeForm).setType(.enumerationCaseInstance))
        let intelligent = self.addClass(TypeClass(label: "Intelligent").superclass(sentient).setType(.enumerationCaseInstance))
        let humanoid = self.addClass(TypeClass(label: "Humanoid").superclass(bipedal).setType(.enumerationCaseInstance))
        self.addClass(TypeClass(label: "Vulcan").superclass(intelligent).superclass(humanoid).setType(.enumerationCaseInstance))
        self.addClass(TypeClass(label: "Human").superclass(humanoid).superclass(intelligent).setType(.enumerationCaseInstance))
        self.addSymbol(TypeClass(label: "ClassE").superclass(d).setType(.enumerationCaseInstance))
        self.addSystemEnumeration(TypeEnumeration(label: "Opcode").flags([.kSystemTypeFlag]).cases(Instruction.opcodeLabels).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "TimeComponent").flags([.kSystemTypeFlag]).case("#hours",[self.integer]).case("#minutes",[self.integer]).case("#seconds",[self.integer]).case("#milliseconds",[self.integer]).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "DateComponent").flags([.kSystemTypeFlag]).case("#days",[self.integer]).case("#months",[self.integer]).case("#years",[self.integer]).case("#decades",[self.integer]).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "SlotType").flags([.kSystemTypeFlag]).cases("#instanceSlot","#localSlot","#moduleSlot","#classSlot","#magicNumberSlot","#headerSlot","#virtualReadSlot","#virtualReadWriteSlot","#cocoonSlot").setType(.enumeration))
        }
        
    private func addClass(_ aClass: Type) -> TypeClass
        {
        self.addSymbol(aClass)
        return(aClass as! TypeClass)
        }
        
    private func initVariables()
        {
        self.addSymbol(GlobalSlot(label:"$userFirstName",type:self.string))
        self.addSymbol(GlobalSlot(label:"$directory",type:self.string))
        self.addSymbol(GlobalSlot(label:"$version",type:self.string))
        self.addSymbol(GlobalSlot(label:"$headless",type:self.boolean))
        self.addSymbol(GlobalSlot(label:"$userLastName",type:self.string))
        self.addSymbol(GlobalSlot(label:"$userName",type:self.string))
        self.addSymbol(GlobalSlot(label:"$userEMailAddress",type:self.string))
        self.addSymbol(GlobalSlot(label:"$hostname",type:self.string))
        self.addSymbol(GlobalSlot(label:"$ipAddress",type:self.string))
        self.addSymbol(GlobalSlot(label:"$ethernetAddress",type:self.string))
        self.addSymbol(GlobalSlot(label:"$gatewayAddress",type:self.string))
        self.addSymbol(GlobalSlot(label:"$userHomeDirectory",type:self.string))
        self.addSymbol(GlobalSlot(label:"$ipAddresses",type:self.array.of(self.string)))
        self.addSymbol(GlobalSlot(label:"$ethernetAddresses",type:self.array.of(self.string)))
        }
        
    private func initMetaclasses()
        {
        let list = self.classes
        for aClass in list
            {
            let metaclass = aClass.makeMetaclass()
            self.addSymbol(metaclass)
            }
        for aClass in list
            {
            aClass.configureMetaclass()
            }
        for aClass in self.enumerations
            {
            aClass.type = self.lookupType(label: "Enumeration")
            }
        }
        
    public func printHierarchy(class aClass: TypeClass,depth:String)
        {
        print("\(depth)\(aClass.label) \(aClass.index)")
        let newDepth = depth + "\t"
        for subclass in aClass.subtypes.compactMap({$0 as? TypeClass})
            {
            self.printHierarchy(class: subclass,depth: newDepth)
            }
        }
        
    ///
    /// For some types their argonHash will change from when they are first created without slots
    /// until they have their slots added because slots form part of the hash calculation.
    /// Hence these types must only be added to the Argon.typeTable after they have
    /// been finalise.
    ///
    private func postProcessTypes()
        {
        self.iterable.typeVar("ELEMENT")
        self.dictionary.typeVar("KEY")
        self.dictionary.typeVar("VALUE")
        self.pointer.typeVar("ELEMENT")
//        assert(Argon.typeAtKey(self.object.argonHash).isNotNil)
        }
        
    private func lookupClass(label: Label) -> TypeClass
        {
        return(self.lookup(label: label) as! TypeClass)
        }
        
    private func initSlots()
        {
        self.array.typeVar("ELEMENT")
        self.array.slot("block",self.block)
        self.block.slot("count",self.integer).slot("size",self.integer).slot("nextBlock",self.address).setHasBytes(true).slot("startIndex",self.integer).slot("stopIndex",self.integer)
        self.classType.slot("superclasses",self.classType).slot("subclasses",self.array.of(self.classType)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer).slot("isArchetype",self.boolean).slot("isGenericInstance",self.boolean)
        self.bucket.slot("nextBucket?",self.bucket).slot("bucketValue",self.object).slot("bucketKey",self.integer)
        self.closure.slot("codeSegment",self.address).slot("initialIP",self.address).slot("localCount",self.integer).slot("contextPointer",self.address)
        self.collection.slot("count",self.integer).slot("size",self.integer).slot("elementType",self.typeType)
        self.date.slot("day",self.integer).slot("month",self.string).slot("monthIndex",self.integer).slot("year",self.integer)
        self.dictionary.slot("rootNode",self.treeNode)
        self.enumeration.slot("rawType",self.typeType).slot("cases",self.array.of(self.enumerationCase))
        self.enumerationCase.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeType)).slot("enumeration",self.enumeration).slot("rawType",self.integer).slot("instanceSizeInBytes",self.integer).slot("index",self.integer)
        self.enumerationCaseInstance.slot("enumeration",self.enumeration).slot("caseIndex",self.integer).slot("associatedValueCount",self.integer)
        self.function.slot("libraryPath",self.string).slot("libraryHandle",self.address).slot("librarySymbol",self.address)
//        self.instruction.slot("opcode",self.opcode).slot("offset",self.integer).slot("operand1",self.operand).slot("operand2",self.operand).slot("result",self.operand)
        self.instructionBlock.slot("count",self.integer).slot("size",self.integer)
        self.invokable.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeType).slot("localSlots",self.array.of(self.slot)).slot("module",self.moduleType)
        let element = self.list.typeVar("ELEMENT")
        self.list.slot("firstNode",self.listNode).slot("lastNode",self.listNode)
        self.listNode.typeVar(element)
        self.listNode.slot("element",element).slot("nextNode",self.listNode).slot("previousNode",self.listNode)
        self.methodInstance.slot("instructionCount",self.integer).slot("instructionBlock",self.instructionBlock).slot("instructionAddress",self.address)
        self.moduleType.slot("isSystemModule",self.boolean).slot("symbols",self.typeType).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.object.slot("hash",self.integer)
        self.parameter.slot("tag",self.string).slot("retag",self.string).slot("tagIsShown",self.boolean).slot("isVariadic",self.boolean)
        self.pointer.slot("address",mandatory:"#address",self.address)
        self.list.slot("first",self.listNode).slot("last",self.listNode)
        self.slot.slot("name",self.string).slot("type",self.typeType).slot("offset",self.integer).slot("typeCode",self.integer).slot("container",self.typeType).slot("slotType",self.slotType).slot("symbol",self.symbol).slot("owningClass",self.classType).slot("vtIndex",self.integer)
        self.string.slot("count",self.integer).slot("block",self.block)
        self.tuple.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.treeNode.slot("key",self.string).slot("value",self.object).slot("leftNode",self.treeNode).slot("rightNode",self.treeNode).slot("payload1",self.integer).slot("payload2",self.integer).slot("payload3",self.integer).slot("height",self.integer)
        self.typeType.slot("name",self.string).slot("module",self.moduleType).slot("typeParameters",self.array.of(self.typeType)).slot("isSystemType",self.boolean)
        self.vector.slot("block",self.block)
        self.virtualMachine.slot("managedSegment",self.managedSegment).slot("staticSegment",self.staticSegment).slot("codeSegment",self.codeSegment).slot("stackSegment",self.stackSegment).slot("registers",self.array.of(self.register))
//        self.lookupClass(label: "ClassE").slot("e1",self.integer).slot("e2",self.integer)
        self.lookupClass(label: "ClassB").slot("b1",self.integer).slot("b2",self.integer)
        self.lookupClass(label: "ClassC").slot("c1",self.integer).slot("c2",self.integer)
        self.lookupClass(label: "ClassD").slot("d1",self.integer).slot("d2",self.integer)
        self.lookupClass(label: "ClassA").slot("a1",self.integer).slot("a2",self.integer)
        }

    private func initBaseMethods()
        {
//        self.addSymbol(Infix(label: "+").triple(self.integer,self.integer,self.integer).prim(100))
//        self.addSymbol(Infix(label: "+").triple(self.uInteger,self.uInteger,self.uInteger).prim(101))
//        self.addSymbol(Infix(label: "+").triple(self.float,self.float,self.float).prim(102))
//        self.addSymbol(Infix(label: "+").triple(self.byte,self.byte,self.byte).prim(103))
//        self.addSymbol(Infix(label: "+").triple(self.character,self.character,self.character).prim(104))
//        self.addSymbol(Infix(label: "+").triple(self.date,self.dateComponent,self.date).prim(105))
//        self.addSymbol(Infix(label: "+").triple(self.time,self.timeComponent,self.time).prim(106))
//        self.addSymbol(Infix(label: "+").triple(self.dateTime,self.dateComponent,self.dateTime).prim(107))
//        self.addSymbol(Infix(label: "+").triple(self.dateTime,self.timeComponent,self.dateTime).prim(108))
//        self.addSymbol(Infix(label: "+").triple(self.string,self.string,self.string).prim(109))
//        
//        self.addSymbol(Infix(label: "-").triple(self.integer,self.integer,self.integer).prim(110))
//        self.addSymbol(Infix(label: "-").triple(self.uInteger,self.uInteger,self.uInteger).prim(111))
//        self.addSymbol(Infix(label: "-").triple(self.float,self.float,self.float).prim(112))
//        self.addSymbol(Infix(label: "-").triple(self.byte,self.byte,self.byte).prim(113))
//        self.addSymbol(Infix(label: "-").triple(self.character,self.character,self.character).prim(114))
//        self.addSymbol(Infix(label: "-").triple(self.date,self.dateComponent,self.date).prim(115))
//        self.addSymbol(Infix(label: "-").triple(self.time,self.timeComponent,self.time).prim(116))
//        self.addSymbol(Infix(label: "-").triple(self.dateTime,self.dateComponent,self.dateTime).prim(117))
//        self.addSymbol(Infix(label: "-").triple(self.dateTime,self.timeComponent,self.dateTime).prim(118))
//        
//        self.addSymbol(Infix(label: "*").triple(self.integer,self.integer,self.integer).prim(119))
//        self.addSymbol(Infix(label: "*").triple(self.uInteger,self.uInteger,self.uInteger).prim(120))
//        self.addSymbol(Infix(label: "*").triple(self.float,self.float,self.float).prim(121))
//        self.addSymbol(Infix(label: "*").triple(self.byte,self.byte,self.byte).prim(122))
//        self.addSymbol(Infix(label: "*").triple(self.character,self.character,self.character).prim(123))
//        
//        self.addSymbol(Infix(label: "/").triple(self.integer,self.integer,self.integer).prim(124))
//        self.addSymbol(Infix(label: "/").triple(self.uInteger,self.uInteger,self.uInteger).prim(125))
//        self.addSymbol(Infix(label: "/").triple(self.float,self.float,self.float).prim(126))
//        self.addSymbol(Infix(label: "/").triple(self.byte,self.byte,self.byte).prim(127))
//        self.addSymbol(Infix(label: "/").triple(self.character,self.character,self.character).prim(128))
//        
//        self.addSymbol(Infix(label: "%").triple(self.integer,self.integer,self.integer).prim(129))
//        self.addSymbol(Infix(label: "%").triple(self.uInteger,self.uInteger,self.uInteger).prim(130))
//        self.addSymbol(Infix(label: "%").triple(self.float,self.float,self.float).prim(131))
//        self.addSymbol(Infix(label: "%").triple(self.byte,self.byte,self.byte).prim(132))
//        self.addSymbol(Infix(label: "%").triple(self.character,self.character,self.character).prim(133))
//        
//        self.addSymbol(Infix(label: "**").triple(self.integer,self.integer,self.integer).prim(134))
//        self.addSymbol(Infix(label: "**").triple(self.uInteger,self.uInteger,self.uInteger).prim(135))
//        self.addSymbol(Infix(label: "**").triple(self.float,self.float,self.float).prim(136))
//        self.addSymbol(Infix(label: "**").triple(self.byte,self.byte,self.byte).prim(137))
//        self.addSymbol(Infix(label: "**").triple(self.character,self.character,self.character).prim(138))
//        
//        self.addSymbol(Infix(label: "*=").triple(self.integer,self.integer,self.integer).prim(139))
//        self.addSymbol(Infix(label: "*=").triple(self.uInteger,self.uInteger,self.uInteger).prim(140))
//        self.addSymbol(Infix(label: "*=").triple(self.float,self.float,self.float).prim(141))
//        self.addSymbol(Infix(label: "*=").triple(self.byte,self.byte,self.byte).prim(142))
//        self.addSymbol(Infix(label: "*=").triple(self.character,self.character,self.character).prim(143))
//        
//        self.addSymbol(Infix(label: "+=").triple(self.integer,self.integer,self.integer).prim(144))
//        self.addSymbol(Infix(label: "+=").triple(self.uInteger,self.uInteger,self.uInteger).prim(145))
//        self.addSymbol(Infix(label: "+=").triple(self.float,self.float,self.float).prim(146))
//        self.addSymbol(Infix(label: "+=").triple(self.byte,self.byte,self.byte).prim(147))
//        self.addSymbol(Infix(label: "+=").triple(self.character,self.character,self.character).prim(148))
//        
//        self.addSymbol(Infix(label: "-=").triple(self.integer,self.integer,self.integer).prim(149))
//        self.addSymbol(Infix(label: "-=").triple(self.uInteger,self.uInteger,self.uInteger).prim(150))
//        self.addSymbol(Infix(label: "-=").triple(self.float,self.float,self.float).prim(151))
//        self.addSymbol(Infix(label: "-=").triple(self.byte,self.byte,self.byte).prim(152))
//        self.addSymbol(Infix(label: "-=").triple(self.character,self.character,self.character).prim(153))
//        
//        self.addSymbol(Infix(label: "/=").triple(self.integer,self.integer,self.integer).prim(154))
//        self.addSymbol(Infix(label: "/=").triple(self.uInteger,self.uInteger,self.uInteger).prim(155))
//        self.addSymbol(Infix(label: "/=").triple(self.float,self.float,self.float).prim(156))
//        self.addSymbol(Infix(label: "/=").triple(self.byte,self.byte,self.byte).prim(157))
//        self.addSymbol(Infix(label: "/=").triple(self.character,self.character,self.character).prim(158))
//        
//        self.addSymbol(Infix(label: "%=").triple(self.integer,self.integer,self.integer).prim(159))
//        self.addSymbol(Infix(label: "%=").triple(self.uInteger,self.uInteger,self.uInteger).prim(160))
//        self.addSymbol(Infix(label: "%=").triple(self.float,self.float,self.float).prim(161))
//        self.addSymbol(Infix(label: "%=").triple(self.byte,self.byte,self.byte).prim(162))
//        self.addSymbol(Infix(label: "%=").triple(self.character,self.character,self.character).prim(163))
//        
//        self.addSymbol(Infix(label: "|=").triple(self.integer,self.integer,self.integer).prim(165))
//        self.addSymbol(Infix(label: "|=").triple(self.uInteger,self.uInteger,self.uInteger).prim(166))
//        self.addSymbol(Infix(label: "|=").triple(self.float,self.float,self.float).prim(167))
//        self.addSymbol(Infix(label: "|=").triple(self.byte,self.byte,self.byte).prim(168))
//        self.addSymbol(Infix(label: "|=").triple(self.character,self.character,self.character).prim(169))
//        
//        self.addSymbol(Infix(label: "&=").triple(self.integer,self.integer,self.integer).prim(170))
//        self.addSymbol(Infix(label: "&=").triple(self.uInteger,self.uInteger,self.uInteger).prim(171))
//        self.addSymbol(Infix(label: "&=").triple(self.float,self.float,self.float).prim(172))
//        self.addSymbol(Infix(label: "&=").triple(self.byte,self.byte,self.byte).prim(173))
//        self.addSymbol(Infix(label: "&=").triple(self.character,self.character,self.character).prim(174))
//        
//        self.addSymbol(Infix(label: "^=").triple(self.integer,self.integer,self.integer).prim(175))
//        self.addSymbol(Infix(label: "^=").triple(self.uInteger,self.uInteger,self.uInteger).prim(176))
//        self.addSymbol(Infix(label: "^=").triple(self.float,self.float,self.float).prim(177))
//        self.addSymbol(Infix(label: "^=").triple(self.byte,self.byte,self.byte).prim(178))
//        self.addSymbol(Infix(label: "^=").triple(self.character,self.character,self.character).prim(179))
//        
//        self.addSymbol(Infix(label: "~=").triple(self.integer,self.integer,self.integer).prim(180))
//        self.addSymbol(Infix(label: "~=").triple(self.uInteger,self.uInteger,self.uInteger).prim(181))
//        self.addSymbol(Infix(label: "~=").triple(self.float,self.float,self.float).prim(182))
//        self.addSymbol(Infix(label: "~=").triple(self.byte,self.byte,self.byte).prim(183))
//        self.addSymbol(Infix(label: "~=").triple(self.character,self.character,self.character).prim(184))
//        
//        self.addSymbol(Infix(label: "&&").triple(self.boolean,self.boolean,self.boolean).prim(184))
//        
//        self.addSymbol(Infix(label: "+=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)).prim(108))
//        self.addSymbol(Infix(label: "-=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)).prim(109))
//        self.addSymbol(Infix(label: "*=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)).prim(110))
//        self.addSymbol(Infix(label: "/=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)).prim(111))
//        self.addSymbol(Infix(label: "%=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)).prim(112))
//        
//        self.addSymbol(Infix(label: "==").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(113))
//        self.addSymbol(Infix(label: "!=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(114))
//        self.addSymbol(Infix(label: "<=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(115))
//        self.addSymbol(Infix(label: ">=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(116))
//        self.addSymbol(Infix(label: ">").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(117))
//        self.addSymbol(Infix(label: "<").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)).prim(118))
//        
//        self.addSymbol(Infix(label: "&&").triple(self,.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)).prim(119))
//        self.addSymbol(Infix(label: "||").triple(self,.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)).prim(120))
//    
//        self.addSymbol(Infix(label: "&").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)).prim(121))
//        self.addSymbol(Infix(label: "|").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)).prim(122))
//        self.addSymbol(Infix(label: "^").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)).prim(123))
//        
//        self.addSymbol(Prefix(label: "!").double(self,.generic("number"),.generic("number"),where: ("number",self.number)).prim(124))
//        self.addSymbol(Prefix(label: "-").double(self,.generic("number"),.generic("number"),where: ("number",self.number)).prim(125))
//        self.addSymbol(Prefix(label: "~").double(self,.generic("number"),.generic("number"),where: ("number",self.number)).prim(126))
//        
//        self.addSymbol(Postfix(label: "++").double(self,.generic("number"),.void,where: ("number",self.number)).prim(127))
//        self.addSymbol(Postfix(label: "--").double(self,.generic("number"),.void),where: ("number",self.number)).prim(128))
//
        let var1 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("+=",.byReference(var1),.byValue(var1),self.void).inline().where(.in(var1,[self.integer,self.float,self.uInteger,self.character,self.byte])))
        let var2 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("-=",.byReference(var2),.byValue(var2),self.void).inline().where(.in(var2,[self.integer,self.float,self.uInteger,self.character,self.byte])))
        let var3 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("*=",.byReference(var3),.byValue(var3),self.void).inline().where(.in(var3,[self.integer,self.float,self.uInteger,self.character,self.byte])))
        let var4 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("/=",.byReference(var4),.byValue(var4),self.void).inline().where(.in(var4,[self.integer,self.float,self.uInteger,self.character,self.byte])))
        let var5 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("&=",.byReference(var5),.byValue(var5),self.void).inline().where(.in(var5,[self.integer,self.uInteger,self.character,self.byte])))
        let var6 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("|=",.byReference(var6),.byValue(var6),self.void).inline().where(.in(var6,[self.integer,self.uInteger,self.character,self.byte])))
        let var7 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("^=",.byReference(var7),.byValue(var7),self.void).inline().where(.in(var7,[self.integer,self.uInteger,self.character,self.byte])))
        let var8 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("~=",.byReference(var8),.byValue(var8),self.void).inline().where(.in(var8,[self.integer,self.uInteger,self.character,self.byte])))
        let var9 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.postfix("++",.byReference(var9),self.void).inline().where(.in(var9,[self.integer,self.uInteger,self.character,self.byte])))
        let var10 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.postfix("--",.byReference(var10),self.void).inline().where(.in(var10,[self.integer,self.uInteger,self.character,self.byte])))
        let var11 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("<<=",.byReference(var11),.byValue(var11),self.void).inline().where(.in(var11,[self.integer,self.uInteger,self.character,self.byte])))
        let var12 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix(">>=",.byReference(var12),.byValue(var12),self.void).inline().where(.in(var12,[self.integer,self.uInteger,self.character,self.byte])))
        let var13 = TypeContext.freshTypeVariable(named: "number")
        self.addMethodInstance(Operator.infix("%=",.byReference(var13),.byValue(var13),self.void).inline().where(.in(var8,[self.integer,self.float,self.uInteger,self.character,self.byte])))
        
        self.addMethodInstance(Inline("class",self.object).returns(self.classType).classMethod())
        self.addMethodInstance(Inline("address",("of",self.object)).returns(self.address).addressMethod())
        
        self.addMethodInstance(Inline("Float",self.string).returns(self.float).stringToFloatMethod())
        self.addMethodInstance(Inline("Character",self.string).returns(self.character).stringToCharacterMethod())
        self.addMethodInstance(Inline("Byte",self.string).returns(self.byte).stringToByteMethod())
        self.addMethodInstance(Inline("Integer",self.string).returns(self.integer).stringToIntegerMethod())
        self.addMethodInstance(Inline("UInteger",self.string).returns(self.uInteger).stringToUIntegerMethod())
        
        self.addMethodInstance(Inline("Float",self.integer).returns(self.float).integerToFloatMethod())
        self.addMethodInstance(Inline("Character",self.integer).returns(self.character).integerToCharacterMethod())
        self.addMethodInstance(Inline("Byte",self.integer).returns(self.byte).integerToByteMethod())
        self.addMethodInstance(Inline("String",self.integer).returns(self.integer).integerToStringMethod())
        self.addMethodInstance(Inline("UInteger",self.integer).returns(self.uInteger).integerToUIntegerMethod())
        
        self.addMethodInstance(Inline("String",self.float).returns(self.string).floatToStringMethod())
        self.addMethodInstance(Inline("Character",self.float).returns(self.character).floatToCharacterMethod())
        self.addMethodInstance(Inline("Byte",self.float).returns(self.byte).floatToByteMethod())
        self.addMethodInstance(Inline("Integer",self.float).returns(self.integer).floatToIntegerMethod())
        self.addMethodInstance(Inline("UInteger",self.float).returns(self.uInteger).floatToUIntegerMethod())
        
        self.addMethodInstance(Inline("String",self.byte).returns(self.string).byteToStringMethod())
        self.addMethodInstance(Inline("Character",self.byte).returns(self.character).byteToCharacterMethod())
        self.addMethodInstance(Inline("Float",self.byte).returns(self.float).byteToFloatMethod())
        self.addMethodInstance(Inline("Integer",self.byte).returns(self.integer).byteToIntegerMethod())
        self.addMethodInstance(Inline("UInteger",self.byte).returns(self.uInteger).byteToUIntegerMethod())
        
        self.addMethodInstance(Inline("String",self.character).returns(self.string).characterToStringMethod())
        self.addMethodInstance(Inline("Byte",self.character).returns(self.character).characterToByteMethod())
        self.addMethodInstance(Inline("Float",self.character).returns(self.float).characterToFloatMethod())
        self.addMethodInstance(Inline("Integer",self.character).returns(self.integer).characterToIntegerMethod())
        self.addMethodInstance(Inline("UInteger",self.character).returns(self.uInteger).characterToUIntegerMethod())
        
        self.addMethodInstance(Inline("+",self.date,self.dateComponent).returns(self.date).addDateToDateComponent())
        self.addMethodInstance(Inline("-",self.date,self.dateComponent).returns(self.date).subDateComponentFromDate())
        self.addMethodInstance(Inline("+",self.time,self.timeComponent).returns(self.time).addTimeToTimeComponent())
        self.addMethodInstance(Inline("-",self.time,self.timeComponent).returns(self.time).subTimeComponentFromTime())
        self.addMethodInstance(Inline("+",self.dateTime,self.dateComponent).returns(self.dateTime).addDateTimeToComponent())
        self.addMethodInstance(Inline("+",self.dateTime,self.timeComponent).returns(self.dateTime).addDateTimeToComponent())
        self.addMethodInstance(Inline("-",self.dateTime,self.dateComponent).returns(self.dateTime).subComponentFromDateTime())
        self.addMethodInstance(Inline("-",self.dateTime,self.timeComponent).returns(self.dateTime).subComponentFromDateTime())
        self.addMethodInstance(Inline("-",self.date,self.date).returns(self.dateComponent).subDateFromDate())
        self.addMethodInstance(Inline("-",self.time,self.time).returns(self.timeComponent).subTimeFromTime())
        self.addMethodInstance(Inline("difference",("between",self.date),("and",self.date),("in",self.dateComponent)).returns(self.dateComponent).differenceBetweenDatesMethod())
        self.addMethodInstance(Inline("difference",("between",self.time),("and",self.time),("in",self.timeComponent)).returns(self.timeComponent).differenceBetweenTimesMethod())
        
//        let typeVariable = TypeContext.freshTypeVariable(named: "ELEMENT")
//        self.addMethodInstance(Inline("append",("list",self.list.of(typeVariable)),("element",typeVariable)).listAppendMethod())
        
        self.addMethodInstance(SlotGetter("date",on: self.dateTime).returns(self.date))
        self.addMethodInstance(SlotGetter("time",on: self.dateTime).returns(self.time))
        self.addMethodInstance(SlotGetter("characters",on: self.string).returns(self.array.of(self.character)))
        self.addMethodInstance(SlotGetter("day",on: self.date).returns(self.integer))
        self.addMethodInstance(SlotGetter("month",on: self.date).returns(self.string))
        self.addMethodInstance(SlotGetter("monthIndex",on: self.date).returns(self.integer))
        self.addMethodInstance(SlotGetter("year",on: self.date).returns(self.integer))
        self.addMethodInstance(SlotGetter("hour",on: self.time).returns(self.integer))
        self.addMethodInstance(SlotGetter("minute",on: self.time).returns(self.integer))
        self.addMethodInstance(SlotGetter("second",on: self.time).returns(self.integer))
        self.addMethodInstance(SlotGetter("millisecond",on: self.time).returns(self.integer))
        
        self.addMethodInstance(PrimitiveMethodInstance.label("today","argument",self.date.type,ret: self.date).prim(200))
        self.addMethodInstance(PrimitiveMethodInstance.label("now","argument",self.time.type,ret: self.time).prim(201))
        self.addMethodInstance(PrimitiveMethodInstance.label("now","argument",self.dateTime.type,ret: self.dateTime).prim(202))
        }
        
    private func lookup(_ label: String) -> Symbol?
        {
        for symbol in self.allSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public func addMethodInstance(_ instance: MethodInstance)
        {
        instance.isSystemType = true
        if let method = self.lookupMethod(label:instance.label)
            {
            method.isSystemType = true
            method.addMethodInstance(instance)
            return
            }
        let method = Method(label: instance.label)
        self.addSymbol(method)
        method.addMethodInstance(instance)
        }
        
    public func typevar(_ label: String) -> TypeVariable
        {
        TypeContext.freshTypeVariable(named: label)
        }
        
    public override func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.allSymbols
            {
            if symbol.label == label
                {
                found.append(symbol)
                }
            }
        return(found.isEmpty ? nil : found)
        }
        
    public func lookup(index: IdentityKey) -> Symbol?
        {
        for symbol in self.allSymbols
            {
            if symbol.index == index
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public override func lookupMethod(label: Label) -> ArgonWorks.Method?
        {
        for symbol in self.allSymbols
            {
            if symbol.isMethod && symbol.label == label
                {
                return(symbol as? ArgonWorks.Method)
                }
            }
        return(nil)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.allSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(nil)
        }
    }
