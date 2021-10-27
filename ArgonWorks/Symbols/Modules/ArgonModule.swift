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
        
    public var nilClass: Class
        {
        return(self.lookup(label: "Nil") as! Class)
        }
        
    public var number: Class
        {
        return(self.lookup(label: "Number") as! Class)
        }
        
    public var readStream: Class
        {
        return(self.lookup(label: "ReadStream") as! Class)
        }
        
    public var stream: Class
        {
        return(self.lookup(label: "Stream") as! Class)
        }
        
    public var date: Class
        {
        return(self.lookup(label: "Date") as! Class)
        }
        
    public var time: Class
        {
        return(self.lookup(label: "Time") as! Class)
        }
        
    public var byte: Class
        {
        return(self.lookup(label: "Byte") as! Class)
        }
        
    public var symbol: Class
        {
        return(self.lookup(label: "Symbol") as! Class)
        }
        
    public var void: Class
        {
        return(self.lookup(label: "Void") as! Class)
        }
        
    public var float: Class
        {
        return(self.lookup(label: "Float") as! Class)
        }
        
    public var uInteger: Class
        {
        return(self.lookup(label: "UInteger") as! Class)
        }
        
    public var writeStream: Class
        {
        return(self.lookup(label: "WriteStream") as! Class)
        }
        
    public var boolean: Class
        {
        return(self.lookup(label: "Boolean") as! Class)
        }
        
    public var collection: Class
        {
        return(self.lookup(label: "Collection") as! Class)
        }
        
    public var string: Class
        {
        return(self.lookup(label: "String") as! Class)
        }
        
    public var methodInstance: Class
        {
        return(self.lookup(label: "MethodInstance") as! Class)
        }
        
    public var `class`: Class
        {
        return(self.lookup(label: "Class") as! Class)
        }
        
    public var metaclass: Class
        {
        return(self.lookup(label: "Metaclass") as! Class)
        }
        
    public var array: ArrayClass
        {
        return(self.lookup(label: "Array") as! ArrayClass)
        }
        
    public var vector: ArrayClass
        {
        return(self.lookup(label: "Vector") as! ArrayClass)
        }
        
    public var dictionary: Class
        {
        return(self.lookup(label: "Dictionary") as! Class)
        }
        
    public var slot: Class
        {
        return(self.lookup(label: "Slot") as! Class)
        }
        
    public var parameter: Class
        {
        return(self.lookup(label: "Parameter") as! Class)
        }
        
    public var method: Class
        {
        return(self.lookup(label: "Method") as! Class)
        }
        
    public var pointer: GenericSystemClass
        {
        return(self.lookup(label: "Pointer") as! GenericSystemClass)
        }
        
    public var object: Class
        {
        return(self.lookup(label: "Object") as! Class)
        }
        
    public var function: Class
        {
        return(self.lookup(label: "Function") as! Class)
        }
        
    public var invokable: Class
        {
        return(self.lookup(label: "Invokable") as! Class)
        }
        
    public var list: Class
        {
        return(self.lookup(label: "List") as! Class)
        }
        
    public var listNode: Class
        {
        return(self.lookup(label: "ListNode") as! Class)
        }
        
    public var typeClass: Class
        {
        return(self.lookup(label: "Type") as! Class)
        }
        
    public var block: Class
        {
        return(self.lookup(label: "Block") as! Class)
        }
        
    public var integer: Class
        {
        return(self.lookup(label: "Integer") as! Class)
        }
        
    public var address: Class
        {
        return(self.lookup(label: "Address") as! Class)
        }
        
    public var dictionaryBucket: Class
        {
        return(self.lookup(label: "DictionaryBucket") as! Class)
        }
        
    public var moduleClass: Class
        {
        return(self.lookup(label: "Module") as! Class)
        }
        
    public var instructionArray: Class
        {
        return(self.lookup(label: "InstructionArray") as! Class)
        }
        
    public var generic: Class
        {
        return(self.lookup(label: "GenericClass") as! Class)
        }
        
    public var genericInstance: Class
        {
        return(self.lookup(label: "GenericClassInstance") as! Class)
        }
        
    public var enumerationCase: Class
        {
        return(self.lookup(label: "EnumerationCase") as! Class)
        }
        
    public var behavior: Class
        {
        return(self.lookup(label: "Behavior") as! Class)
        }
        
    public var tuple: Class
        {
        return(self.lookup(label: "Tuple") as! Class)
        }
        
    public var enumerationInstance: Class
        {
        return(self.lookup(label: "EnumerationInstance") as! Class)
        }
        
    public var dateTime: Class
        {
        return(self.lookup(label: "DateTime") as! Class)
        }
        
    public var magnitude: Class
        {
        return(self.lookup(label: "Magnitude") as! Class)
        }
        
    public var classParameter: Class
        {
        return(self.lookup(label: "ClassParameter") as! Class)
        }
        
    public var module: Class
        {
        return(self.lookup(label: "Module") as! Class)
        }
        
    public var closure: ClosureClass
        {
        return(self.lookup(label: "Closure") as! ClosureClass)
        }
        
    public var character: Class
        {
        return(self.lookup(label: "Character") as! Class)
        }
        
    public var variadicParameter: Class
        {
        return(self.lookup(label: "VariadicParameter") as! Class)
        }
        
    public var enumeration: Class
        {
        return(self.lookup(label: "Enumeration") as! Class)
        }
        
    public var instruction: Class
        {
        return(self.lookup(label: "Instruction") as! Class)
        }

    public init()
        {
        UUID.startSystemUUIDs()
        super.init(label: "Argon")
        self.index = UUID(index: 1)
        self.initTypes()
        self.initBaseMethods()
        self.initSlots()
        self.initConstants()
        UUID.stopSystemUUIDs()
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
 
        
    public override func resolveReferences(topModule: TopModule)
        {
        super.resolveReferences(topModule: topModule)
//        self.layout()
        }
        
    private func initTypes()
        {
        self.addSymbol(SystemClass(label:"Address").superclass("\\\\Argon\\UInteger"))
        self.addSymbol(ArrayClass(label:"Array",superclasses:["\\\\Argon\\Collection","\\\\Argon\\Iterable"],parameters:["ELEMENT"]).slotClass(ArraySlot.self).mcode("a"))
        self.addSymbol(ArrayClass(label:"ByteArray",superclasses:["\\\\Argon\\Array","\\\\Argon\\Iterable"],parameters:Array<String>()).slotClass(ArraySlot.self))
        self.addSymbol(ArrayClass(label:"InstructionArray",superclasses:["\\\\Argon\\Array","\\\\Argon\\Iterable"],parameters:["Instruction"]).slotClass(ArraySlot.self))
        self.addSymbol(SystemClass(label:"Behavior").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Block").superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.byteClass.superclass("\\\\Argon\\Magnitude").mcode("b"))
        self.addSymbol(PrimitiveClass.booleanClass.superclass("\\\\Argon\\Object").slotClass(BooleanSlot.self).mcode("l"))
        self.addSymbol(PrimitiveClass.characterClass.superclass("\\\\Argon\\Magnitude").mcode("c"))
        self.addSymbol(SystemClass(label:"Class").superclass("\\\\Argon\\Type").slotClass(ObjectSlot.self).mcode("s"))
        self.addSymbol(SystemClass(label:"ClassParameter").superclass("\\\\Argon\\Object").mcode("S"))
        self.addSymbol(ClosureClass(label:"Closure",superclasses:["\\\\Argon\\MethodContext","\\\\Argon\\Invokable"]).slotClass(ObjectSlot.self))
        self.addSymbol(SystemClass(label:"Collection").superclass("\\\\Argon\\Object").superclass("\\\\Argon\\Iterable"))
        self.addSymbol(PrimitiveClass.dateClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(PrimitiveClass.dateTimeClass.superclass("\\\\Argon\\Date").superclass("\\\\Argon\\Time"))
        self.addSymbol(GenericSystemClass(label:"Dictionary",superclasses:["\\\\Argon\\Collection","\\\\Argon\\Iterable"],parameters:["KEY","VALUE"]).mcode("d"))
        self.addSymbol(SystemClass(label:"DictionaryBucket").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Enumeration").superclass("\\\\Argon\\Type").mcode("e"))
        self.addSymbol(SystemClass(label:"EnumerationCase").superclass("\\\\Argon\\Object").mcode("u"))
        self.addSymbol(SystemClass(label:"EnumerationInstance").superclass("\\\\Argon\\Object").mcode("C"))
        self.addSymbol(SystemClass(label:"Error").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Expression").superclass("\\\\Argon\\Object"))
        self.addSymbol(TaggedPrimitiveClass.floatClass.superclass("\\\\Argon\\Number"))
        self.addSymbol(SystemClass(label:"Function").superclass("\\\\Argon\\Invokable").mcode("f"))
        self.addSymbol(SystemClass(label:"GenericClass").superclass("\\\\Argon\\Class").mcode("Q"))
        self.addSymbol(SystemClass(label:"GenericClassInstance").superclass("\\\\Argon\\Class").mcode("K"))
        self.addSymbol(TaggedPrimitiveClass.integerClass.superclass("\\\\Argon\\Number").slotClass(IntegerSlot.self).mcode("i"))
        self.addSymbol(SystemClass(label:"Invokable").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Instruction").superclass("\\\\Argon\\Object"))
        self.addSymbol(GenericSystemClass(label:"Iterable",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"]))
        self.addSymbol(GenericSystemClass(label:"List",superclasses:["\\\\Argon\\Collection","\\\\Argon\\Iterable"],parameters:["ELEMENT"]))
        self.addSymbol(GenericSystemClass(label:"ListNode",superclasses:["\\\\Argon\\Collection"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Magnitude").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Metaclass",typeCode:.metaclass).superclass("\\\\Argon\\Class").mcode("g"))
        self.addSymbol(SystemClass(label:"Method",typeCode:.method).superclass("\\\\Argon\\Invokable").mcode("m"))
        self.addSymbol(SystemClass(label:"MethodContext",typeCode:.none).superclass("\\\\Argon\\Object").mcode("C"))
        self.addSymbol(SystemClass(label:"MethodInstance",typeCode:.methodInstance).superclass("\\\\Argon\\Invokable").mcode("h"))
        self.addSymbol(SystemClass(label:"Module",typeCode:.module).superclass("\\\\Argon\\Type"))
        self.addSymbol(PrimitiveClass.mutableStringClass.superclass("\\\\Argon\\String").mcode("t"))
        self.addSymbol(SystemClass(label:"Nil").superclass("\\\\Argon\\Object").mcode("j"))
        self.addSymbol(SystemClass(label:"Number").superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(RootClass(label:"Object").mcode("k"))
        self.addSymbol(SystemClass(label:"Parameter").superclass("\\\\Argon\\Slot"))
        self.addSymbol(GenericSystemClass(label:"Pointer",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"],typeCode:.pointer).mcode("r"))
        self.addSymbol(SystemClass(label:"ReadStream",typeCode:.stream).superclass("\\\\Argon\\Stream"))
        self.addSymbol(SystemClass(label:"ReadWriteStream",typeCode:.stream).superclass("\\\\Argon\\ReadStream").superclass("\\\\Argon\\WriteStream"))
        self.addSymbol(GenericSystemClass(label:"Set",superclasses:["\\\\Argon\\Collection","\\\\Argon\\Iterable"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Slot",typeCode:.slot).superclass("\\\\Argon\\Object").mcode("p"))
        self.addSymbol(SystemClass(label:"Stream",typeCode:.stream).superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.stringClass.superclass("\\\\Argon\\Object").slotClass(StringSlot.self).mcode("q"))
        self.addSymbol(SystemClass(label:"Symbol",typeCode:.symbol).superclass("\\\\Argon\\String").mcode("n"))
        self.addSymbol(PrimitiveClass.timeClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Tuple",typeCode:.tuple).superclass("\\\\Argon\\Type").mcode("v"))
        self.addSymbol(SystemClass(label:"Type",typeCode:.type).superclass("\\\\Argon\\Object"))
        self.addSymbol(TaggedPrimitiveClass.uIntegerClass.superclass("\\\\Argon\\Number").mcode("x"))
        self.addSymbol(SystemClass(label:"VariadicParameter",typeCode:.symbol).superclass("\\\\Argon\\Object"))
        self.addSymbol(ArrayClass(label:"Vector",superclasses:["\\\\Argon\\Collection","\\\\Argon\\Iterable"],parameters:["INDEX","ELEMENT"]).slotClass(ArraySlot.self).mcode("y"))
        self.addSymbol(VoidClass.voidClass.superclass("\\\\Argon\\Object").mcode("z"))
        self.addSymbol(SystemClass(label:"WriteStream",typeCode:.stream).superclass("\\\\Argon\\Stream"))
        }
        
    private func initConstants()
        {
        self.addSymbol(SystemConstant(label:"$UserFirstName",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$ArgonDirectory",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$ArgonVersion",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$ArgonIsHeadless",type:self.boolean.type))
        self.addSymbol(SystemConstant(label:"$UserLastName",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$UserName",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$UserEMailAddress",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$HostName",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$IPAddress",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$EthernetAddress",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$GatewayAddress",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$UserHomeDirectory",type:self.string.type))
        self.addSymbol(SystemConstant(label:"$IPAddresses",type:self.array.of(self.string).type))
        self.addSymbol(SystemConstant(label:"$EthernetAddresses",type:self.array.of(self.string).type))
        }
        
    private func initSlots()
        {
        self.object.slot("hash",self.integer)
        self.array.hasBytes(true).slot("elements",self.array.of(self.class)).slot("elementClass",self.class)
        self.block.slot("count",self.integer).slot("blockSize",self.integer).slot("nextBlock",self.address)
        self.class.slot("superclasses",self.array.of(self.class)).virtual("subclasses",self.array.of(self.class)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer)
        self.classParameter.slot("name",self.string)
        self.closure.slot("codeSegment",self.address).slot("initialIP",self.address).slot("localCount",self.integer).slot("localSlots",self.array.of(self.slot)).slot("contextPointer",self.address).slot("instructions",self.array.of(self.instruction)).slot("parameters",self.array.of(self.parameter)).slot("returnType",self.typeClass)
        self.collection.slot("count",self.integer).slot("size",self.integer).slot("elementType",self.typeClass)
        self.date.virtual("day",self.integer).virtual("month",self.string).virtual("monthIndex",self.integer).virtual("year",self.integer)
        self.dateTime.virtual("date",self.date).virtual("time",self.time)
        self.dictionary.slot("hashFunction",self.closure).slot("prime",self.integer)
        self.dictionaryBucket.slot("key",self.object).slot("value",self.object).slot("next",self.dictionaryBucket)
        self.enumeration.slot("rawType",self.typeClass).slot("cases",self.array.of(self.enumerationCase))
        self.enumerationCase.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeClass)).slot("enumeration",self.enumeration).slot("rawType",self.integer).slot("caseSizeInBytes",self.integer).slot("index",self.integer)
        self.enumerationInstance.slot("enumeration",self.enumeration).slot("index",self.integer).slot("associatedValueCount",self.integer)
        self.function.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("code",self.instructionArray).slot("localSlots",self.array.of(self.slot)).slot("libraryPath",self.string).slot("libraryHandle",self.address).slot("librarySymbol",self.address)
        self.generic.slot("classParameters",self.array.of(self.classParameter))
        self.genericInstance.slot("instanciatedClasses",self.array.of(self.class))
        self.instruction.virtual("opcode",self.integer).virtual("mode",self.integer).virtual("operand1",self.integer).virtual("operand2",self.integer).virtual("operand3",self.integer)
        self.instructionArray.hasBytes(true)
        self.list.slot("elementSize",self.integer).slot("first",self.listNode).slot("last",self.listNode)
        self.listNode.slot("element",self.object).slot("next",self.listNode).slot("previous",self.listNode)
        self.method.slot("instances",self.array.of(self.methodInstance))
        self.methodInstance.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("code",self.instructionArray).slot("localSlots",self.array.of(self.slot))
        self.moduleClass.virtual("isSystemModule",self.boolean).slot("elements",self.typeClass).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.slot.slot("name",self.string).slot("type",self.typeClass).slot("offset",self.integer).slot("typeCode",self.integer)
        self.stream.slot("fileHandle",self.integer).slot("count",self.integer).virtual("isOpen",self.boolean).virtual("canRead",self.boolean).virtual("canWrite",self.boolean)
        self.string.slot("count",self.integer).virtual("bytes",self.address).hasBytes(true)
        self.time.virtual("hour",self.integer).virtual("minute",self.integer).virtual("second",self.integer).virtual("millisecond",self.integer)
        self.tuple.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.typeClass.slot("name",self.string).slot("typeCode",self.integer)
        self.vector.slot("startBlock",self.block).slot("blockCount",self.integer).hasBytes(true)
        }
        
    private func initBaseMethods()
        {
        self.addSymbol(Infix(left:"TYPE","+",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Infix(left:"TYPE","-",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Infix(left:"TYPE","*",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Infix(left:"TYPE","/",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Infix(left:"TYPE","%",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Infix(left:"TYPE","**",right:"TYPE",out:"TYPE").method)
        self.addSymbol(Prefix("!",self.boolean,out:self.boolean).method)
        self.addSymbol(Prefix("~",self.integer,out: self.integer).method)
        self.addSymbol(Postfix("++",self.integer,out: self.integer).method)
        self.addSymbol(Postfix("--",self.integer,out: self.integer).method)
        let mathGroup = SystemSymbolGroup(label: "Mathematics")
        self.addSymbol(mathGroup)
        mathGroup.addSymbol(Primitive("truncate",arg:self.float,out:self.integer).method)
        mathGroup.addSymbol(Primitive("ceiling",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("floor",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("round",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("fabs",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("abs",arg:self.integer,out:self.integer).method)
        mathGroup.addSymbol(Primitive("sin",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("cos",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("tan",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("asin",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("acos",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("atan",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("ln",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("log",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("exp",arg:self.float,out:self.float).method)
        mathGroup.addSymbol(Primitive("odd",arg:self.integer,out:self.boolean).method)
        mathGroup.addSymbol(Primitive("even",arg:self.integer,out:self.boolean).method)
        let formatGroup = SystemSymbolGroup(label: "Printing")
        self.addSymbol(formatGroup)
        formatGroup.addSymbol(Primitive("format",self.string,self.object,self.string).method)
        let method = Primitive("print",left: self.integer).method
        formatGroup.addSymbol(method)
        method.addInstance(Primitive("print",left: self.float).instance)
        method.addInstance(Primitive("print",left: self.string).instance)
        method.addInstance(Primitive("print",left: self.boolean).instance)
        method.addInstance(Primitive("print",left: self.object).instance)
        method.addInstance(Primitive("print",left: self.byte).instance)
        method.addInstance(Primitive("print",left: self.character).instance)
        method.addInstance(Primitive("print",left: self.uInteger).instance)
        method.addInstance(Primitive("print",left: self.address).instance)
        method.addInstance(Primitive("print",left: self.pointer).instance)
        let ioGroup = SystemSymbolGroup(label: "IO")
        self.addSymbol(ioGroup)
        ioGroup.addSymbol(Primitive("next",self.readStream,"TYPE",self.integer).method)
        ioGroup.addSymbol(Primitive("nextPut",self.writeStream,"TYPE",self.integer).method)
        ioGroup.addSymbol(Primitive("open",self.string,self.string,self.string).method)
        ioGroup.addSymbol(Primitive("close",self.stream,self.boolean).method)
        ioGroup.addSymbol(Primitive("tell",self.stream,self.integer).method)
        ioGroup.addSymbol(Primitive("flush",self.stream,self.boolean).method)
        ioGroup.addSymbol(Primitive("seek",self.stream,self.integer,self.boolean).method)
        ioGroup.addSymbol(Primitive("nextLine",self.stream,self.string,self.void).method)
        ioGroup.addSymbol(Primitive("nextPutLine",self.stream,self.string,self.void).method)
        ioGroup.addSymbol(Primitive("nextByte",self.stream,self.byte,self.void).method)
        ioGroup.addSymbol(Primitive("nextPutByte",self.stream,self.byte,self.void).method)
        ioGroup.addSymbol(Primitive("nextFloat",self.stream,self.float).method)
        ioGroup.addSymbol(Primitive("nextPutFloat",self.stream,self.float,self.void).method)
        ioGroup.addSymbol(Primitive("nextInteger",self.stream,self.integer).method)
        ioGroup.addSymbol(Primitive("nextPutInteger",self.stream,self.integer,self.void).method)
        ioGroup.addSymbol(Primitive("nextString",self.stream,self.string).method)
        ioGroup.addSymbol(Primitive("nextPutString",self.stream,self.string,self.void).method)
        ioGroup.addSymbol(Primitive("nextSymbol",self.stream,self.symbol).method)
        ioGroup.addSymbol(Primitive("nextPutSymbol",self.stream,self.symbol,self.void).method)
        ioGroup.addSymbol(Primitive("nextUInteger",self.stream,self.uInteger).method)
        ioGroup.addSymbol(Primitive("nextPutUInteger",self.stream,self.uInteger,self.void).method)
        ioGroup.addSymbol(Primitive("nextDate",self.stream,self.date).method)
        ioGroup.addSymbol(Primitive("nextPutDate",self.stream,self.date,self.void).method)
        ioGroup.addSymbol(Primitive("nextTime",self.stream,self.time).method)
        ioGroup.addSymbol(Primitive("nextPutTime",self.stream,self.time,self.void).method)
        let arrays = SystemSymbolGroup(label: "Arrays")
        self.addSymbol(arrays)
        arrays.addSymbol(Primitive("at",self.array,self.integer).method)
        arrays.addSymbol(Primitive("atPut",self.array,self.integer,self.void).method)
        arrays.addSymbol(Primitive("atPutAll",self.array,self.array,self.void).method)
        arrays.addSymbol(Primitive("contains",self.array,"TYPE",self.boolean).method)
        arrays.addSymbol(Primitive("containsAll",self.array,self.array,self.boolean).method)
//        arrays.addSymbol(Primitive("last",self.array,"TYPE").method)
//        arrays.addSymbol(Primitive("first",self.array,"TYPE").method)
        arrays.addSymbol(Primitive("append",self.array.of(ClassParm("TYPE")),ClassParm("TYPE")).method)
        arrays.addSymbol(Primitive("appendAll",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).method)
        arrays.addSymbol(Primitive("removeAt",self.array.of(ClassParm("TYPE")),self.integer).method)
        arrays.addSymbol(Primitive("removeAll",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).method)
        arrays.addSymbol(Primitive("withoutFirst",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).method)
        arrays.addSymbol(Primitive("withoutLast",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).method)
        let strings = SystemSymbolGroup(label: "Strings")
        self.addSymbol(strings)
        strings.addSymbol(Primitive("separatedBy",self.string,self.string,self.array.of(self.string)).method)
        strings.addSymbol(Primitive("joinedWith",self.array.of(self.string),self.string,self.string).method)
        strings.addSymbol(Primitive("contains",self.string,self.string,self.boolean).method)
        strings.addSymbol(Primitive("hasPrefix",self.string,self.string,self.boolean).method)
        strings.addSymbol(Primitive("hasSuffix",self.string,self.string,self.boolean).method)
        strings.addSymbol(Primitive("prefixedWith",self.string,self.string,self.string).method)
        strings.addSymbol(Primitive("suffixedWith",self.string,self.string,self.boolean).method)
        }
    ///
    ///
    /// We need a special layout algorithm because this module has
    /// complex dependencies.
    ///
//    ///
//    internal override func layout()
//        {
//        self.layoutSlots()
//        ///
//        ///
//        /// Now do layouts in a specific order
//        ///
//        let classes = self.classes
//        for aClass in classes
//            {
//            aClass.preallocateMemory(size: InnerPointer.kClassSizeInBytes)
//            }
//        for aClass in classes
//            {
//            aClass.layoutInMemory()
//            }
//        for instance in self.methodInstances
//            {
//            instance.layoutInMemory()
//            }
//        }
    }
