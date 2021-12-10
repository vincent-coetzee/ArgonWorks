//
//  Operator.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public typealias ParameterTuple = (Label,Type)

//public enum OperatorParameter
//    {
//    public var type: Type
//        {
//        switch(self)
//            {
//            case .class(let aClass):
//                return(aClass.type)
//            case .enumeration(let enumeration):
//                return(enumeration.type)
//            case .generic(let generic):
//                return(GenericType(generic).type)
//            default:
//                fatalError()
//            }
//        }
//        
//    case `class`(Class)
//    case enumeration(Enumeration)
//    case generic(String)
//    case classes([Class])
//    }
    
public class Operator: Method
    {
    private let operation: Token.Operator
    
    init(_ operation: Token.Operator)
        {
        self.operation = operation
        super.init(label: operation.name)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR")
        self.operation = Token.Operator(coder.decodeString(forKey: "operation")!)
        super.init(coder: coder)
//        print("END DECODE OPERATOR \(self.label)")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.operation.name,forKey:"operation")
        super.encode(with: coder)
        }
        
    public required init(label: Label)
        {
        self.operation = Token.Operator("")
        super.init(label: label)
        }

    @discardableResult
    public func instance(_ types: Array<Type>,_ type: Type? = nil) -> MethodInstance
        {
        let typeParameter = TypeContext.freshTypeVariable()
        let parameters = [Parameter(label: "a", relabel: nil, type: typeParameter, isVisible: false, isVariadic: false),Parameter(label: "b", relabel: nil, type: typeParameter, isVisible: false, isVariadic: false)]
        let instance = MethodInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = type.isNil ? typeParameter : type!
        instance.conditionalTypes = types
        self.addInstance(instance)
        return(instance)
        }
        
    @discardableResult
    public func instance(_ class1: Type,_ class2:Type,_ class3:Type) -> MethodInstance
        {
        let parameters = [Parameter(label: "a", relabel: nil, type: class1, isVisible: false, isVariadic: false),Parameter(label: "b", relabel: nil, type: class2, isVisible: false, isVariadic: false)]
        let instance = MethodInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = class3
        self.addInstance(instance)
        return(instance)
        }
        
    @discardableResult
    public func binary(_ classes:Type...) -> Method
        {
        for aClass in classes
            {
            let parameters = [Parameter(label: "lhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false),Parameter(label: "rhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false)]
            let instance = MethodInstance(label: self.label)
            instance.parameters = parameters
            instance.returnType = aClass
            self.addInstance(instance)
            }
        return(self)
        }
        
    @discardableResult
    public func binary(_ classes:Type...,result: Type) -> Method
        {
        for aClass in classes
            {
            let parameters = [Parameter(label: "lhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false),Parameter(label: "rhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false)]
            let instance = MethodInstance(label: self.label)
            instance.parameters = parameters
            instance.returnType = result
            self.addInstance(instance)
            }
        return(self)
        }
        
    @discardableResult
    public func unary(_ classes:Type...) -> Method
        {
        for aClass in classes
            {
            let parameters = [Parameter(label: "lhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false)]
            let instance = MethodInstance(label: self.label)
            instance.parameters = parameters
            instance.returnType = aClass
            self.addInstance(instance)
            }
        return(self)
        }
        
    @discardableResult
    public func unary(_ classes:Type...,result: Type) -> Method
        {
        for aClass in classes
            {
            let parameters = [Parameter(label: "lhs", relabel: nil, type: aClass, isVisible: false, isVariadic: false)]
            let instance = MethodInstance(label: self.label)
            instance.parameters = parameters
            instance.returnType = result
            self.addInstance(instance)
            }
        return(self)
        }
    }
    
public class InfixOperator: Operator
    {
    }

public class SystemInfixOperator: InfixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }
    
public class Infix
    {
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        }
        
    func triple(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type2:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitiveInfixOperatorInstance
        {
        let random = Int.random(in: 0..<1000000)
        
        let parameters = [type1.parameter(random),type2.parameter(random)]
        let returnType = type3.value(random,argonModule)
        let instance = PrimitiveInfixOperatorInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        return(instance)
        }
        
    public func double(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitiveInfixOperatorInstance
        {
        let random = Int.random(in: 0..<1000000)
        
        let parameters = [type1.parameter(random)]
        let returnType = type3.value(random,argonModule)
        let instance = PrimitiveInfixOperatorInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        return(instance)
        }
    }
    
public class PostfixOperator: Operator
    {
    }
    
public class SystemPostfixOperator: PostfixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }
    
public class PrefixOperator: Operator
    {

    }
    
public class Prefix
    {
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        }
        
    public func double(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitivePrefixOperatorInstance
        {
        let random = Int.random(in: 0..<1000000)
        
        let parameters = [type1.parameter(random)]
        let returnType = type3.value(random,argonModule)
        let instance = PrimitivePrefixOperatorInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        return(instance)
        }
    }

public class SystemPrefixOperator: PrefixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }

public class Postfix
    {
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        }
        
    public func double(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitivePostfixOperatorInstance
        {
        let random = Int.random(in: 0..<1000000)
        
        let parameters = [type1.parameter(random)]
        let returnType = type3.value(random,argonModule)
        let instance = PrimitivePostfixOperatorInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        return(instance)
        }
    }
