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
        
    public var method: Type
        {
        return(self.lookup(label: "Method") as! Type)
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
        
    public init(compiler: Compiler)
        {
        UUID.resetSystemUUIDCounter()
        super.init(label: "Argon")
        self.compiler = compiler
        self.initTypes()
        self.initBaseMethods()
        self.initSlots()
        self.initConstants()
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
     public required init(label: Label)
        {
        super.init(label: label)
        }

    public func addSystemClass(_ aClass: Class)
        {
        aClass.index = UUID.systemUUID(self.compiler.instanceNumber)
        let generics = aClass.isGenericClass ? (aClass as! GenericClass).types : []
        let type = TypeSystemClass(class: aClass,generics: generics)
        self.addSymbol(type)
        }
        
    private func initTypes()
        {
        self.addSystemClass(RootClass(label: "Object").mcode("o"))
        self.addSystemClass(SystemClass(label: "Magnitude").superclass(self.object))
        self.addSystemClass(SystemClass(label: "Error").superclass(self.object))
        self.addSystemClass(SystemClass(label: "Block").superclass(self.object))
        self.addSystemClass(SystemClass(label: "Index").superclass(self.object))
        self.addSystemClass(SystemClass(label: "Number").superclass(self.magnitude))
        self.addSystemClass(SystemClass(label: "Integer").superclass(self.number).slotClass(IntegerSlot.self).mcode("i"))
        self.addSystemClass(SystemClass(label: "Float").superclass(self.number).mcode("f"))
        self.addSystemClass(VoidClass.voidClass.superclass(self.object).mcode("v"))
        self.addSystemClass(SystemClass(label: "UInteger").superclass(self.number).mcode("u"))
        self.addSystemClass(SystemClass(label: "Character").superclass(self.magnitude).mcode("c"))
        self.addSystemClass(SystemClass(label: "Time").superclass(self.magnitude).mcode("t"))
        self.addSystemClass(SystemClass(label: "Date").superclass(self.magnitude).mcode("d"))
        self.addSystemClass(SystemClass(label: "DateTime").superclass(self.date).superclass(self.time).mcode("z"))
        self.addSystemClass(SystemClass(label: "Address").superclass(self.uInteger).mcode("h"))
        self.addSystemClass(SystemClass(label: "Type",typeCode:.type).superclass(self.object))
        self.addSystemClass(SystemClass(label: "String").superclass(self.object).slotClass(StringSlot.self).mcode("s"))
        self.addSystemClass(SystemClass(label: "Symbol",typeCode:.symbol).superclass(self.string).mcode("x"))
        self.addSystemClass(SystemClass(label: "Byte").superclass(self.magnitude).mcode("b"))
        self.addSystemClass(SystemClass(label: "Boolean").superclass(self.object).slotClass(BooleanSlot.self).mcode("r"))
        self.addSystemClass(SystemClass(label: "Class").superclass(self.typeClass).slotClass(ObjectSlot.self).mcode("c"))
        self.addSystemClass(SystemClass(label: "Enumeration").superclass(self.typeClass).mcode("e"))
        self.addSystemClass(SystemClass(label: "EnumerationCase").superclass(self.object).mcode("q"))
        self.addSystemClass(SystemClass(label: "Tuple",typeCode:.tuple).superclass(self.typeClass).mcode("p"))
        self.addSystemClass(SystemClass(label: "GenericClass").superclass(self.class).mcode("g"))
        self.addSystemClass(SystemClass(label: "Metaclass",typeCode:.metaclass).superclass(self.class).mcode("m"))
        self.addSystemClass(SystemClass(label: "Module",typeCode:.module).superclass(self.typeClass))
        self.addSystemClass(SystemClass(label: "Slot",typeCode:.slot).superclass(self.object).mcode("l"))
        self.addSystemClass(SystemClass(label: "Parameter").superclass(self.slot))
        self.addSystemClass(SystemClass(label: "VariadicParameter",typeCode:.symbol).superclass(self.parameter))
        self.addSystemClass(SystemClass(label: "Nil").superclass(self.object).mcode("a"))
        self.addSystemClass(GenericSystemClass(label:"Iterable",superclasses: [self.object],types: [TypeContext.freshTypeVariable(named:"IELEMENT")]).mcode("d"))
        self.addSystemClass(SystemClass(label: "Invokable").superclass(self.object))
        self.addSystemClass(SystemClass(label: "Function").superclass(self.invokable).mcode("f"))
        self.addSystemClass(SystemClass(label: "Method",typeCode:.method).superclass(self.invokable))
        self.addSystemClass(SystemClass(label: "MethodInstance",typeCode:.methodInstance).superclass(self.invokable))
        self.addSystemClass(GenericSystemClass(label: "Collection",superclasses: [self.object,self.iterable],types: [TypeContext.freshTypeVariable(named:"ELEMENT")]).mcode("f"))
        self.addSystemClass(ArrayClass(label:"Array",superclasses:[self.collection],types:[]).slotClass(ArraySlot.self).mcode("a"))
        self.addSystemClass(SystemClass(label: "DictionaryBucket").superclass(self.object))
        self.addSystemClass(GenericSystemClass(label: "Dictionary",superclasses:[self.collection],types: [TypeContext.freshTypeVariable(named:"KEY")]).mcode("j"))
        self.addSystemClass(GenericSystemClass(label: "List",superclasses:[self.collection],types:[]).mcode("n"))
        self.addSystemClass(GenericSystemClass(label: "ListNode",superclasses:[self.collection],types: [TypeContext.freshTypeVariable(named:"LELEMENT")]).mcode("N"))
        self.addSystemClass(GenericSystemClass(label: "Pointer",superclasses:[self.object],types: [TypeContext.freshTypeVariable(named:"LNELEMENT")]).mcode("P"))
        self.addSystemClass(GenericSystemClass(label: "Set",superclasses:[self.collection],types:[]).mcode("S"))
        self.addSystemClass(ArrayClass(label: "Vector",superclasses:[self.collection],types:[TypeContext.freshTypeVariable(named:"INDEX")]).slotClass(ArraySlot.self).mcode("V"))
        self.addSystemClass(ClosureClass(label: "Closure",superclasses:[self.invokable]).slotClass(ObjectSlot.self).mcode("C"))
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
        self.class.rawClass.slot("superclasses",self.array.of(self.class)).virtual("subclasses",self.array.of(self.class)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer)
        self.closure.rawClass.slot("codeSegment",self.address).slot("initialIP",self.address).slot("localCount",self.integer).slot("localSlots",self.array.of(self.slot)).slot("contextPointer",self.address).slot("parameters",self.array.of(self.parameter)).slot("returnType",self.typeClass)
        self.collection.rawClass.slot("count",self.integer).slot("size",self.integer).slot("elementType",self.typeClass)
        self.date.rawClass.virtual("day",self.integer).virtual("month",self.string).virtual("monthIndex",self.integer).virtual("year",self.integer)
        self.dateTime.rawClass.virtual("date",self.date).virtual("time",self.time)
        self.dictionary.rawClass.slot("hashFunction",self.closure).slot("prime",self.integer)
        self.dictionaryBucket.rawClass.slot("key",self.object).slot("value",self.object).slot("next",self.dictionaryBucket)
        self.enumeration.rawClass.slot("rawType",self.typeClass).slot("cases",self.array.of(self.enumerationCase))
        self.enumerationCase.rawClass.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeClass)).slot("enumeration",self.enumeration).slot("rawType",self.integer).slot("caseSizeInBytes",self.integer).slot("index",self.integer)
        self.function.rawClass.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot)).slot("libraryPath",self.string).slot("libraryHandle",self.address).slot("librarySymbol",self.address)
        self.list.rawClass.slot("elementSize",self.integer).slot("first",self.listNode).slot("last",self.listNode)
        self.listNode.rawClass.slot("element",self.object).slot("next",self.listNode).slot("previous",self.listNode)
        self.method.rawClass.slot("instances",self.array.of(self.methodInstance))
        self.methodInstance.rawClass.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("localSlots",self.array.of(self.slot))
        self.moduleClass.rawClass.virtual("isSystemModule",self.boolean).slot("elements",self.typeClass).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.slot.rawClass.slot("name",self.string).slot("type",self.typeClass).slot("offset",self.integer).slot("typeCode",self.integer)
        self.string.rawClass.slot("count",self.integer).virtual("bytes",self.address).hasBytes(true)
        self.time.rawClass.virtual("hour",self.integer).virtual("minute",self.integer).virtual("second",self.integer).virtual("millisecond",self.integer)
        self.tuple.rawClass.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.typeClass.rawClass.slot("name",self.string).slot("typeCode",self.integer)
        self.vector.rawClass.slot("startBlock",self.block).slot("blockCount",self.integer).hasBytes(true)
        }

    private func initBaseMethods()
        {
        self.addSymbol(InfixOperator(label: "+").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "-").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "*").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "/").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "**").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "%").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.number)))
        
        self.addSymbol(InfixOperator(label: "+=").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "-=").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "*=").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "/=").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "%=").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        
        self.addSymbol(InfixOperator(label: "==").triple(.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "<=").triple(.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: ">=").triple(.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: ">").triple(.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "<").triple(.generic("number"),.generic("number"),.type(self.boolean),where: ("number",self.number)))
        
        self.addSymbol(InfixOperator(label: "&&").triple(.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)))
        self.addSymbol(InfixOperator(label: "||").triple(.type(self.boolean),.type(self.boolean),.type(self.boolean),where: ("number",self.number)))
    
        self.addSymbol(InfixOperator(label: "&").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        self.addSymbol(InfixOperator(label: "|").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        self.addSymbol(InfixOperator(label: "^").triple(.generic("number"),.generic("number"),.generic("number"),where: ("number",self.integer),("number",self.uInteger),("number",self.byte),("number",self.character)))
        
        self.addSymbol(PrefixOperator(label: "!").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(PrefixOperator(label: "-").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(PrefixOperator(label: "~").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        
        self.addSymbol(PostfixOperator(label: "++").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        self.addSymbol(PostfixOperator(label: "--").double(.generic("number"),.generic("number"),where: ("number",self.number)))
        }
    }
