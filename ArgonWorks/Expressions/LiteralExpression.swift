//
//  LiteralExpression.swift
//  LiteralExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public indirect enum Literal
    {
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
    case method(Method)
    case constant(Constant)
    case function(Function)
    
    init(coder: NSCoder)
        {
        let kind = coder.decodeInteger(forKey: "kind")
        switch(kind)
            {
            case 1:
                self = .nil
            case 2:
                self = .integer(Argon.Integer(coder.decodeInteger(forKey: "integer")))
            case 3:
                self = .float(Argon.Float(coder.decodeDouble(forKey: "float")))
            case 4:
                self = .string(coder.decodeObject(forKey: "string") as! String)
            case 5:
                self = .boolean(coder.decodeBool(forKey: "boolean") ? .trueValue : .falseValue)
            case 6:
                self = .symbol(coder.decodeObject(forKey: "symbol") as! Argon.Symbol)
            case 7:
                self = .array(coder.decodeObject(forKey: "array") as! Array<Literal>)
            case 8:
                self = .class(coder.decodeObject(forKey: "class") as! Class)
            case 9:
                self = .module(coder.decodeObject(forKey: "module") as! Module)
            case 10:
                self = .enumeration(coder.decodeObject(forKey: "enumeration") as! Enumeration)
            case 11:
                self = .enumerationCase(coder.decodeObject(forKey: "enumerationCase") as! EnumerationCase)
            case 12:
                self = .method(coder.decodeObject(forKey: "method") as! Method)
            case 13:
                self = .constant(coder.decodeObject(forKey: "constant") as! Constant)
            case 14:
                self = .function(coder.decodeObject(forKey: "function") as! Function)
            default:
                self = .nil
            }
        }
        
    public func encode(with coder:NSCoder)
        {
        switch(self)
            {
            case .nil:
                coder.encode(1,forKey:"kind")
            case .integer(let integer):
                coder.encode(2,forKey:"kind")
                coder.encode(integer,forKey:"integer")
            case .float(let float):
                coder.encode(3,forKey:"kind")
                coder.encode(float,forKey:"float")
            case .string(let string):
                coder.encode(4,forKey:"kind")
                coder.encode(string,forKey:"string")
            case .boolean(let boolean):
                coder.encode(5,forKey:"kind")
                coder.encode(boolean,forKey:"boolean")
            case .symbol(let symbol):
                coder.encode(6,forKey:"kind")
                coder.encode(symbol,forKey:"symbol")
            case .array(let array):
                coder.encode(7,forKey:"kind")
                coder.encode(array,forKey:"array")
            case .class(let aClass):
                coder.encode(8,forKey:"kind")
                coder.encode(aClass,forKey:"class")
            case .module(let module):
                coder.encode(9,forKey:"kind")
                coder.encode(module,forKey:"module")
            case .enumeration(let enumeration):
                coder.encode(10,forKey:"kind")
                coder.encode(enumeration,forKey:"enumeration")
            case .method(let method):
                coder.encode(12,forKey:"kind")
                coder.encode(method,forKey:"method")
            case .constant(let constant):
                coder.encode(13,forKey:"kind")
                coder.encode(constant,forKey:"constant")
            case .enumerationCase(let aCase):
                coder.encode(11,forKey:"kind")
                coder.encode(aCase,forKey:"enumerationCase")
            case .function(let aCase):
                coder.encode(14,forKey:"kind")
                coder.encode(aCase,forKey:"function")
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
        
    public var isMethodLiteral: Bool
        {
        switch(self.literal)
            {
            case .method:
                return(true)
            default:
                return(false)
            }
        }
        
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
        
    public var methodLiteral: Method
        {
        switch(self.literal)
            {
            case .method(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
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

    public override var type: Type
        {
        switch(self.literal)
            {
            case .nil:
                return(self.compiler.argonModule.nilClass.type)
            case .integer:
                return(self.compiler.argonModule.integer.type)
            case .float:
                return(self.compiler.argonModule.float.type)
            case .string:
                return(self.compiler.argonModule.string.type)
            case .boolean:
                return(self.compiler.argonModule.boolean.type)
            case .symbol:
                return(self.compiler.argonModule.symbol.type)
            case .array:
                return(self.compiler.argonModule.array.type)
            case .class:
                return(self.compiler.argonModule.class.type)
            case .module:
                return(self.compiler.argonModule.module.type)
            case .enumeration:
                return(self.compiler.argonModule.enumeration.type)
            case .enumerationCase:
                return(self.compiler.argonModule.enumerationCase.type)
            case .method:
                return(self.compiler.argonModule.method.type)
            case .function:
                return(self.compiler.argonModule.function.type)
            case .constant(let constant):
                return(constant.type)
            }
        }

        
    init(_ literal:Literal)
        {
        self.literal = literal
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.literal = Literal(coder: coder)
        super.init(coder: coder)
        }
    
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        self.literal.encode(with: coder)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)LITERAL EXPRESSION()")
        print("\(padding)\t \(self.literal)")
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
            case .method(let method):
                 instance.append(nil,"LOAD",.relocatable(.method(method)),.none,temp)
            case .constant(let constant):
                 instance.append(nil,"LOAD",.relocatable(.constant(constant)),.none,temp)
            case .function(let constant):
                 instance.append(nil,"LOAD",.relocatable(.function(constant)),.none,temp)
            }
        self._place = temp
        }
    }
