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
        
 
        
    public override func resolveReferences()
        {
        super.resolveReferences()
        self.layout()
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
        self.addSymbol(SystemClass(label:"Object").mcode("k"))
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
        self.addSymbol(IntrinsicMethodInstance(left:"TYPE","+",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        self.addSymbol(IntrinsicMethodInstance(left:"TYPE","-",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        self.addSymbol(IntrinsicMethodInstance(left:"TYPE","*",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        self.addSymbol(IntrinsicMethodInstance(left:"TYPE","/",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        self.addSymbol(IntrinsicMethodInstance(left:"TYPE","%",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        let mathGroup = SystemSymbolGroup(label: "Mathematics")
        self.addSymbol(mathGroup)
        mathGroup.addSymbol(LibraryMethodInstance(left:self.float,"truncate",right:self.float,out:self.integer).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance(left:self.float,"ceiling",right:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance(left:self.float,"floor",right:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance(left:self.float,"round",right:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("sin",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("cos",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("tan",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("asin",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("acos",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("atan",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("ln",arg:self.float,out:self.float).libraryMethod)
        mathGroup.addSymbol(LibraryMethodInstance("exp",arg:self.float,out:self.float).libraryMethod)
        let formatGroup = SystemSymbolGroup(label: "Printing")
        self.addSymbol(formatGroup)
        let method = LibraryMethodInstance("print",self.integer).libraryMethod
        formatGroup.addSymbol(method)
        method.addInstance(LibraryMethodInstance("print",self.float))
        method.addInstance(LibraryMethodInstance("print",self.string))
        method.addInstance(LibraryMethodInstance("print",self.boolean))
        method.addInstance(LibraryMethodInstance("print",self.object))
        let ioGroup = SystemSymbolGroup(label: "IO")
        self.addSymbol(ioGroup)
        ioGroup.addSymbol(LibraryMethodInstance("next",self.readStream,"TYPE",self.integer).where("TYPE",self.object).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPut",self.writeStream,"TYPE",self.integer).where("TYPE",self.object).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("open",self.string,self.string,"TYPE").where("TYPE",self.readStream).where("TYPE",self.writeStream).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("close",self.stream,self.boolean).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("tell",self.stream,self.integer).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("flush",self.stream,self.boolean).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("seek",self.stream,self.integer,self.boolean).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextLine",self.stream,self.string,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutLine",self.stream,self.string,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextByte",self.stream,self.byte,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutByte",self.stream,self.byte,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextFloat",self.stream,self.float).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutFloat",self.stream,self.float,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextInteger",self.stream,self.integer).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutInteger",self.stream,self.integer,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextString",self.stream,self.string).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutString",self.stream,self.string,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextSymbol",self.stream,self.symbol).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutSymbol",self.stream,self.symbol,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextUInteger",self.stream,self.uInteger).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutUInteger",self.stream,self.uInteger,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextDate",self.stream,self.date).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutDate",self.stream,self.date,self.void).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextTime",self.stream,self.time).libraryMethod)
        ioGroup.addSymbol(LibraryMethodInstance("nextPutTime",self.stream,self.time,self.void).libraryMethod)
        let arrays = SystemSymbolGroup(label: "Arrays")
        self.addSymbol(arrays)
        arrays.addSymbol(LibraryMethodInstance("append",self.array,"TYPE").libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("at",self.array,self.integer,"TYPE").libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("atPut",self.array,self.integer,"TYPE",self.void).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("atPutAll",self.array,self.integer,self.array,self.void).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("contains",self.array,"TYPE",self.boolean).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("containsAll",self.array,self.array,self.boolean).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("last",self.array,"TYPE").libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("first",self.array,"TYPE").libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("add",self.array.of(ClassParm("TYPE")),ClassParm("TYPE")).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("addAll",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("removeAt",self.array.of(ClassParm("TYPE")),self.integer).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("removeAll",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("withoutFirst",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("withoutLast",self.array.of(ClassParm("TYPE")),self.array.of(ClassParm("TYPE"))).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("withoutFirst",self.array.of(ClassParm("TYPE")),self.integer,self.array.of(ClassParm("TYPE"))).libraryMethod)
        arrays.addSymbol(LibraryMethodInstance("withoutLast",self.array.of(ClassParm("TYPE")),self.integer,self.array.of(ClassParm("TYPE"))).libraryMethod)
        let strings = SystemSymbolGroup(label: "Strings")
        self.addSymbol(strings)
        strings.addSymbol(LibraryMethodInstance("separatedBy",self.string,self.string,self.array.of(self.string)).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("joinedWith",self.array.of(self.string),self.string,self.string).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("contains",self.string,self.string,self.boolean).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("hasPrefix",self.string,self.string,self.boolean).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("hasSuffix",self.string,self.string,self.boolean).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("prefixedWith",self.string,self.string,self.string).libraryMethod)
        strings.addSymbol(LibraryMethodInstance("suffixedWith",self.string,self.string,self.boolean).libraryMethod)
        }
    ///
    ///
    /// We need a special layout algorithm because this module has
    /// complex dependencies.
    ///
    ///
    internal override func layout()
        {
        print("LAYING OUT SLOTS")
        self.layoutSlots()
        for aClass in self.classes.sorted(by: {$0.name<$1.name})
            {
            aClass.printLayout()
            }
        print("LAID OUT SLOTS")
        ///
        ///
        /// Now do layouts in a specific order
        ///
        print("LAYING OUT MEMORY")
        let classes = self.classes
        for aClass in classes
            {
            aClass.preallocateMemory(size: InnerPointer.kClassSizeInBytes)
            }
        for aClass in classes
            {
            aClass.layoutInMemory()
            }
        for instance in self.methodInstances
            {
            instance.layoutInMemory()
            }
        print("LAID OUT MEMORY")
        }
    }
