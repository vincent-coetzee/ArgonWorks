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
        
    public var metaclass: Type
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
        
    public var moduleClass: Type
        {
        return(self.lookup(label: "Module") as! Type)
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
        
    public var enumerationInstance: Type
        {
        return(self.lookup(label: "EnumerationInstance") as! Type)
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
        
    public var module: Type
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
        
    private var systemClassInLoadingOrder = Classes()
    private let instanceNumber: Int
        
    public init(instanceNumber: Int)
        {
        self.instanceNumber = instanceNumber
        UUID.resetSystemUUIDCounter()
        super.init(label: "Argon")
        self.initTypes()
        self.initBaseMethods()
        self.initSlots()
        self.initConstants()
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

    public func addSystemClass(_ aClass: Class)
        {
        aClass.setIndex(UUID.systemUUID(self.instanceNumber))
        self.systemClassInLoadingOrder.append(aClass)
        self.addSymbol(aClass.type!)
        }
        
    public func addSystemEnumeration(_ anEnum: Enumeration)
        {
        anEnum.setIndex(UUID.systemUUID(self.instanceNumber))
        self.addSymbol(anEnum.type!)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        }
        
    private func initTypes()
        {
        classesAreLocked = false
        self.addSystemClass(RootClass().mcode("o").setType(.object))
        self.addSystemClass(ValueClass(label: "Magnitude").superclass(self.object).setType(.magnitude))
        self.addSystemClass(ValueClass(label: "Number").superclass(self.magnitude).setType(.number))
        self.addSystemClass(PrimitiveClass(label: "Integer").superclass(self.number).setType(.integer))
        self.addSystemClass(PrimitiveClass(label: "UInteger").superclass(self.number).mcode("u").setType(.uInteger))
        self.addSystemClass(PrimitiveClass(label: "Boolean").superclass(self.object).setType(.boolean))
        self.addSystemClass(SystemClass(label: "String").superclass(self.object).setType(.string))
        self.addSystemClass(SystemClass(label: "Slot").superclass(self.object).mcode("l").setType(.slot))
        self.addSystemClass(GenericSystemClass(label:"Iterable",superclasses: [self.object],types: [TypeContext.freshTypeVariable(named:"IELEMENT")]).mcode("d"))
        self.addSystemClass(GenericSystemClass(label: "Collection",superclasses: [self.object,self.iterable],types: [TypeContext.freshTypeVariable(named:"ELEMENT")]).mcode("f").setType(.collection))
        self.addSystemClass(ArrayClass(label:"Array",superclasses:[self.collection],types:[]).mcode("a").setType(.array))
        self.addSystemClass(SystemClass(label: "Type").superclass(self.object).setType(.type))
        self.addSystemClass(SystemClass(label: "Class").superclass(self.typeClass).mcode("c").setType(.class))
        self.addSystemClass(SystemClass(label: "Error").superclass(self.object).setType(.error))
        self.addSystemClass(SystemClass(label: "Block").superclass(self.object).setType(.block))
        self.addSystemClass(SystemClass(label: "Index").superclass(self.object).setType(.index))
        self.addSystemClass(PrimitiveClass(label: "Float").superclass(self.number).mcode("f").setType(.float))
        self.addSystemClass(SystemClass(label: "Void").superclass(self.object).mcode("v").setType(.void))
        self.addSystemClass(PrimitiveClass(label: "Character").superclass(self.magnitude).mcode("c").setType(.character))
        self.addSystemClass(SystemValueClass(label: "Time").superclass(self.magnitude).mcode("t").setType(.time))
        self.addSystemClass(SystemValueClass(label: "Date").superclass(self.magnitude).mcode("d").setType(.date))
        self.addSystemClass(SystemValueClass(label: "DateTime").superclass(self.date).superclass(self.time).mcode("z").setType(.dateTime))
        self.addSystemClass(SystemValueClass(label: "Address").superclass(self.uInteger).mcode("h").setType(.address))
        self.addSystemClass(SystemClass(label: "Symbol").superclass(self.string).mcode("x").setType(.symbol))
        self.addSystemClass(PrimitiveClass(label: "Byte").superclass(self.magnitude).mcode("b").setType(.byte))
        self.addSystemClass(SystemClass(label: "Enumeration").superclass(self.typeClass).mcode("e").setType(.enumeration))
        self.addSystemClass(SystemClass(label: "EnumerationCase").superclass(self.object).mcode("q").setType(.enumerationCase))
        self.addSystemClass(SystemClass(label: "Tuple").superclass(self.typeClass).mcode("p").setType(.tuple))
        self.addSystemClass(SystemClass(label: "GenericClass").superclass(self.class).mcode("g").setType(.genericClass))
        self.addSystemClass(SystemClass(label: "Metaclass").superclass(self.class).mcode("m").setType(.metaclass))
        self.addSystemClass(SystemClass(label: "Module").superclass(self.typeClass).setType(.module))
        self.addSystemClass(SystemClass(label: "Parameter").superclass(self.slot).setType(.parameter))
        self.addSystemClass(SystemClass(label: "Nil").superclass(self.object).mcode("a").setType(.nil))
        self.addSystemClass(SystemClass(label: "Invokable").superclass(self.object).setType(.invokable))
        self.addSystemClass(SystemClass(label: "Function").superclass(self.invokable).mcode("f").setType(.function))
        self.addSystemClass(SystemClass(label: "MethodInstance").superclass(self.invokable).setType(.methodInstance))
        self.addSystemClass(SystemClass(label: "Instruction").superclass(self.object).setType(.instruction))
        self.addSystemClass(SystemClass(label: "DictionaryBucket").superclass(self.object).setType(.dictionaryBucket))
        self.addSystemClass(SystemClass(label: "EnumerationInstance").superclass(self.object))
        self.addSystemClass(GenericSystemClass(label: "Dictionary",superclasses:[self.collection],types: [TypeContext.freshTypeVariable(named:"KEY")]).mcode("j").setType(.dictionary))
        self.addSystemClass(GenericSystemClass(label: "List",superclasses:[self.collection],types:[]).mcode("n").setType(.list))
        self.addSystemClass(GenericSystemClass(label: "ListNode",superclasses:[self.collection],types: [TypeContext.freshTypeVariable(named:"LELEMENT")]).mcode("N").setType(.listNode))
        self.addSystemClass(GenericSystemClass(label: "Pointer",superclasses:[self.object],types: [TypeContext.freshTypeVariable(named:"LNELEMENT")]).mcode("P").setType(.pointer))
        self.addSystemClass(GenericSystemClass(label: "Set",superclasses:[self.collection],types:[]).mcode("S").setType(.set))
        self.addSystemClass(ArrayClass(label: "Vector",superclasses:[self.collection],types:[TypeContext.freshTypeVariable(named:"INDEX")]).mcode("V").setType(.vector))
        self.addSystemClass(ClosureClass(label: "Closure",superclasses:[self.invokable]).mcode("C").setType(.closure))
        self.addSystemEnumeration(SystemEnumeration(label: "Opcode").cases("#CALL","#CALLP","#STP","#LFP","#IADD","#FADD","#ISUB","#FSUB","#IMUL","#FMUL","#IDIV","#FDIV","#IMOD","#FMOD","#IPOW","#FPOW","#ILT","#ILTEQ","#IEQ","#INEQ","#IGT","#IGTEQ","#FLT","FLTEQ","#FEQ","#FNEQ","#FGT","#FGTEQ","#INEG","#FNEG","#IBITAND","#IBITOR","#IBITXOR","#NOT","#BITNOT","#IINC","#IDEC","#IINCW","#IDECW","#RET","#PUSH","#POP","#MOV"))
        self.addSystemEnumeration(SystemEnumeration(label: "Literal").case("#integer",[self.integer]).case("float",[self.float]).case("boolean",[self.boolean]).case("byte",[self.byte]).case("character",[self.character]).case("string",[self.string]).case("address",[self.address]))
        self.addSystemEnumeration(SystemEnumeration(label: "Operand").case("#literal",[self.literal]).case("#address",[self.address]))
        self.addSystemEnumeration(SystemEnumeration(label: "SlotType").cases("#instanceSlot","#localSlot","#moduleSlot","#classSlot","#magicNumberSlot","#headerSlot","#virtualReadSlot","#virtualReadWriteSlot","#cocoonSlot"))
        classesAreLocked = true
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
        
    private func initSlots()
        {
        self.object.rawClass.slot("hash",self.integer)
        self.array.rawClass.hasBytes(true).slot("elements",self.array.of(self.class)).slot("elementClass",self.class)
        self.block.rawClass.slot("count",self.integer).slot("blockSize",self.integer).slot("nextBlock",self.address)
        self.class.rawClass.slot("superclasses",self.array.of(self.class)).slot("subclasses",self.array.of(self.class)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer)
        self.closure.rawClass.slot("codeSegment",self.address).slot("initialIP",self.address).slot("localCount",self.integer).slot("localSlots",self.array.of(self.slot)).slot("contextPointer",self.address).slot("parameters",self.array.of(self.parameter)).slot("returnType",self.typeClass)
        self.collection.rawClass.slot("count",self.integer).slot("size",self.integer).slot("elementType",self.typeClass)
        self.date.rawClass.virtual("day",self.integer).virtual("month",self.string).virtual("monthIndex",self.integer).virtual("year",self.integer)
        self.dateTime.rawClass.virtual("date",self.date).virtual("time",self.time)
        self.dictionary.rawClass.slot("hashFunction",self.closure).slot("prime",self.integer)
        self.dictionaryBucket.rawClass.slot("key",self.object).slot("value",self.object).slot("next",self.dictionaryBucket)
        self.enumeration.rawClass.slot("rawType",self.typeClass).slot("cases",self.array.of(self.enumerationCase))
        self.enumerationCase.rawClass.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeClass)).slot("enumeration",self.enumeration).slot("rawType",self.integer).slot("instanceSizeInBytes",self.integer).slot("index",self.integer)
        self.function.rawClass.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot)).slot("libraryPath",self.string).slot("libraryHandle",self.address).slot("librarySymbol",self.address)
        self.list.rawClass.slot("elementSize",self.integer).slot("first",self.listNode).slot("last",self.listNode)
        self.listNode.rawClass.slot("element",self.object).slot("next",self.listNode).slot("previous",self.listNode)
        self.methodInstance.rawClass.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot)).slot("instructions",self.array.of(self.instruction))
        self.moduleClass.rawClass.virtual("isSystemModule",self.boolean).slot("symbols",self.typeClass).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.slot.rawClass.slot("name",self.string).slot("type",self.typeClass).slot("offset",self.integer).slot("typeCode",self.integer).slot("container",self.typeClass).slot("slotType",self.enumeration)
        self.string.rawClass.slot("count",self.integer).virtual("bytes",self.address).hasBytes(true)
        self.time.rawClass.virtual("hour",self.integer).virtual("minute",self.integer).virtual("second",self.integer).virtual("millisecond",self.integer)
        self.tuple.rawClass.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.typeClass.rawClass.slot("name",self.string).slot("typeCode",self.integer).slot("container",self.module).slot("typeParameters",self.array.of(self.typeClass)).slot("isSystemType",self.boolean)
        self.vector.rawClass.slot("startBlock",self.block).slot("blockCount",self.integer).hasBytes(true)
        self.instruction.rawClass.slot("opcode",self.opcode).slot("offset",self.integer).slot("operand1",self.operand).slot("operand2",self.operand).slot("result",self.operand)
        self.parameter.rawClass.slot("tag",self.string).slot("retag",self.string).slot("type",self.typeClass).slot("tagIsShown",self.boolean).slot("isVariadic",self.boolean)
        self.enumerationInstance.rawClass.slot("enumeration",self.enumeration).slot("caseIndex",self.integer).slot("associatedValues",self.array.of(self.object))
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
        
        self.float.initializer(500,self.string)
        self.float.initializer(501,self.integer)
        self.float.initializer(502,self.uInteger)
        self.float.initializer(503,self.byte)
        self.float.initializer(504,self.character)
        self.string.initializer(510,self.float)
        self.string.initializer(511,self.integer)
        self.string.initializer(512,self.uInteger)
        self.string.initializer(513,self.byte)
        self.string.initializer(514,self.character)
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
    }
