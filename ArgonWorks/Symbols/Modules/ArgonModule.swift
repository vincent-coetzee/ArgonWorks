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
    public static var shared: ArgonModule!
    
    public override var typeCode:TypeCode
        {
        .argonModule
        }
        
    public override var isArgonModule: Bool
        {
        return(true)
        }
        
    public var nilClass: Type
        {
        return(self.lookup(label: "Nil") as! Type)
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
        
    public var `class`: Type
        {
        return(self.lookup(label: "Class") as! Type)
        }
        
    public var metatype: Type
        {
        return(self.lookup(label: "Metatype") as! Type)
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
        
    public var typeClass: Type
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
        
    public var dictionaryBucket: Type
        {
        return(self.lookup(label: "DictionaryBucket") as! Type)
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
        
    public var variadicParameter: Type
        {
        return(self.lookup(label: "VariadicParameter") as! Type)
        }
        
    public var enumeration: Type
        {
        return(self.lookup(label: "Enumeration") as! Type)
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
        
//    private var systemClassInLoadingOrder = Classes()
    private let instanceNumber: Int
        
    public init(instanceNumber: Int)
        {
        self.instanceNumber = instanceNumber
        super.init(label: "Argon")
        }
        
    public func initialize()
        {
        UUID.resetSystemUUIDCounter()
        self.initTypes()
        self.initClasses()
        self.initBaseMethods()
        self.initSlots()
        self.initConstants()
        self.layoutObjectSlots()
        self.postProcessTypes()
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
        aClass.setIndex(UUID.systemUUID(self.instanceNumber))
        aClass.flags([.kSystemTypeFlag])
        self.addSymbol(aClass)
        }
        
    public func addSystemEnumeration(_ anEnum: Type)
        {
        anEnum.setIndex(UUID.systemUUID(self.instanceNumber))
        (anEnum as! TypeEnumeration)._isSystemType = true
        self.addSymbol(anEnum)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        }
        
    private func initTypes()
        {
        self.addSystemClass(TypeClass(label: "Object").flags([.kRootTypeFlag,.kSystemTypeFlag]).mcode("o").setType(.object))
        self.addSystemClass(TypeClass(label: "Magnitude").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.magnitude))
        self.addSystemClass(TypeClass(label: "Number").flags([.kValueTypeFlag,.kSystemTypeFlag]).superclass(self.magnitude).setType(.number))
        self.addSystemClass(TypeClass(label: "Integer").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).setType(.integer))
        self.addSystemClass(TypeClass(label: "UInteger").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.number).mcode("u").setType(.uInteger))
        self.addSystemClass(TypeClass(label: "Boolean").flags([.kPrimitiveTypeFlag,.kSystemTypeFlag]).superclass(self.object).setType(.boolean))
        self.addSystemClass(TypeClass(label: "String").flags([.kSystemTypeFlag]).superclass(self.object).setType(.string))
        self.addSystemClass(TypeClass(label: "Slot").flags([.kSystemTypeFlag]).superclass(self.object).mcode("l").setType(.slot))
        self.addSystemClass(TypeClass(label: "Iterable").flags([.kSystemTypeFlag]).superclass(self.object).mcode("d"))
        self.addSystemClass(TypeClass(label: "Collection").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("f").setType(.collection))
        self.addSystemClass(TypeClass(label: "Array").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("a").setType(.array))
        self.addSystemClass(TypeClass(label: "Type").flags([.kSystemTypeFlag]).superclass(self.object).setType(.type))
        self.addSystemClass(TypeClass(label: "Class").flags([.kSystemTypeFlag]).superclass(self.typeClass).mcode("c").setType(.class))
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
        self.addSystemClass(TypeClass(label: "Enumeration").flags([.kSystemTypeFlag,.kPrimitiveTypeFlag]).superclass(self.typeClass).mcode("e").setType(.enumeration))
        self.addSystemClass(TypeClass(label: "EnumerationCase").flags([.kSystemTypeFlag]).superclass(self.object).mcode("q").setType(.enumerationCase))
        self.addSystemClass(TypeClass(label: "Tuple").flags([.kSystemTypeFlag]).superclass(self.typeClass).mcode("p").setType(.tuple))
        self.addSystemClass(TypeClass(label: "Module").flags([.kSystemTypeFlag]).superclass(self.typeClass).setType(.module))
        self.addSystemClass(TypeClass(label: "Parameter").flags([.kSystemTypeFlag]).superclass(self.slot).setType(.parameter))
        self.addSystemClass(TypeClass(label: "Nil").flags([.kSystemTypeFlag]).superclass(self.object).mcode("a").setType(.nil))
        self.addSystemClass(TypeClass(label: "Invokable").flags([.kSystemTypeFlag]).superclass(self.object).setType(.invokable))
        self.addSystemClass(TypeClass(label: "Function").flags([.kSystemTypeFlag]).superclass(self.invokable).mcode("f").setType(.function))
        self.addSystemClass(TypeClass(label: "MethodInstance").flags([.kSystemTypeFlag]).superclass(self.invokable).setType(.methodInstance))
        self.addSystemClass(TypeClass(label: "Instruction").flags([.kSystemTypeFlag]).superclass(self.object).setType(.instruction))
        self.addSystemClass(TypeClass(label: "DictionaryBucket").flags([.kSystemTypeFlag]).superclass(self.object).setType(.dictionaryBucket))
        self.addSystemClass(TypeClass(label: "Dictionary").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("j").setType(.dictionary))
        self.addSystemClass(TypeClass(label: "List").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("n").setType(.list))
        self.addSystemClass(TypeClass(label: "ListNode").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("N").setType(.listNode))
        self.addSystemClass(TypeClass(label: "Pointer").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.object).mcode("P").setType(.pointer))
        self.addSystemClass(TypeClass(label: "Set").flags([.kSystemTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("S").setType(.set))
        self.addSystemClass(TypeClass(label: "Vector").flags([.kSystemTypeFlag,.kArrayTypeFlag,.kArcheTypeFlag]).superclass(self.collection).mcode("V").setType(.vector))
        self.addSystemClass(TypeClass(label: "Closure").flags([.kSystemTypeFlag]).superclass(self.invokable).mcode("C").setType(.closure))
        self.addSystemClass(TypeClass(label: "Metatype").flags([.kSystemTypeFlag]).superclass(self.typeClass).mcode("t").setType(.metaclass))
        self.addSystemEnumeration(TypeEnumeration(label: "Opcode").flags([.kSystemTypeFlag]).cases("#CALL","#CALLP","#STP","#LFP","#IADD","#FADD","#ISUB","#FSUB","#IMUL","#FMUL","#IDIV","#FDIV","#IMOD","#FMOD","#IPOW","#FPOW","#ILT","#ILTEQ","#IEQ","#INEQ","#IGT","#IGTEQ","#FLT","FLTEQ","#FEQ","#FNEQ","#FGT","#FGTEQ","#INEG","#FNEG","#IBITAND","#IBITOR","#IBITXOR","#NOT","#BITNOT","#IINC","#IDEC","#IINCW","#IDECW","#RET","#PUSH","#POP","#MOV"))
        self.addSystemEnumeration(TypeEnumeration(label: "Literal").flags([.kSystemTypeFlag]).case("#integer",[self.integer]).case("float",[self.float]).case("boolean",[self.boolean]).case("byte",[self.byte]).case("character",[self.character]).case("string",[self.string]).case("address",[self.address]))
        self.addSystemEnumeration(TypeEnumeration(label: "Operand").flags([.kSystemTypeFlag]).case("#literal",[self.literal]).case("#address",[self.address]).case("#indirect",[self.integer,self.integer]).case("#return",[]).case("#stack",[]).case("#frame",[]).case("#label",[self.integer]).case("#temporary",[self.integer]).case("#literal",[self.literal]).case("#none",[]))
        self.addSystemEnumeration(TypeEnumeration(label: "SlotType").flags([.kSystemTypeFlag]).cases("#instanceSlot","#localSlot","#moduleSlot","#classSlot","#magicNumberSlot","#headerSlot","#virtualReadSlot","#virtualReadWriteSlot","#cocoonSlot"))
        }
        
    private func initConstants()
        {
        self.addSymbol(SystemConstant(label:"$UserFirstName",type:self.string))
        self.addSymbol(SystemConstant(label:"$ArgonDirectory",type:self.string))
        self.addSymbol(SystemConstant(label:"$ArgonVersion",type:self.string))
        self.addSymbol(SystemConstant(label:"$ArgonIsHeadless",type:self.boolean))
        self.addSymbol(SystemConstant(label:"$UserLastName",type:self.string))
        self.addSymbol(SystemConstant(label:"$UserName",type:self.string))
        self.addSymbol(SystemConstant(label:"$UserEMailAddress",type:self.string))
        self.addSymbol(SystemConstant(label:"$HostName",type:self.string))
        self.addSymbol(SystemConstant(label:"$IPAddress",type:self.string))
        self.addSymbol(SystemConstant(label:"$EthernetAddress",type:self.string))
        self.addSymbol(SystemConstant(label:"$GatewayAddress",type:self.string))
        self.addSymbol(SystemConstant(label:"$UserHomeDirectory",type:self.string))
        self.addSymbol(SystemConstant(label:"$IPAddresses",type:self.array.of(self.string)))
        self.addSymbol(SystemConstant(label:"$EthernetAddresses",type:self.array.of(self.string)))
        }
        
    private func initMetatypes(forType: Type)
        {
        guard let typeClass = forType as? TypeClass else
            {
            return
            }
        typeClass.type = Argon.addType(TypeClassClass(label: typeClass.label + "Class",isSystem: typeClass.isSystemType,generics: typeClass.generics))
        typeClass.type.type = self.metatype
        for type in typeClass.subtypes
            {
            self.initMetatypes(forType: type)
            }
        }
        
    private func initClasses()
        {
        self.metatype.type = self.object
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
        self.collection.typeVar("ELEMENT")
        self.dictionary.typeVar("KEY").typeVar("VALUE")
        self.listNode.typeVar("ELEMENT")
        self.pointer.typeVar("ELEMENT")
        for type in self.symbols.compactMap({$0 as? Type})
            {
            Argon.addType(type)
            }
        assert(Argon.typeTable[self.object.argonHash].isNotNil)
        }
        
    private func initSlots()
        {
        self.array.hasBytes(true).slot("elements",self.array.of(self.object))
        self.block.slot("count",self.integer).slot("size",self.integer).slot("nextBlock",self.address).hasBytes(true).slot("bytesOffset",self.integer)
        self.class.slot("superclass",self.class).slot("subclasses",self.array.of(self.class)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer).slot("isArchetype",self.boolean).slot("isGenericInstance",self.boolean)
        self.closure.slot("codeSegment",self.address).slot("initialIP",self.address).slot("localCount",self.integer).slot("localSlots",self.array.of(self.slot)).slot("contextPointer",self.address).slot("parameters",self.array.of(self.parameter)).slot("returnType",self.typeClass)
        self.collection.slot("count",self.integer).slot("size",self.integer).slot("elementType",self.typeClass)
        self.date.slot("day",self.integer).slot("month",self.string).slot("monthIndex",self.integer).slot("year",self.integer)
        self.dictionary.slot("hashFunction",self.closure).slot("prime",self.integer)
        self.dictionaryBucket.slot("key",self.object).slot("value",self.object).slot("next",self.dictionaryBucket)
        self.enumeration.slot("rawType",self.typeClass).slot("cases",self.array.of(self.enumerationCase))
        self.enumerationCase.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeClass)).slot("enumeration",self.enumeration).slot("rawType",self.integer).slot("instanceSizeInBytes",self.integer).slot("index",self.integer)
        self.function.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot)).slot("libraryPath",self.string).slot("libraryHandle",self.address).slot("librarySymbol",self.address)
        self.list.slot("elementSize",self.integer).slot("first",self.listNode).slot("last",self.listNode)
        self.listNode.slot("element",self.object).slot("next",self.listNode).slot("previous",self.listNode)
        self.metatype.slot("baseType",self.typeClass)
        self.methodInstance.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot)).slot("instructions",self.array.of(self.instruction))
        self.moduleType.slot("isSystemModule",self.boolean).slot("symbols",self.typeClass).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.object.slot("hash",self.integer)
        self.slot.slot("name",self.string).slot("type",self.typeClass).slot("offset",self.integer).slot("typeCode",self.integer).slot("container",self.typeClass).slot("slotType",self.slotType)
        self.string.slot("count",self.integer).hasBytes(true)
        self.tuple.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.typeClass.slot("name",self.string).slot("typeCode",self.integer).slot("module",self.moduleType).slot("typeParameters",self.array.of(self.typeClass)).slot("isSystemType",self.boolean)
        self.instruction.slot("opcode",self.opcode).slot("offset",self.integer).slot("operand1",self.operand).slot("operand2",self.operand).slot("result",self.operand)
        self.parameter.slot("tag",self.string).slot("retag",self.string).slot("tagIsShown",self.boolean).slot("isVariadic",self.boolean)
        self.vector.slot("block",self.block).slot("blockCount",self.integer)
        }

    private func initBaseMethods()
        {
        self.addSymbol(Infix(label: "+").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "-").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "*").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "/").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "**").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "**").triple(self,.generic("number"),.generic("anotherNumber"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Infix(label: "%").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        
        self.addSymbol(Infix(label: "+=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)))
        self.addSymbol(Infix(label: "-=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)))
        self.addSymbol(Infix(label: "*=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)))
        self.addSymbol(Infix(label: "/=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)))
        self.addSymbol(Infix(label: "%=").triple(self,.generic("number"),.generic("number"),.type(self.void),where: ("number",self.number)))
        
        self.addSymbol(Infix(label: "==").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: "!=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: "<=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: ">=").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: ">").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: "<").triple(self,.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        
        self.addSymbol(Infix(label: "&&").triple(self,.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(Infix(label: "||").triple(self,.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)))
    
        self.addSymbol(Infix(label: "&").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        self.addSymbol(Infix(label: "|").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        self.addSymbol(Infix(label: "^").triple(self,.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        
        self.addSymbol(Prefix(label: "!").double(self,.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Prefix(label: "-").double(self,.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(Prefix(label: "~").double(self,.generic("number"),.generic("number"),where: ("number",self.number)))
        
        self.addSymbol(Postfix(label: "++").double(self,.generic("number"),.void,where: ("number",self.number)))
        self.addSymbol(Postfix(label: "--").double(self,.generic("number"),.void,where: ("number",self.number)))
        
        self.addSymbol(PrimitiveMethodInstance.label("class","of",self.object,ret: self.class))
        
        self.addSymbol(MakerMethodInstance.from(self.string,to: self.float.type))
        self.addSymbol(MakerMethodInstance.from(self.string,to: self.integer.type))
        self.addSymbol(MakerMethodInstance.from(self.string,to: self.uInteger.type))
        self.addSymbol(MakerMethodInstance.from(self.string,to: self.byte.type))
        self.addSymbol(MakerMethodInstance.from(self.string,to: self.character.type))
        
        self.addSymbol(MakerMethodInstance.from(self.float,to: self.integer.type))
        self.addSymbol(MakerMethodInstance.from(self.float,to: self.uInteger.type))
        self.addSymbol(MakerMethodInstance.from(self.float,to: self.string.type))
        self.addSymbol(MakerMethodInstance.from(self.float,to: self.byte.type))
        self.addSymbol(MakerMethodInstance.from(self.float,to: self.character.type))
        
        self.addSymbol(MakerMethodInstance.from(self.integer,to: self.float.type))
        self.addSymbol(MakerMethodInstance.from(self.integer,to: self.uInteger.type))
        self.addSymbol(MakerMethodInstance.from(self.integer,to: self.string.type))
        self.addSymbol(MakerMethodInstance.from(self.integer,to: self.byte.type))
        self.addSymbol(MakerMethodInstance.from(self.integer,to: self.character.type))
        
        self.addSymbol(MakerMethodInstance.from(self.uInteger,to: self.float.type))
        self.addSymbol(MakerMethodInstance.from(self.uInteger,to: self.integer.type))
        self.addSymbol(MakerMethodInstance.from(self.uInteger,to: self.string.type))
        self.addSymbol(MakerMethodInstance.from(self.uInteger,to: self.byte.type))
        self.addSymbol(MakerMethodInstance.from(self.uInteger,to: self.character.type))
        
        self.addSymbol(MakerMethodInstance.from(self.byte,to: self.float.type))
        self.addSymbol(MakerMethodInstance.from(self.byte,to: self.integer.type))
        self.addSymbol(MakerMethodInstance.from(self.byte,to: self.string.type))
        self.addSymbol(MakerMethodInstance.from(self.byte,to: self.uInteger.type))
        self.addSymbol(MakerMethodInstance.from(self.byte,to: self.character.type))
        
        self.addSymbol(MakerMethodInstance.from(self.character,to: self.float.type))
        self.addSymbol(MakerMethodInstance.from(self.character,to: self.integer.type))
        self.addSymbol(MakerMethodInstance.from(self.character,to: self.string.type))
        self.addSymbol(MakerMethodInstance.from(self.character,to: self.uInteger.type))
        self.addSymbol(MakerMethodInstance.from(self.character,to: self.byte.type))
        
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
        
    public func lookup(index: UUID) -> Symbol?
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
