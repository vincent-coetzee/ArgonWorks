//
//  TypeInferencer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

public class TypeValue
    {
    }
    
public class ClassTypeValue: TypeValue
    {
    private let theClass: Class
    
    init(class: Class)
        {
        self.theClass = `class`
        }
    }

public class VariableTypeValue: TypeValue
    {
    private let name: String
    
    init(name: String)
        {
        self.name = name
        }
    }

public class ApplyTypeValue: TypeValue
    {
    private let name: String
    private let arguments: Array<TypeValue>
    private let returnType: TypeValue
    
    init(name: String,arguments: Array<TypeValue> = [],returnType: TypeValue = ClassTypeValue(class: VoidClass.voidClass))
        {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        }
    }

public typealias Environment = Dictionary<String,TypeValue>

public indirect enum TypeExpression
    {
    case integer
    case boolean
    case float
    case uinteger
    case string
    case symbol
    case character
    case byte
    case variable(String)
    case method(String,[TypeValue],TypeValue)
    case call([TypeExpression],TypeExpression)
    }
    
public struct TypeInferencer
    {
    public func infer(_ expression: TypeExpression,environment: Environment) -> TypeValue
        {
        switch(expression)
            {
            case .integer:
                return(ClassTypeValue(class: TopModule.shared.argonModule.integer))
            case .float:
                return(ClassTypeValue(class: TopModule.shared.argonModule.float))
            case .uinteger:
                return(ClassTypeValue(class: TopModule.shared.argonModule.uInteger))
            case .character:
                return(ClassTypeValue(class: TopModule.shared.argonModule.character))
            case .boolean:
                return(ClassTypeValue(class: TopModule.shared.argonModule.boolean))
            case .byte:
                return(ClassTypeValue(class: TopModule.shared.argonModule.byte))
            case .variable(let name):
                if environment[name].isNotNil
                    {
                    return(environment[name]!)
                    }
                fatalError("Unbound variable \(name)")
            default:
                fatalError("Type \(expression) is not implemented")
            }
        }
    }
