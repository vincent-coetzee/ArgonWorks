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
        
    case `nil`
    case integer(Argon.Integer)
    case float(Argon.Float)
    case string(String)
    case boolean(Argon.Boolean)
    case symbol(Argon.Symbol)
    case array([Literal])
    case `class`(Class)
    case module(Module)
    case enumeration(Enumeration)
    case enumerationCase(EnumerationCase)
    case constant(Constant)
    case function(Function)
    
    init(integer: Int)
        {
        self = .integer(Argon.Integer(integer))
        }
        
    init(type: Type)
        {
        self = type.literal
        }
        
    init(coder: NSCoder,forKey: String)
        {
        let kind = coder.decodeInteger(forKey: "kind")
        switch(kind)
            {
            case 1:
                self = .nil
            case 2:
                self = .integer(Argon.Integer(coder.decodeInteger(forKey: forKey + "integer")))
            case 3:
                self = .float(Argon.Float(coder.decodeDouble(forKey:forKey +  "float")))
            case 4:
                self = .string(coder.decodeObject(forKey: forKey + "string") as! String)
            case 5:
                self = .boolean(coder.decodeBool(forKey: forKey + "boolean") ? .trueValue : .falseValue)
            case 6:
                self = .symbol(coder.decodeObject(forKey: forKey + "symbol") as! Argon.Symbol)
            case 7:
                let count = coder.decodeInteger(forKey: forKey + "arrayCount")
                var array = Array<Literal>()
                for index in 0..<count
                    {
                    array.append(Literal(coder: coder,forKey: forKey + "element\(index)"))
                    }
                self = .array(array)
            case 8:
                self = .class(coder.decodeObject(forKey: forKey + "class") as! Class)
            case 9:
                self = .module(coder.decodeObject(forKey: forKey + "module") as! Module)
            case 10:
                self = .enumeration(coder.decodeObject(forKey: forKey + "enumeration") as! Enumeration)
            case 11:
                self = .enumerationCase(coder.decodeObject(forKey: forKey + "enumerationCase") as! EnumerationCase)
//            case 12:
//                self = .method(coder.decodeObject(forKey: forKey + "method") as! Method)
            case 13:
                self = .constant(coder.decodeObject(forKey: forKey + "constant") as! Constant)
            case 14:
                self = .function(coder.decodeObject(forKey: forKey + "function") as! Function)
            default:
                self = .nil
            }
        }
        
    public var displayString: String
        {
       switch(self)
            {
            case .nil:
                return("nil")
            case .integer(let integer):
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
            }
        }
        
    public func encode(with coder:NSCoder,forKey: String)
        {
        switch(self)
            {
            case .nil:
                coder.encode(1,forKey:forKey + "kind")
            case .integer(let integer):
                coder.encode(2,forKey:forKey + "kind")
                coder.encode(integer,forKey:forKey + "integer")
            case .float(let float):
                coder.encode(3,forKey:forKey + "kind")
                coder.encode(float,forKey:forKey + "float")
            case .string(let string):
                coder.encode(4,forKey:forKey + "kind")
                coder.encode(string,forKey:forKey + "string")
            case .boolean(let boolean):
                coder.encode(5,forKey:forKey + "kind")
                coder.encode(boolean,forKey:forKey + "boolean")
            case .symbol(let symbol):
                coder.encode(6,forKey:forKey + "kind")
                coder.encode(symbol,forKey:forKey + "symbol")
            case .array(let array):
                coder.encode(7,forKey:forKey + "kind")
                coder.encode(array.count,forKey: forKey + "arrayCount")
                var index = 0
                for element in array
                    {
                    element.encode(with: coder,forKey: forKey + "element\(index)")
                    index += 1
                    }
            case .class(let aClass):
                coder.encode(8,forKey:forKey + "kind")
                coder.encode(aClass,forKey:forKey + "class")
            case .module(let module):
                coder.encode(9,forKey:forKey + "kind")
                coder.encode(module,forKey:forKey + "module")
            case .enumeration(let enumeration):
                coder.encode(10,forKey:forKey + "kind")
                coder.encode(enumeration,forKey:forKey + "enumeration")
//            case .method(let method):
//                coder.encode(12,forKey:forKey + "kind")
//                coder.encode(method,forKey:forKey + "method")
            case .constant(let constant):
                coder.encode(13,forKey:forKey + "kind")
                coder.encode(constant,forKey:forKey + "constant")
            case .enumerationCase(let aCase):
                coder.encode(11,forKey:forKey + "kind")
                coder.encode(aCase,forKey:forKey + "enumerationCase")
            case .function(let aCase):
                coder.encode(14,forKey:forKey + "kind")
                coder.encode(aCase,forKey:forKey + "function")
            }
        }
        
    public func type(inContext context: TypeContext) -> Type?
        {
       switch(self)
            {
            case .nil:
                return(context.nilType)
            case .integer:
                return(context.integerType)
            case .float:
                return(context.floatType)
            case .string:
                return(context.stringType)
            case .boolean:
                return(context.booleanType)
            case .symbol:
                return(context.symbolType)
            case .array(let array):
                let first = array.first!
                let elementType = first.type(inContext: context)!
                let arrayType = context.arrayType
                let arrayClass = (arrayType as! TypeClass).theClass
                return(TypeClass(class: arrayClass,generics: [elementType]))
            case .class:
                return(context.classType)
            case .module:
                return(context.moduleType)
            case .enumeration(let enumeration):
                return(TypeEnumeration(enumeration: enumeration,generics: enumeration.genericTypes))
            case .enumerationCase:
                return(context.enumerationCaseType)
//            case .method(let instance):
//                return(TypeFunction(label: instance.fullName.displayString,method: instance))
//                fatalError()
            case .function(let function):
                return(TypeFunction(label: function.label,types: function.parameters.map{$0.type!},returnType: function.returnType))
            case .constant(let constant):
                return(constant.type)
            }
        }
        
    public func display(indent: String)
        {
        print("\(indent)LITERAL \(self) \(self.type!.displayString)")
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
            case .boolean:
                return(self)
            case .symbol:
                return(self)
            case .array(let array):
                let newElements = array.map{$0.substitute(from: substitution)}
                return(.array(newElements))
            case .class(let aClass):
                return(.class(substitution.substitute(aClass) as! Class))
            case .module(let module):
                return(.module(substitution.substitute(module) as! Module))
            case .enumeration(let enumeration):
                return(.enumeration(substitution.substitute(enumeration) as! Enumeration))
            case .enumerationCase(let aCase):
                return(.enumerationCase(substitution.substitute(aCase) as! EnumerationCase))
//            case .method(let instance):
//                return(.method(substitution.substitute(instance) as! Method))
            case .function(let function):
                return(.function(substitution.substitute(function) as! Function))
            case .constant(let constant):
                return(.constant(substitution.substitute(constant) as! Constant))
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
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
    public var stringLiteral: String
        {
        switch(self.literal)
            {
            case .string(let symbol):
                return(symbol)
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
        
    public var classLiteral: Class
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

    init(_ type:Type)
        {
        self.literal = Literal(type: type)
        super.init()
        }
        
    init(_ literal:Literal)
        {
        self.literal = literal
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.literal = Literal(coder: coder,forKey: "literal")
        super.init(coder: coder)
        }
    
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        self.literal.encode(with: coder,forKey: "literal")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try visitor.accept(self)
        }
    
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
       switch(self.literal)
            {
            case .nil:
                context.append(TypeConstraint(left: self.type,right: context.nilType,origin: .expression(self)))
            case .integer:
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
                var aType: Type
                if aClass is GenericClass
                    {
                    let genericClass = aClass as! GenericClass
                    aType = TypeClass(class: aClass,generics: genericClass.types)
                    }
                else
                    {
                    aType = TypeClass(class: aClass,generics: [])
                    }
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
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        switch(self.literal)
            {
            case .nil:
                self.type = context.nilType
            case .integer:
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
                let first = array.first!
                let elementType = first.type(inContext: context)
                let arrayType = context.arrayType
                let arrayClass = (arrayType as! TypeClass).theClass
                self.type = TypeClass(class: arrayClass,generics: [elementType!])
            case .class(let aClass):
                if aClass is GenericClass
                    {
                    let genericClass = aClass as! GenericClass
                    self.type = TypeClass(class: aClass,generics: genericClass.types)
                    }
                else
                    {
                    self.type = TypeClass(class: aClass,generics: [])
                    }
            case .module:
                self.type = context.moduleType
            case .enumeration(let enumeration):
                self.type = enumeration.type!
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
        print("\(indent)LITERAL \(self.literal) \(self.type!.displayString)")
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
            case .class(let aClass):
                return(aClass.metaclass?.lookupSlot(label: selector))
            default:
                return(nil)
            }
        }
        
    public override func lookup(label child: String) -> Symbol?
        {
        switch(self.literal)
            {
            case .class(let aClass):
                if let symbol = aClass.lookup(label: child)
                    {
                    return(symbol)
                    }
                return(nil)
            case .module(let module):
                if let symbol = module.lookup(label: child)
                    {
                    return(symbol)
                    }
                else
                    {
                    return(nil)
                    }
            case .enumeration(let enumeration):
                if let symbol = enumeration.lookup(label: child)
                    {
                    return(symbol)
                    }
                return(nil)
            default:
                return(nil)
            }
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
       let temp = instance.nextTemporary()
        switch(self.literal)
            {
            case .nil:
                instance.append(nil,"LOAD",.literal(.nil),.none,temp)
            case .integer(let integer):
                instance.append(nil,"LOAD",.literal(.integer(Argon.Integer(integer))),.none,temp)
            case .float(let float):
                instance.append(nil,"LOAD",.literal(.float(float)),.none,temp)
            case .string(let string):
                instance.append(nil,"LOAD",.literal(.string(string)),.none,temp)
            case .boolean(let boolean):
                instance.append(nil,"LOAD",.literal(.boolean(boolean)),.none,temp)
            case .symbol(let string):
                instance.append(nil,"LOAD",.literal(.symbol(string)),.none,temp)
            case .array:
                fatalError()
            case .class(let aClass):
                 instance.append(nil,"LOAD",.relocatable(.class(aClass)),.none,temp)
            case .module(let module):
                 instance.append(nil,"LOAD",.relocatable(.module(module)),.none,temp)
            case .enumeration(let enumeration):
                 instance.append(nil,"LOAD",.relocatable(.enumeration(enumeration)),.none,temp)
            case .enumerationCase(let enumerationCase):
                 instance.append(nil,"LOAD",.relocatable(.enumerationCase(enumerationCase)),.none,temp)
//            case .method(let method):
//                 instance.append(nil,"LOAD",.relocatable(.method(method)),.none,temp)
            case .constant(let constant):
                 instance.append(nil,"LOAD",.relocatable(.constant(constant)),.none,temp)
            case .function(let constant):
                 instance.append(nil,"LOAD",.relocatable(.function(constant)),.none,temp)
            }
        self._place = temp
        }
    }
