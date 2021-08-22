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

    public init(virtualMachine: VirtualMachine)
        {
        super.init(label: "Argon")
        self.initTypes()
        self.initBaseMethods()
        self.initSlots()
        }
        
    public func resolve(in vm: VirtualMachine)
        {
        self.resolveReferences(in: vm)
        self.layout(in: vm)
        }
        
    private var collectionModule: SystemModule
        {
        return(self.lookup(label: "Collections") as! SystemModule)
        }
        
    private var streamsModule: SystemModule
        {
        return(self.lookup(label: "Streams") as! SystemModule)
        }
        
    private var numbersModule: SystemModule
        {
        return(self.lookup(label: "Numbers") as! SystemModule)
        }
        
    private var printingModule: SystemModule
        {
        return(self.lookup(label: "Printing") as! SystemModule)
        }
        
    private func initTypes()
        {
        self.addSymbol(SystemClass(label:"Address").superclass("\\\\Argon\\Numbers\\UInteger"))
        let collections = SystemModule(label:"Collections")
        self.addSymbol(collections)
        let numbers = SystemModule(label:"Numbers")
        self.addSymbol(numbers)
        let io = SystemModule(label: "IO")
        self.addSymbol(io)
        let streams = SystemModule(label:"Streams")
        io.addSymbol(streams)
        let printing = SystemModule(label:"Printing")
        self.addSymbol(printing)
        collections.addSymbol(ArrayClass(label:"Array",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["ELEMENT"]).slotClass(ArraySlot.self).mcode("a"))
        collections.addSymbol(ArrayClass(label:"ByteArray",superclasses:["\\\\Argon\\Collections\\Array","\\\\Argon\\Collections\\Iterable"],parameters:Array<String>()).slotClass(ArraySlot.self))
        collections.addSymbol(ArrayClass(label:"InstructionArray",superclasses:["\\\\Argon\\Collections\\Array","\\\\Argon\\Collections\\Iterable"],parameters:["Instruction"]).slotClass(ArraySlot.self))
        self.addSymbol(SystemClass(label:"Behavior").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Block").superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.byteClass.superclass("\\\\Argon\\Magnitude").mcode("b"))
        self.addSymbol(PrimitiveClass.booleanClass.superclass("\\\\Argon\\Object").slotClass(BooleanSlot.self).mcode("l"))
        self.addSymbol(PrimitiveClass.characterClass.superclass("\\\\Argon\\Magnitude").mcode("c"))
        self.addSymbol(SystemClass(label:"Class").superclass("\\\\Argon\\Type").slotClass(ObjectSlot.self).mcode("s"))
        self.addSymbol(SystemClass(label:"ClassParameter").superclass("\\\\Argon\\Object").mcode("S"))
        self.addSymbol(ClosureClass(label:"Closure").superclass("\\\\Argon\\Function").slotClass(ObjectSlot.self))
        collections.addSymbol(SystemClass(label:"Collection").superclass("\\\\Argon\\Object").superclass("\\\\Argon\\Collections\\Iterable"))
        self.addSymbol(PrimitiveClass.dateClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(PrimitiveClass.dateTimeClass.superclass("\\\\Argon\\Date").superclass("\\\\Argon\\Time"))
        collections.addSymbol(GenericSystemClass(label:"Dictionary",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["KEY","VALUE"]).mcode("d"))
        collections.addSymbol(SystemClass(label:"DictionaryBucket").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Enumeration").superclass("\\\\Argon\\Type").mcode("e"))
        self.addSymbol(SystemClass(label:"EnumerationCase").superclass("\\\\Argon\\Object").mcode("u"))
        self.addSymbol(SystemClass(label:"EnumerationInstance").superclass("\\\\Argon\\Object").mcode("C"))
        self.addSymbol(SystemClass(label:"Error").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Expression").superclass("\\\\Argon\\Object"))
        numbers.addSymbol(TaggedPrimitiveClass.floatClass.superclass("\\\\Argon\\Numbers\\Number"))
        self.addSymbol(SystemClass(label:"Function").superclass("\\\\Argon\\Invokable").mcode("f"))
        self.addSymbol(SystemClass(label:"GenericClass").superclass("\\\\Argon\\Class").mcode("Q"))
        self.addSymbol(SystemClass(label:"GenericClassInstance").superclass("\\\\Argon\\Class").mcode("K"))
        numbers.addSymbol(TaggedPrimitiveClass.integerClass.superclass("\\\\Argon\\Numbers\\Number").slotClass(IntegerSlot.self).mcode("i"))
        self.addSymbol(SystemClass(label:"Invokable").superclass("\\\\Argon\\Behavior"))
        self.addSymbol(SystemClass(label:"Instruction").superclass("\\\\Argon\\Object"))
        collections.addSymbol(GenericSystemClass(label:"Iterable",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"]))
        collections.addSymbol(GenericSystemClass(label:"List",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["ELEMENT"]))
        collections.addSymbol(GenericSystemClass(label:"ListNode",superclasses:["\\\\Argon\\Collections\\Collection"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Magnitude").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Metaclass",typeCode:.metaclass).superclass("\\\\Argon\\Class").mcode("g"))
        self.addSymbol(SystemClass(label:"Method",typeCode:.method).superclass("\\\\Argon\\Invokable").mcode("m"))
        self.addSymbol(SystemClass(label:"MethodInstance",typeCode:.methodInstance).superclass("\\\\Argon\\Invokable").mcode("h"))
        self.addSymbol(SystemClass(label:"Module",typeCode:.module).superclass("\\\\Argon\\Type"))
        self.addSymbol(PrimitiveClass.mutableStringClass.superclass("\\\\Argon\\String").mcode("t"))
        self.addSymbol(SystemClass(label:"Nil").superclass("\\\\Argon\\Object").mcode("j"))
        numbers.addSymbol(SystemClass(label:"Number").superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Object").mcode("k"))
        self.addSymbol(SystemClass(label:"Parameter").superclass("\\\\Argon\\Slot"))
        self.addSymbol(GenericSystemClass(label:"Pointer",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"],typeCode:.pointer).mcode("r"))
        streams.addSymbol(SystemClass(label:"ReadStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\Stream"))
        streams.addSymbol(SystemClass(label:"ReadWriteStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\ReadStream").superclass("\\\\Argon\\Streams\\WriteStream"))
        collections.addSymbol(GenericSystemClass(label:"Set",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Slot",typeCode:.slot).superclass("\\\\Argon\\Object").mcode("p"))
        streams.addSymbol(SystemClass(label:"Stream",typeCode:.stream).superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.stringClass.superclass("\\\\Argon\\Object").slotClass(StringSlot.self).mcode("q"))
        self.addSymbol(SystemClass(label:"Symbol",typeCode:.symbol).superclass("\\\\Argon\\String").mcode("n"))
        self.addSymbol(PrimitiveClass.timeClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Tuple",typeCode:.tuple).superclass("\\\\Argon\\Type").mcode("v"))
        self.addSymbol(SystemClass(label:"Type",typeCode:.type).superclass("\\\\Argon\\Object"))
        numbers.addSymbol(TaggedPrimitiveClass.uIntegerClass.superclass("\\\\Argon\\Numbers\\Number").mcode("x"))
        collections.addSymbol(ArrayClass(label:"Vector",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["INDEX","ELEMENT"]).slotClass(ArraySlot.self).mcode("y"))
        self.addSymbol(VoidClass.voidClass.superclass("\\\\Argon\\Object").mcode("z"))
        streams.addSymbol(SystemClass(label:"WriteStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\Stream"))
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
        let numbersModule = self.numbersModule
        numbersModule.addSymbol(IntrinsicMethodInstance(left:"TYPE","+",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        numbersModule.addSymbol(IntrinsicMethodInstance(left:"TYPE","-",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        numbersModule.addSymbol(IntrinsicMethodInstance(left:"TYPE","*",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        numbersModule.addSymbol(IntrinsicMethodInstance(left:"TYPE","/",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        numbersModule.addSymbol(IntrinsicMethodInstance(left:"TYPE","%",right:"TYPE",out:"TYPE").where("TYPE",self.number).intrinsicMethod)
        numbersModule.addSymbol(LibraryMethodInstance(left:self.float,"truncate",right:self.float,out:self.integer).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance(left:self.float,"ceiling",right:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance(left:self.float,"floor",right:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance(left:self.float,"round",right:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("sin",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("cos",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("tan",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("asin",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("acos",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("atan",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("ln",arg:self.float,out:self.float).libraryMethod)
        numbersModule.addSymbol(LibraryMethodInstance("exp",arg:self.float,out:self.float).libraryMethod)
        let printing = self.printingModule
        printing.addSymbol(LibraryMethodInstance("print",self.integer).libraryMethod)
        printing.addSymbol(LibraryMethodInstance("print",self.float).libraryMethod)
        printing.addSymbol(LibraryMethodInstance("print",self.string).libraryMethod)
        printing.addSymbol(LibraryMethodInstance("print",self.boolean).libraryMethod)
        printing.addSymbol(LibraryMethodInstance("print",self.object).libraryMethod)
        let streams = self.streamsModule
        streams.addSymbol(LibraryMethodInstance("next",self.readStream,"TYPE",self.integer).where("TYPE",self.object).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPut",self.writeStream,"TYPE",self.integer).where("TYPE",self.object).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("open",self.string,self.string,"TYPE").where("TYPE",self.readStream).where("TYPE",self.writeStream).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("close",self.stream,self.boolean).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("tell",self.stream,self.integer).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("flush",self.stream,self.boolean).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("seek",self.stream,self.integer,self.boolean).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextLine",self.stream,self.string,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutLine",self.stream,self.string,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextByte",self.stream,self.byte,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutByte",self.stream,self.byte,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextFloat",self.stream,self.float).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutFloat",self.stream,self.float,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextInteger",self.stream,self.integer).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutInteger",self.stream,self.integer,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextString",self.stream,self.string).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutString",self.stream,self.string,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextSymbol",self.stream,self.symbol).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutSymbol",self.stream,self.symbol,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextUInteger",self.stream,self.uInteger).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutUInteger",self.stream,self.uInteger,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextDate",self.stream,self.date).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutDate",self.stream,self.date,self.void).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextTime",self.stream,self.time).libraryMethod)
        streams.addSymbol(LibraryMethodInstance("nextPutTime",self.stream,self.time,self.void).libraryMethod)
        let collections = self.collectionModule
        collections.addSymbol(LibraryMethodInstance("at",self.array,self.integer,"TYPE").libraryMethod)
        collections.addSymbol(LibraryMethodInstance("atPut",self.array,self.integer,"TYPE",self.void).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("atPutAll",self.array,self.integer,self.array,self.void).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("contains",self.array,"TYPE",self.boolean).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("containsAll",self.array,self.array,self.boolean).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("last",self.array,"TYPE").libraryMethod)
        collections.addSymbol(LibraryMethodInstance("first",self.array,"TYPE").libraryMethod)
        collections.addSymbol(LibraryMethodInstance("add",self.array,"TYPE").libraryMethod)
        collections.addSymbol(LibraryMethodInstance("addAll",self.array,self.array).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("removeAt",self.array,self.integer).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("removeAll",self.array,self.array).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("withoutFirst",self.array,self.array).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("withoutLast",self.array,self.array).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("withoutFirst",self.array,self.integer,self.array).libraryMethod)
        collections.addSymbol(LibraryMethodInstance("withoutLast",self.array,self.integer,self.array).libraryMethod)
        let strings = SymbolGroup(label:"String Methods")
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
    internal override func layout(in virtualMachine: VirtualMachine)
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
            aClass.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: virtualMachine)
            }
        for aClass in classes
            {
            aClass.layoutInMemory(in: virtualMachine)
            }
        for instance in self.methodInstances
            {
            instance.layoutInMemory(in: virtualMachine)
            }
        print("LAID OUT MEMORY")
        }
    }
