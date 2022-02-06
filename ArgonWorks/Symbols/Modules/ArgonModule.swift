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
        return(self.lookup(label: "Null") as! Type)
        }
        
    public var number: Type
        {
        return(self.lookup(label: "Number") as! Type)
        }

    public var date: Type
        {
        return(self.lookup(label: "Date") as! Type)
        }
        
    public var time: Type
        {
        return(self.lookup(label: "Time") as! Type)
        }
        
    public var byte: Type
        {
        return(self.lookup(label: "Byte") as! Type)
        }
        
    public var symbol: Type
        {
        return(self.lookup(label: "Symbol") as! Type)
        }
        
    public var void: Type
        {
        return(self.lookup(label: "Void") as! Type)
        }
        
    public var float: Type
        {
        return(self.lookup(label: "Float") as! Type)
        }
        
    public var uInteger: Type
        {
        return(self.lookup(label: "UInteger") as! Type)
        }
        
    public var writeStream: Type
        {
        return(self.lookup(label: "WriteStream") as! Type)
        }
        
    public var boolean: Type
        {
        return(self.lookup(label: "Boolean") as! Type)
        }
        
    public var collection: Type
        {
        return(self.lookup(label: "Collection") as! Type)
        }
        
    public var string: Type
        {
        return(self.lookup(label: "String") as! Type)
        }
        
    public var methodInstance: Type
        {
        return(self.lookup(label: "MethodInstance") as! Type)
        }
        
    public var classType: Type
        {
        return(self.lookup(label: "Class") as! Type)
        }
        
    public var metaclassType: Type
        {
        return(self.lookup(label: "Metaclass") as! Type)
        }
        
    public var array: Type
        {
        return(self.lookup(label: "Array") as! Type)
        }
        
    public var vector: Type
        {
        return(self.lookup(label: "Vector") as! Type)
        }
        
    public var dictionary: Type
        {
        return(self.lookup(label: "Dictionary") as! Type)
        }
        
    public var slot: Type
        {
        return(self.lookup(label: "Slot") as! Type)
        }
        
    public var parameter: Type
        {
        return(self.lookup(label: "Parameter") as! Type)
        }
        
    public var pointer:Type
        {
        return(self.lookup(label: "Pointer") as! Type)
        }
        
    public var object: Type
        {
        return(self.lookup(label: "Object") as! Type)
        }
        
    public var function: Type
        {
        return(self.lookup(label: "Function") as! Type)
        }
        
    public var invokable: Type
        {
        return(self.lookup(label: "Invokable") as! Type)
        }
        
    public var list: Type
        {
        return(self.lookup(label: "List") as! Type)
        }
        
    public var listNode: Type
        {
        return(self.lookup(label: "ListNode") as! Type)
        }
        
    public var typeType: Type
        {
        return(self.lookup(label: "Type") as! Type)
        }
        
    public var block: Type
        {
        return(self.lookup(label: "Block") as! Type)
        }
        
    public var integer: Type
        {
        return(self.lookup(label: "Integer") as! Type)
        }
        
    public var address: Type
        {
        return(self.lookup(label: "Address") as! Type)
        }
        
    public var bucket: Type
        {
        return(self.lookup(label: "Bucket") as! Type)
        }
        
    public var generic: Type
        {
        return(self.lookup(label: "GenericClass") as! Type)
        }
        
    public var genericInstance: Type
        {
        return(self.lookup(label: "GenericClassInstance") as! Type)
        }
        
    public var enumerationCase: Type
        {
        return(self.lookup(label: "EnumerationCase") as! Type)
        }
        
    public var behavior: Type
        {
        return(self.lookup(label: "Behavior") as! Type)
        }
        
    public var tuple: Type
        {
        return(self.lookup(label: "Tuple") as! Type)
        }
        
    public var dateTime: Type
        {
        return(self.lookup(label: "DateTime") as! Type)
        }
        
    public var iterable: Type
        {
        return(self.lookup(label: "Iterable") as! Type)
        }
        
    public var magnitude: Type
        {
        return(self.lookup(label: "Magnitude") as! Type)
        }
        
    public var classParameter: Type
        {
        return(self.lookup(label: "ClassParameter") as! Type)
        }
        
    public var moduleType: Type
        {
        return(self.lookup(label: "Module") as! Type)
        }
        
    public var opcode: Type
        {
        return(self.lookup(label: "Opcode") as! Type)
        }
        
    public var instruction: Type
        {
        return(self.lookup(label: "Instruction") as! Type)
        }
        
    public var closure: Type
        {
        return(self.lookup(label: "Closure") as! Type)
        }
        
    public var character: Type
        {
        return(self.lookup(label: "Character") as! Type)
        }
        
    public var dateComponent: Type
        {
        return(self.lookup(label: "DateComponent") as! Type)
        }
        
    public var timeComponent: Type
        {
        return(self.lookup(label: "TimeComponent") as! Type)
        }
        
    public var variadicParameter: Type
        {
        return(self.lookup(label: "VariadicParameter") as! Type)
        }
        
    public var enumeration: Type
        {
        return(self.lookup(label: "Enumeration") as! Type)
        }
        
    public var treeNode: Type
        {
        return(self.lookup(label: "TreeNode") as! Type)
        }
        
    public var literal: Type
        {
        return(self.lookup(label: "Literal") as! Type)
        }
        
    public var operand: Type
        {
        return(self.lookup(label: "Operand") as! Type)
        }
        
    public var slotType: Type
        {
        return(self.lookup(label: "SlotType") as! Type)
        }
        
    public var set: Type
        {
        return(self.lookup(label: "Set") as! Type)
        }
        
    public var objectClass: Type
        {
        return(self.lookup(label: "ObjectClass") as! Type)
        }
        
    public var instructionBlock: Type
        {
        return(self.lookup(label: "InstructionBlock") as! Type)
        }
        
    public var enumerationCaseInstance: Type
        {
        return(self.lookup(label: "EnumerationCaseInstance") as! Type)
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
        self.initTypes()
        self.initClasses()
        self.initBaseMethods()
        self.initSlots()
        self.initVariables()
        self.layoutObjectSlots()
        self.postProcessTypes()
        self.systemClassNames = self.symbols.compactMap{$0 as? TypeClass}.map{$0.label}
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

    public func addSystemClass(_ aClass: Type)
        {
        aClass.flags([.kSystemTypeFlag])
        self.addSymbol(aClass)
        }
        
    public func addSystemEnumeration(_ anEnum: Type)
        {
        anEnum.flags([.kSystemTypeFlag])
        self.addSymbol((anEnum as! TypeEnumeration).createRawValueMethod())
        self.addSymbol(anEnum)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
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
        self.addSystemClass(TypeClass(label: "Collection").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("f").setType(.collection))
        self.addSystemClass(TypeClass(label: "Array").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("a").setType(.array))
        self.addSystemClass(TypeClass(label: "Magnitude").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.magnitude))
        self.addSystemClass(TypeClass(label: "Number").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.magnitude).setType(.number))
        self.addSystemClass(TypeClass(label: "Integer").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).setType(.integer))
        self.addSystemClass(TypeClass(label: "UInteger").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).mcode("u").setType(.uInteger))
        self.addSystemClass(TypeClass(label: "Boolean").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.boolean))
        self.addSystemClass(TypeClass(label: "String").flags([.kSystemTypeFlag]).superclass(self.object).setType(.string))
        self.addSystemClass(TypeClass(label: "Slot").flags([.kSystemTypeFlag]).superclass(self.object).mcode("l").setType(.slot))
        self.addSystemClass(TypeClass(label: "Iterable").flags([.kSystemTypeFlag]).superclass(self.object).mcode("d"))
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
        self.addSystemClass(TypeClass(label: "ListNode").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("N").setType(.listNode))
        self.addSystemClass(TypeClass(label: "Pointer").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("P").setType(.pointer))
        self.addSystemClass(TypeClass(label: "Set").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("S").setType(.set))
        self.addSystemClass(TypeClass(label: "Vector").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("V").setType(.vector))
        self.addSystemClass(TypeClass(label: "Closure").flags([.kSystemTypeFlag]).superclass(self.invokable).mcode("C").setType(.closure))
        self.addSystemClass(TypeClass(label: "Metaclass").flags([.kSystemTypeFlag]).superclass(self.classType).mcode("t").setType(.metaclass))
        self.addSystemClass(TypeClass(label: "InstructionBlock").flags([.kSystemTypeFlag]).superclass(self.object).mcode("i").setType(.instructionBlock))
        self.addSystemClass(TypeClass(label: "EnumerationCaseInstance").flags([.kSystemTypeFlag]).superclass(self.object).setType(.enumerationCaseInstance))
        self.addSystemEnumeration(TypeEnumeration(label: "Opcode").flags([.kSystemTypeFlag]).cases(Instruction.opcodeLabels).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "TimeComponent").flags([.kSystemTypeFlag]).case("#hours",[self.integer]).case("#minutes",[self.integer]).case("seconds",[self.integer]).case("#milliseconds",[self.integer]).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "DateComponent").flags([.kSystemTypeFlag]).case("#days",[self.integer]).case("#months",[self.integer]).case("years",[self.integer]).case("decades",[self.integer]).setType(.enumeration))
        self.addSystemEnumeration(TypeEnumeration(label: "SlotType").flags([.kSystemTypeFlag]).cases("#instanceSlot","#localSlot","#moduleSlot","#classSlot","#magicNumberSlot","#headerSlot","#virtualReadSlot","#virtualReadWriteSlot","#cocoonSlot").setType(.enumeration))
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
        
    private func initMetatypes(forType: Type)
        {
        guard let typeClass = forType as? TypeClass else
            {
            return
            }
        guard typeClass.type == nil else
            {
            return
            }
        print("CREATING METACLASS FOR \(forType.label)")
        if typeClass.supertype.isNotNil && typeClass.supertype!.type.isNil
            {
            self.initMetatypes(forType: typeClass.supertype!)
            }
        let typeMetaclass = TypeMetaclass(label: typeClass.label + "Class",isSystem: typeClass.isSystemType,generics: typeClass.generics)
        if typeClass.supertype.isNotNil
            {
            typeMetaclass.setSupertype(typeClass.supertype!.type)
            }
        typeMetaclass.flags([.kSystemTypeFlag,.kMetaclassFlag])
        self.addSystemClass(typeMetaclass)
        typeClass.type = typeMetaclass
        typeClass.type.type = self.metaclassType
        for type in typeClass.subtypes
            {
            self.initMetatypes(forType: type)
            }
        }
        
    private func initClasses()
        {
        self.metaclassType.type = self.object
        self.initMetatypes(forType: self.object)
        }
        
    ///
    /// For some types their argonHash will change from when they are first created without slots
    /// until they have their slots added because slots form part of the hash calculation.
    /// Hence these types must only be added to the Argon.typeTable after they have
    /// been finalise.
    ///
    private func postProcessTypes()
        {
        self.dictionary.typeVar("KEY").typeVar("VALUE")
        self.listNode.typeVar("ELEMENT")
        self.pointer.typeVar("ELEMENT")
//        assert(Argon.typeAtKey(self.object.argonHash).isNotNil)
        }
        
    private func initSlots()
        {
        self.array.setHasBytes(true).slot("elements",self.array.of(self.object))
        self.block.slot("count",self.integer).slot("size",self.integer).slot("nextBlock",self.address).setHasBytes(true).slot("startIndex",self.integer).slot("stopIndex",self.integer)
        self.classType.slot("superclass",self.classType).slot("subclasses",self.array.of(self.classType)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer).slot("isArchetype",self.boolean).slot("isGenericInstance",self.boolean)
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
        self.listNode.slot("element",self.object).slot("next",self.listNode).slot("previous",self.listNode)
        self.methodInstance.slot("instructionCount",self.integer).slot("instructionBlock",self.instructionBlock).slot("instructionAddress",self.address)
        self.moduleType.slot("isSystemModule",self.boolean).slot("symbols",self.typeType).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.object.slot("hash",self.integer)
        self.parameter.slot("tag",self.string).slot("retag",self.string).slot("tagIsShown",self.boolean).slot("isVariadic",self.boolean)
        self.list.slot("first",self.listNode).slot("last",self.listNode)
        self.slot.slot("name",self.string).slot("type",self.typeType).slot("offset",self.integer).slot("typeCode",self.integer).slot("container",self.typeType).slot("slotType",self.slotType).slot("symbol",self.symbol)
        self.string.slot("count",self.integer).setHasBytes(true)
        self.tuple.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.treeNode.slot("key",self.string).slot("value",self.object).slot("leftNode",self.treeNode).slot("rightNode",self.treeNode).slot("payload1",self.integer).slot("payload2",self.integer).slot("payload3",self.integer)
        self.typeType.slot("name",self.string).slot("module",self.moduleType).slot("typeParameters",self.array.of(self.typeType)).slot("isSystemType",self.boolean)
        self.vector.slot("block",self.block).slot("blockCount",self.integer)
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
        self.addSymbol(Template("+").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("+").method(self.float,self.float,self.float))
        self.addSymbol(Template("+").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("+").method(self.character,self.character,self.character))
        self.addSymbol(Template("+").method(self.uInteger,self.uInteger,self.uInteger))
        self.addSymbol(Template("+").method(self.string,self.string,self.string))
        
        self.addSymbol(Template("-").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("-").method(self.float,self.float,self.float))
        self.addSymbol(Template("-").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("-").method(self.character,self.character,self.character))
        self.addSymbol(Template("-").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("*").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("*").method(self.float,self.float,self.float))
        self.addSymbol(Template("*").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("*").method(self.character,self.character,self.character))
        self.addSymbol(Template("*").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("/").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("/").method(self.float,self.float,self.float))
        self.addSymbol(Template("/").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("/").method(self.character,self.character,self.character))
        self.addSymbol(Template("/").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("%").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("%").method(self.float,self.float,self.float))
        self.addSymbol(Template("%").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("%").method(self.character,self.character,self.character))
        self.addSymbol(Template("%").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("&").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("&").method(self.float,self.float,self.float))
        self.addSymbol(Template("&").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("&").method(self.character,self.character,self.character))
        self.addSymbol(Template("&").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("|").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("|").method(self.float,self.float,self.float))
        self.addSymbol(Template("|").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("|").method(self.character,self.character,self.character))
        self.addSymbol(Template("|").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("^").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("^").method(self.float,self.float,self.float))
        self.addSymbol(Template("^").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("^").method(self.character,self.character,self.character))
        self.addSymbol(Template("^").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("**").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("**").method(self.float,self.float,self.float))
        self.addSymbol(Template("**").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("**").method(self.character,self.character,self.character))
        self.addSymbol(Template("**").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template("<<").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template("<<").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template("<<").method(self.character,self.character,self.character))
        self.addSymbol(Template("<<").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Template(">>").method(self.integer,self.integer,self.integer))
        self.addSymbol(Template(">>").method(self.byte,self.byte,self.byte))
        self.addSymbol(Template(">>").method(self.character,self.character,self.character))
        self.addSymbol(Template(">>").method(self.uInteger,self.uInteger,self.uInteger))
        
        self.addSymbol(Infix(label: "+=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "-=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "*=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "/=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "%=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "&=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "|=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "^=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: "<<=").double(self.integer, self.integer))
        self.addSymbol(Infix(label: ">>=").double(self.integer, self.integer))
        
        self.addSymbol(Infix(label: "+=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "-=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "*=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "/=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "%=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "&=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "|=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "^=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: "<<=").double(self.uInteger, self.uInteger))
        self.addSymbol(Infix(label: ">>=").double(self.uInteger, self.uInteger))
        
        self.addSymbol(Infix(label: "+=").double(self.float, self.float))
        self.addSymbol(Infix(label: "-=").double(self.float, self.float))
        self.addSymbol(Infix(label: "*=").double(self.float, self.float))
        self.addSymbol(Infix(label: "/=").double(self.float, self.float))
        self.addSymbol(Infix(label: "%=").double(self.float, self.float))
        
        self.addSymbol(Infix(label: "+=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "-=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "*=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "/=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "%=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "&=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "|=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "^=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: "<<=").double(self.byte, self.byte))
        self.addSymbol(Infix(label: ">>=").double(self.byte, self.byte))
        
        self.addSymbol(Inline("class",self.object).returns(self.classType).classMethod())
        self.addSymbol(Inline("address",self.object).returns(self.address).addressMethod())
        
        self.addSymbol(Inline("Float",self.string).returns(self.float).stringToFloatMethod())
        self.addSymbol(Inline("Character",self.string).returns(self.character).stringToCharacterMethod())
        self.addSymbol(Inline("Byte",self.string).returns(self.byte).stringToByteMethod())
        self.addSymbol(Inline("Integer",self.string).returns(self.integer).stringToIntegerMethod())
        self.addSymbol(Inline("UInteger",self.string).returns(self.uInteger).stringToUIntegerMethod())
        
        self.addSymbol(Inline("Float",self.integer).returns(self.float).integerToFloatMethod())
        self.addSymbol(Inline("Character",self.integer).returns(self.character).integerToCharacterMethod())
        self.addSymbol(Inline("Byte",self.integer).returns(self.byte).integerToByteMethod())
        self.addSymbol(Inline("String",self.integer).returns(self.integer).integerToStringMethod())
        self.addSymbol(Inline("UInteger",self.integer).returns(self.uInteger).integerToUIntegerMethod())
        
        self.addSymbol(Inline("String",self.float).returns(self.string).floatToStringMethod())
        self.addSymbol(Inline("Character",self.float).returns(self.character).floatToCharacterMethod())
        self.addSymbol(Inline("Byte",self.float).returns(self.byte).floatToByteMethod())
        self.addSymbol(Inline("Integer",self.float).returns(self.integer).floatToIntegerMethod())
        self.addSymbol(Inline("UInteger",self.float).returns(self.uInteger).floatToUIntegerMethod())
        
        self.addSymbol(Inline("String",self.byte).returns(self.string).byteToStringMethod())
        self.addSymbol(Inline("Character",self.byte).returns(self.character).byteToCharacterMethod())
        self.addSymbol(Inline("Float",self.byte).returns(self.float).byteToFloatMethod())
        self.addSymbol(Inline("Integer",self.byte).returns(self.integer).byteToIntegerMethod())
        self.addSymbol(Inline("UInteger",self.byte).returns(self.uInteger).byteToUIntegerMethod())
        
        self.addSymbol(Inline("String",self.character).returns(self.string).characterToStringMethod())
        self.addSymbol(Inline("Byte",self.character).returns(self.character).characterToByteMethod())
        self.addSymbol(Inline("Float",self.character).returns(self.float).characterToFloatMethod())
        self.addSymbol(Inline("Integer",self.character).returns(self.integer).characterToIntegerMethod())
        self.addSymbol(Inline("UInteger",self.character).returns(self.uInteger).characterToUIntegerMethod())
        
        self.addSymbol(Inline("+",self.date,self.dateComponent).returns(self.date).addDateToDateComponent())
        self.addSymbol(Inline("-",self.date,self.dateComponent).returns(self.date).subDateComponentFromDate())
        self.addSymbol(Inline("+",self.time,self.timeComponent).returns(self.time).addTimeToTimeComponent())
        self.addSymbol(Inline("-",self.time,self.timeComponent).returns(self.time).subTimeComponentFromTime())
        self.addSymbol(Inline("+",self.dateTime,self.dateComponent).returns(self.dateTime).addDateTimeToComponent())
        self.addSymbol(Inline("+",self.dateTime,self.timeComponent).returns(self.dateTime).addDateTimeToComponent())
        self.addSymbol(Inline("-",self.dateTime,self.dateComponent).returns(self.dateTime).subComponentFromDateTime())
        self.addSymbol(Inline("-",self.dateTime,self.timeComponent).returns(self.dateTime).subComponentFromDateTime())
        self.addSymbol(Inline("-",self.date,self.date).returns(self.dateComponent).subDateFromDate())
        self.addSymbol(Inline("-",self.time,self.time).returns(self.timeComponent).subTimeFromTime())
        self.addSymbol(Inline("difference",("between",self.date),("and",self.date),("in",self.dateComponent)).returns(self.dateComponent).differenceBetweenDatesMethod())
        self.addSymbol(Inline("difference",("between",self.time),("and",self.time),("in",self.timeComponent)).returns(self.timeComponent).differenceBetweenDatesMethod())
        
//        let typeVariable = TypeContext.freshTypeVariable(named: "ELEMENT")
//        self.addSymbol(Inline("append",("list",self.list.of(typeVariable)),("element",typeVariable)).listAppendMethod())
        
        self.addSymbol(SlotGetter("date",on: self.dateTime).returns(self.date))
        self.addSymbol(SlotGetter("time",on: self.dateTime).returns(self.time))
        self.addSymbol(SlotSetter("date",on: self.dateTime).value(self.date))
        self.addSymbol(SlotSetter("time",on: self.dateTime).value(self.time))
        self.addSymbol(SlotGetter("characters",on: self.string).returns(self.array.of(self.character)))
        self.addSymbol(SlotGetter("day",on: self.date).returns(self.integer))
        self.addSymbol(SlotGetter("month",on: self.date).returns(self.string))
        self.addSymbol(SlotGetter("monthIndex",on: self.date).returns(self.integer))
        self.addSymbol(SlotGetter("year",on: self.date).returns(self.integer))
        self.addSymbol(SlotSetter("day",on: self.date).value(self.integer))
        self.addSymbol(SlotSetter("monthIndex",on: self.date).value(self.integer))
        self.addSymbol(SlotSetter("year",on: self.date).value(self.integer))
        self.addSymbol(SlotGetter("hour",on: self.time).returns(self.integer))
        self.addSymbol(SlotGetter("minute",on: self.time).returns(self.integer))
        self.addSymbol(SlotGetter("second",on: self.time).returns(self.integer))
        self.addSymbol(SlotGetter("millisecond",on: self.time).returns(self.integer))
        self.addSymbol(SlotSetter("hour",on: self.time).value(self.integer))
        self.addSymbol(SlotSetter("minute",on: self.time).value(self.integer))
        self.addSymbol(SlotSetter("second",on: self.time).value(self.integer))
        self.addSymbol(SlotSetter("millisecond",on: self.time).value(self.integer))
        
        self.addSymbol(PrimitiveMethodInstance.label("today","argument",self.date.type,ret: self.date).prim(200))
        self.addSymbol(PrimitiveMethodInstance.label("now","argument",self.time.type,ret: self.time).prim(201))
        self.addSymbol(PrimitiveMethodInstance.label("now","argument",self.dateTime.type,ret: self.dateTime).prim(202))
        }
        
    public func typevar(_ label: String) -> TypeVariable
        {
        TypeContext.freshTypeVariable(named: label)
        }
        
    public override func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.symbols
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
        for symbol in self.symbols
            {
            if symbol.index == index
                {
                return(symbol)
                }
            }
        return(nil)
        }
    }
