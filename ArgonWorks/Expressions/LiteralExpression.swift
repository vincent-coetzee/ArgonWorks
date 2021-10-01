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
                coder.encode(11,forKey:"kind")
                coder.encode(method,forKey:"method")
            case .constant(let constant):
                coder.encode(12,forKey:"kind")
                coder.encode(constant,forKey:"constant")
            case .enumerationCase(let aCase):
                coder.encode(13,forKey:"kind")
                coder.encode(aCase,forKey:"enumerationCasee")
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
        
        
    private let literal:Literal

    public override var resultType: Type
        {
        switch(self.literal)
            {
            case .nil:
                return(TopModule.shared.argonModule.nilClass.type)
            case .integer:
                return(TopModule.shared.argonModule.integer.type)
            case .float:
                return(TopModule.shared.argonModule.float.type)
            case .string:
                return(TopModule.shared.argonModule.string.type)
            case .boolean:
                return(TopModule.shared.argonModule.boolean.type)
            case .symbol:
                return(TopModule.shared.argonModule.symbol.type)
            case .array:
                return(TopModule.shared.argonModule.array.type)
            case .class:
                return(TopModule.shared.argonModule.class.type)
            case .module:
                return(TopModule.shared.argonModule.module.type)
            case .enumeration:
                return(TopModule.shared.argonModule.enumeration.type)
            case .enumerationCase:
                return(TopModule.shared.argonModule.enumerationCase.type)
            case .method:
                return(TopModule.shared.argonModule.method.type)
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
        
    public override func scopedExpression(for child: String) -> Expression?
        {
        switch(self.literal)
            {
            case .class(let aClass):
                if let symbol = aClass.lookup(label: child)
                    {
                    return(SymbolExpression(symbol: symbol))
                    }
                return(nil)
            case .module(let module):
                if let aClass = module.lookup(label: child) as? Class
                    {
                    return(LiteralExpression(.class(aClass)))
                    }
                else if let aSlot = module.lookup(label: child) as? Slot
                    {
                    return(SlotExpression(self, slot: SlotSelectorExpression(selector: aSlot.label)))
                    }
                else if let aModule = module.lookup(label: child) as? Module
                    {
                    return(LiteralExpression(.module(aModule)))
                    }
                else if let aMethod = module.lookup(label: child) as? Method
                    {
                    return(LiteralExpression(.method(aMethod)))
                    }
                else if let anEnumeration = module.lookup(label: child) as? Enumeration
                    {
                    return(LiteralExpression(.enumeration(anEnumeration)))
                    }
                else
                    {
                    return(nil)
                    }
            case .enumeration(let enumeration):
                if let symbol = enumeration.lookup(label: child) as? EnumerationCase
                    {
                    return(LiteralExpression(.enumerationCase(symbol)))
                    }
                return(nil)
            default:
                return(nil)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let register = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        switch(self.literal)
            {
            case .nil:
                instance.append(.LOAD,.absolute(0),.none,.register(register))
            case .integer(let integer):
                instance.append(.LOAD,.integer(integer),.none,.register(register))
            case .float(let float):
                instance.append(.LOAD,.float(float),.none,.register(register))
            case .string(let string):
                instance.append(.LOAD,.relocation(.string(string)),.none,.register(register))
            case .boolean(let boolean):
                instance.append(.LOAD,.integer(boolean == .trueValue ? 1 : 0),.none,.none)
            case .symbol(let string):
                instance.append(.LOAD,.relocation(.symbol(string)),.none,.register(register))
            case .array:
                fatalError()
            case .class(let aClass):
                instance.append(.LOAD,.relocation(.class(aClass)),.none,.register(register))
            case .module(let module):
                instance.append(.LOAD,.relocation(.module(module)),.none,.register(register))
            case .enumeration(let enumeration):
                instance.append(.LOAD,.relocation(.enumeration(enumeration)),.none,.register(register))
            case .enumerationCase(let enumerationCase):
                instance.append(.LOAD,.relocation(.enumerationCase(enumerationCase)),.none,.register(register))
            case .method(let method):
                instance.append(.LOAD,.relocation(.method(method)),.none,.register(register))
            case .constant(let constant):
                instance.append(.LOAD,.relocation(.constant(constant)),.none,.register(register))
            }
        self._place = .register(register)
        }
    }
