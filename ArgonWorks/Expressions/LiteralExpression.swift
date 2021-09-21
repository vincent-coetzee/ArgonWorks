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
                instance.append(.LOAD,.integer(boolean == .trueValue ? 1 : 0))
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
