//
//  LiteralExpression.swift
//  LiteralExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public indirect enum Literal:Hashable,Displayable
    {
    public var type: Type?
        {
        return(LiteralExpression(self).type)
        }
        
    public var sizeInBytes: Int
        {
        Argon.kWordSizeInBytesInt
        }
        
    public var wordValue: Word
        {
       switch(self)
            {
            case .nil:
                return(0)
            case .integer(let integer):
                return(Word(integer: integer))
            case .float(let float):
                return(Word(float: float))
            case .string(let string):
                return(string.memoryAddress)
            case .boolean(let boolean):
                return(Word(boolean: boolean == .trueValue))
            case .symbol(let symbol):
                return(symbol.memoryAddress)
            case .array(let array):
                return(array.memoryAddress)
            case .class(let aClass):
                return(aClass.memoryAddress)
            case .module(let module):
                return(module.memoryAddress)
            case .enumeration(let enumeration):
                return(enumeration.memoryAddress)
            case .enumerationCase(let aCase):
                return(aCase.memoryAddress)
//            case .method(let method):
//                return("\(method.label)")
            case .function(let function):
                return(function.memoryAddress)
            case .constant(let constant):
                return(constant.memoryAddress)
            case .address(let constant):
                return(constant)
            case .date(let constant):
                return(constant)
            case .time(let constant):
                return(constant)
            case .dateTime(let constant):
                return(constant)
            case .byte(let byte):
                return(Word(byte: byte))
            case .character(let constant):
                return(Word(character: constant))
            }
        }
        
    case `nil`
    case integer(Argon.Integer)
    case float(Argon.Float)
    case string(StaticString)
    case boolean(Argon.Boolean)
    case symbol(StaticSymbol)
    case character(Argon.Character)
    case byte(Argon.Byte)
    case array(StaticArray)
    case `class`(TypeClass)
    case module(Module)
    case enumeration(TypeEnumeration)
    case enumerationCase(EnumerationCase)
    case constant(Constant)
    case function(Function)
    case address(Address)
    case date(Argon.Date)
    case time(Argon.Time)
    case dateTime(Argon.DateTime)
    
    init(integer: Int)
        {
        self = .integer(Argon.Integer(integer))
        }
        
//    init(type: Type)
//        {
//        self = type.literal
//        }
        
//    init(coder: NSCoder,forKey: String)
//        {
//        let kind = coder.decodeInteger(forKey: "kind")
//        switch(kind)
//            {
//            case 1:
//                self = .nil
//            case 2:
//                self = .integer(Argon.Integer(coder.decodeInteger(forKey: forKey + "integer")))
//            case 3:
//                self = .float(Argon.Float(coder.decodeDouble(forKey:forKey +  "float")))
//            case 4:
//                self = .string(coder.decodeObject(forKey: forKey + "string") as! StaticString)
//            case 5:
//                self = .boolean(coder.decodeBool(forKey: forKey + "boolean") ? .trueValue : .falseValue)
//            case 6:
//                self = .symbol(coder.decodeObject(forKey: forKey + "symbol") as! StaticSymbol)
//            case 7:
//                self = .array(coder.decodeObject(forKey: forKey + "array") as! StaticArray)
//            case 8:
//                self = .class(coder.decodeObject(forKey: forKey + "class") as! Class)
//            case 9:
//                self = .module(coder.decodeObject(forKey: forKey + "module") as! Module)
//            case 10:
//                self = .enumeration(coder.decodeObject(forKey: forKey + "enumeration") as! Enumeration)
//            case 11:
//                self = .enumerationCase(coder.decodeObject(forKey: forKey + "enumerationCase") as! EnumerationCase)
////            case 12:
////                self = .method(coder.decodeObject(forKey: forKey + "method") as! Method)
//            case 13:
//                self = .constant(coder.decodeObject(forKey: forKey + "constant") as! Constant)
//            case 14:
//                self = .function(coder.decodeObject(forKey: forKey + "function") as! Function)
//            case 15:
//                self = .address(Address(coder.decodeInteger(forKey: forKey + "address")))
//            default:
//                self = .nil
//            }
//        }
        
    public var displayString: String
        {
       switch(self)
            {
            case .nil:
                return("nil")
            case .integer(let integer):
                return("\(integer)")
            case .byte(let byte):
                return("\(byte)")
            case .character(let integer):
                return("\(integer)")
            case .float(let float):
                return("\(float)")
            case .string(let string):
                return("\(string)")
            case .boolean(let boolean):
                return("\(boolean)")
            case .symbol(let symbol):
                return("\(symbol)")
            case .array(let array):
                return("\(array.displayString)")
            case .class(let aClass):
                return("\(aClass.label)")
            case .module(let module):
                return("\(module.label)")
            case .enumeration(let enumeration):
                return("\(enumeration.label)")
            case .enumerationCase(let aCase):
                return("\(aCase.label)")
//            case .method(let method):
//                return("\(method.label)")
            case .function(let function):
                return("\(function.label)")
            case .constant(let constant):
                return("\(constant.label)")
            case .address(let constant):
                return("\(constant)")
            case .date(let constant):
                return(constant.displayString)
            case .time(let constant):
                return(constant.displayString)
            case .dateTime(let constant):
                return(constant.displayString)
            }
        }
        
//    public func encode(with coder:NSCoder,forKey: String)
//        {
//        switch(self)
//            {
//            case .nil:
//                coder.encode(1,forKey:forKey + "kind")
//            case .integer(let integer):
//                coder.encode(2,forKey:forKey + "kind")
//                coder.encode(integer,forKey:forKey + "integer")
//            case .float(let float):
//                coder.encode(3,forKey:forKey + "kind")
//                coder.encode(float,forKey:forKey + "float")
//            case .string(let string):
//                coder.encode(4,forKey:forKey + "kind")
//                coder.encode(string,forKey:forKey + "string")
//            case .boolean(let boolean):
//                coder.encode(5,forKey:forKey + "kind")
//                coder.encode(boolean,forKey:forKey + "boolean")
//            case .symbol(let symbol):
//                coder.encode(6,forKey:forKey + "kind")
//                coder.encode(symbol,forKey:forKey + "symbol")
//            case .array(let array):
//                coder.encode(7,forKey:forKey + "kind")
//                coder.encode(array,forKey: forKey + "array")
//            case .class(let aClass):
//                coder.encode(8,forKey:forKey + "kind")
//                coder.encode(aClass,forKey:forKey + "class")
//            case .module(let module):
//                coder.encode(9,forKey:forKey + "kind")
//                coder.encode(module,forKey:forKey + "module")
//            case .enumeration(let enumeration):
//                coder.encode(10,forKey:forKey + "kind")
//                coder.encode(enumeration,forKey:forKey + "enumeration")
////            case .method(let method):
////                coder.encode(12,forKey:forKey + "kind")
////                coder.encode(method,forKey:forKey + "method")
//            case .constant(let constant):
//                coder.encode(13,forKey:forKey + "kind")
//                coder.encode(constant,forKey:forKey + "constant")
//            case .enumerationCase(let aCase):
//                coder.encode(11,forKey:forKey + "kind")
//                coder.encode(aCase,forKey:forKey + "enumerationCase")
//            case .function(let aCase):
//                coder.encode(14,forKey:forKey + "kind")
//                coder.encode(aCase,forKey:forKey + "function")
//            case .address(let aCase):
//                coder.encode(15,forKey:forKey + "kind")
//                coder.encode(Int(aCase),forKey:forKey + "address")
//            }
//        }
        
    public func type(inContext context: TypeContext) -> Type?
        {
       switch(self)
            {
            case .nil:
                return(ArgonModule.shared.null)
            case .integer:
                return(ArgonModule.shared.integer)
            case .float:
                return(ArgonModule.shared.float)
            case .byte:
                return(ArgonModule.shared.byte)
            case .character:
                return(ArgonModule.shared.character)
            case .string:
                return(ArgonModule.shared.string)
            case .boolean:
                return(ArgonModule.shared.boolean)
            case .symbol:
                return(ArgonModule.shared.symbol)
            case .array(let array):
                return(array.type(inContext: context))
            case .class:
                return(ArgonModule.shared.classType)
            case .module:
                return(ArgonModule.shared.moduleType)
            case .enumeration(let enumeration):
                return(TypeEnumeration(label: enumeration.label,generics: enumeration.generics))
            case .enumerationCase:
                return(ArgonModule.shared.enumerationCase)
//            case .method(let instance):
//                return(TypeFunction(label: instance.fullName.displayString,method: instance))
//                fatalError()
            case .function(let function):
                return(TypeFunction(label: function.label,types: function.parameters.map{$0.type},returnType: function.returnType))
            case .constant(let constant):
                return(constant.type)
            case .address:
                return(ArgonModule.shared.integer)
            case .date:
                return(ArgonModule.shared.date)
            case .dateTime:
                return(ArgonModule.shared.dateTime)
            case .time:
                return(ArgonModule.shared.time)
            }
        }
        
    public func display(indent: String)
        {
        print("\(indent)LITERAL \(self) \(self.type.displayString)")
        }
        
    public func substitute(from substitution: TypeContext.Substitution) -> Literal
        {
       switch(self)
            {
            case .nil:
                return(self)
            case .integer:
                return(self)
            case .float:
                return(self)
            case .string:
                return(self)
            case .byte:
                return(self)
            case .character:
                return(self)
            case .boolean:
                return(self)
            case .symbol:
                return(self)
            case .array:
                return(self)
            case .date:
                return(self)
            case .time:
                return(self)
            case .dateTime:
                return(self)
            case .class(let aClass):
                return(.class(substitution.substitute(aClass) as! TypeClass))
            case .module(let module):
                return(.module(substitution.substitute(module) as! Module))
            case .enumeration(let enumeration):
                return(.enumeration(substitution.substitute(enumeration)))
            case .enumerationCase(let aCase):
                return(.enumerationCase(substitution.substitute(aCase)))
//            case .method(let instance):
//                return(.method(substitution.substitute(instance) as! Method))
            case .function(let function):
                return(.function(substitution.substitute(function) as! Function))
            case .constant(let constant):
                return(.constant(substitution.substitute(constant) as! Constant))
           case .address(let constant):
                return(.address(constant))
            }
        }
    }

public class LiteralExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.literal)")
        }
        
    public var isStringLiteral: Bool
        {
        switch(self.literal)
            {
            case .string:
                return(true)
            default:
                return(false)
            }
        }
        
    public override var isEnumerationExpression: Bool
        {
        switch(self.literal)
            {
            case .enumeration:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isIntegerLiteral: Bool
        {
        switch(self.literal)
            {
            case .integer:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isClassLiteral: Bool
        {
        switch(self.literal)
            {
            case .class:
                return(true)
            default:
                return(false)
            }
        }
        
//    public var isMethodLiteral: Bool
//        {
//        switch(self.literal)
//            {
//            case .method:
//                return(true)
//            default:
//                return(false)
//            }
//        }
        
    public var isSymbolLiteral: Bool
        {
        switch(self.literal)
            {
            case .symbol:
                return(true)
            default:
                return(false)
            }
        }
        
    public var symbolLiteral: Argon.Symbol
        {
        switch(self.literal)
            {
            case .symbol(let symbol):
                return(symbol.string)
            default:
                fatalError("Should not have been called")
            }
        }
        
    public var stringLiteral: String
        {
        switch(self.literal)
            {
            case .string(let symbol):
                return(symbol.string)
            default:
                fatalError("Should not have been called")
            }
        }
//
//    public var methodLiteral: Method
//        {
//        switch(self.literal)
//            {
//            case .method(let symbol):
//                return(symbol)
//            default:
//                fatalError("Should not have been called")
//            }
//        }
        
    public var classLiteral: TypeClass
        {
        switch(self.literal)
            {
            case .class(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
    public override var enumerationCase: EnumerationCase
        {
        switch(self.literal)
            {
            case .enumerationCase(let aCase):
                return(aCase)
            default:
                fatalError()
            }
        }
        
    public var integerLiteral: Argon.Integer
        {
        switch(self.literal)
            {
            case .integer(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
    public override var isLiteralExpression: Bool
        {
        return(true)
        }
        
    public override var isEnumerationCaseExpression: Bool
        {
        switch(self.literal)
            {
            case .enumerationCase:
                return(true)
            default:
                return(false)
            }
        }
        
    public override var canBeScoped: Bool
        {
        switch(self.literal)
            {
            case .class:
                fallthrough
            case .module:
                fallthrough
            case .enumeration:
                return(true)
            default:
                return(false)
            }
        }
        
        
    public let literal:Literal

//    init(_ type:Type)
//        {
//        self.literal = Literal(type: type)
//        super.init()
//        }
        
    init(_ literal:Literal)
        {
        self.literal = literal
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.literal = coder.decodeLiteral(forKey: "literal")
        super.init(coder: coder)
        }
    
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encodeLiteral(self.literal,forKey: "literal")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try visitor.accept(self)
        }
    
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
       switch(self.literal)
            {
            case .nil:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.null,origin: .expression(self)))
            case .date:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.date,origin: .expression(self)))
            case .time:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.time,origin: .expression(self)))
            case .byte:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.byte,origin: .expression(self)))
            case .character:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.character,origin: .expression(self)))
            case .dateTime:
                context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.dateTime,origin: .expression(self)))
            case .integer:
                context.append(TypeConstraint(left: self.type,right: context.integerType,origin: .expression(self)))
            case .address:
                context.append(TypeConstraint(left: self.type,right: context.integerType,origin: .expression(self)))
            case .float:
                context.append(TypeConstraint(left: self.type,right: context.floatType,origin: .expression(self)))
            case .string:
                context.append(TypeConstraint(left: self.type,right: context.stringType,origin: .expression(self)))
            case .boolean:
                context.append(TypeConstraint(left: self.type,right: context.booleanType,origin: .expression(self)))
            case .symbol:
                context.append(TypeConstraint(left: self.type,right: context.symbolType,origin: .expression(self)))
            case .array:
                let aType = self.literal.type(inContext: context)
                context.append(TypeConstraint(left: self.type,right: aType,origin: .expression(self)))
            case .class(let aClass):
                    let aType = TypeClass(label: aClass.label,generics: aClass.generics)
                context.append(TypeConstraint(left: self.type,right: aType,origin: .expression(self)))
            case .module:
                context.append(TypeConstraint(left: self.type,right: context.moduleType,origin: .expression(self)))
            case .enumeration(let enumeration):
                context.append(TypeConstraint(left: self.type,right: enumeration.type,origin: .expression(self)))
            case .enumerationCase(let aCase):
                context.append(TypeConstraint(left: self.type,right: aCase.type,origin: .expression(self)))
//            case .method(let method):
//                context.append(TypeConstraint(left: self.type,right: method.type,origin: .expression(self)))
            case .function(let function):
                context.append(TypeConstraint(left: self.type,right: function.type,origin: .expression(self)))
            case .constant(let constant):
                context.append(TypeConstraint(left: self.type,right: constant.type,origin: .expression(self)))
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        switch(self.literal)
            {
            case .nil:
                self.type = ArgonModule.shared.null
            case .date:
                self.type = ArgonModule.shared.date
            case .dateTime:
                self.type = ArgonModule.shared.dateTime
            case .time:
                self.type = ArgonModule.shared.time
            case .byte:
                self.type = ArgonModule.shared.byte
            case .character:
                self.type = ArgonModule.shared.character
            case .integer:
                self.type = context.integerType
            case .address:
                self.type = context.integerType
            case .float:
                self.type = context.floatType
            case .string:
                self.type = context.stringType
            case .boolean:
                self.type = context.booleanType
            case .symbol:
                self.type = context.symbolType
            case .array(let array):
                self.type = array.type(inContext: context)
            case .class(let aClass):
                    self.type = aClass.type
            case .module(let module):
                self.type = module.type
            case .enumeration(let enumeration):
                self.type = enumeration.type
            case .enumerationCase(let aCase):
                self.type = aCase.type
//            case .method(let method):
//                self.type = method.type
            case .function(let function):
                self.type = function.type
            case .constant(let constant):
                self.type = constant.type
            }
        }
        
    public override func display(indent: String)
        {
        print("\(indent)LITERAL \(self.literal) \(self.type.displayString)")
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        switch(self.literal)
            {
            case .class(let aClass):
                if aClass.isGenericClass
                    {
                    analyzer.cancelCompletion()
                    analyzer.dispatchError(at: self.declaration!, message: "This class literal is an uninstanciated class and must be instanciated before it can be used.")
                    }
            default:
                break
            }
        }
        
    public override func lookupSlot(selector: String) -> Slot?
        {
        switch(self.literal)
            {
            case .module(let module):
                return(module.lookupSlot(label: selector))
            case .class:
//                return(aClass.lookupSlot(label: selector))
                fatalError()
            default:
                return(nil)
            }
        }
        
    public override func substitute(from: TypeContext.Substitution) -> Self
        {
        LiteralExpression(self.literal.substitute(from: from)) as! Self
        }
        
    public override func emitAddressCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
       let temp = instance.nextTemporary
        switch(self.literal)
            {
            case .nil:
                fatalError("Can not emit LValue of nil")
            case .integer:
                fatalError("Can not emit LValue of integer")
            case .float:
                fatalError("Can not emit LValue of float")
            case .date:
                fatalError("Can not emit LValue of date")
            case .dateTime:
                fatalError("Can not emit LValue of dateTime")
            case .byte:
                fatalError("Can not emit LValue of byte")
            case .character:
                fatalError("Can not emit LValue of character")
            case .time:
                fatalError("Can not emit LValue of time")
            case .address(let address):
                instance.add(.MOVE,.address(address),temp)
            case .string(let staticString):
                assert(staticString.memoryAddress != 0,"StaticArray memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticString.memoryAddress),temp)
            case .boolean(let boolean):
                instance.add(.MOVE,.integer(Argon.Integer(boolean == .trueValue ? 1 : 0)),temp)
            case .symbol(let staticSymbol):
                assert(staticSymbol.memoryAddress != 0,"StaticSymbol memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticSymbol.memoryAddress),temp)
            case .array(let staticArray):
                assert(staticArray.memoryAddress != 0,"StaticArray memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticArray.memoryAddress),temp)
            case .class(let aClass):
                assert(aClass.memoryAddress != 0,"Class \(aClass.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(aClass.memoryAddress),temp)
            case .module(let module):
                assert(module.memoryAddress != 0,"Module \(module.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(module.memoryAddress),temp)
            case .enumeration(let enumeration):
                assert(enumeration.memoryAddress != 0,"Enumeration \(enumeration.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(enumeration.memoryAddress),temp)
            case .enumerationCase(let enumerationCase):
                 instance.add(.MOVE,.address(enumerationCase.memoryAddress),temp)
//            case .method(let method):
//                 instance.append("LOAD",.method(method)),.none,temp)
            case .constant(let constant):
                 instance.add(.MOVE,.address(constant.memoryAddress),temp)
            case .function(let function):
                assert(function.memoryAddress != 0,"Function \(function.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(function.memoryAddress),temp)
            }
        self._place = temp
        }
        
    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.emitCode(into: into,using: using)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
       let temp = instance.nextTemporary
        switch(self.literal)
            {
            case .address(let address):
                instance.add(.MOVE,.address(address),temp)
            case .nil:
                instance.add(.MOVE,.integer(0),temp)
            case .date(let date):
                instance.add(.MOVE,.integer(Argon.Integer(word: date)),temp)
            case .dateTime(let date):
                instance.add(.MOVE,.integer(Argon.Integer(word: date)),temp)
            case .byte(let byte):
                instance.add(.MOVE,.integer(Argon.Integer(Word(byte: byte))),temp)
            case .character(let character):
                instance.add(.MOVE,.integer(Argon.Integer(Word(character: character))),temp)
            case .time(let date):
                instance.add(.MOVE,.integer(Argon.Integer(word: date)),temp)
            case .integer(let integer):
                instance.add(.MOVE,.integer(Argon.Integer(integer)),temp)
            case .float(let float):
                instance.add(.MOVE,.float(float),temp)
            case .string(let staticString):
                assert(staticString.memoryAddress != 0,"StaticArray memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticString.memoryAddress),temp)
            case .boolean(let boolean):
                instance.add(.MOVE,.integer(Argon.Integer(boolean == .trueValue ? 1 : 0)),temp)
            case .symbol(let staticSymbol):
                assert(staticSymbol.memoryAddress != 0,"StaticSymbol memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticSymbol.memoryAddress),temp)
            case .array(let staticArray):
                assert(staticArray.memoryAddress != 0,"StaticArray memoryAddress == 0, this means it was probably not in the static table and so did have an address allocated.")
                instance.add(.MOVE,.address(staticArray.memoryAddress),temp)
            case .class(let aClass):
                assert(aClass.memoryAddress != 0,"Class \(aClass.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(aClass.memoryAddress),temp)
            case .module(let module):
                assert(module.memoryAddress != 0,"Module \(module.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(module.memoryAddress),temp)
            case .enumeration(let enumeration):
                assert(enumeration.memoryAddress != 0,"Enumeration \(enumeration.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(enumeration.memoryAddress),temp)
            case .enumerationCase(let enumerationCase):
                 instance.add(.MOVE,.address(enumerationCase.memoryAddress),temp)
//            case .method(let method):
//                 instance.append("LOAD",.method(method)),.none,temp)
            case .constant(let constant):
                 instance.add(.MOVE,.address(constant.memoryAddress),temp)
            case .function(let function):
                assert(function.memoryAddress != 0,"Function \(function.label) memoryAddress == 0.")
                 instance.add(.MOVE,.address(function.memoryAddress),temp)
            }
        self._place = temp
        }
    }
