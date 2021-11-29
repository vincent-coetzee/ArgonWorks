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
    var method: SystemInfixOperator
        {
        let method = SystemInfixOperator(self.operation)
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: [Parameter(label: "a", type: self.left),Parameter(label: "b", type: self.right)], returnType: self.out)
        method.addInstance(instance)
        return(method)
        }
        
    var instance: MethodInstance
        {
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: [Parameter(label: "a", type: self.left),Parameter(label: "b", type: self.right)], returnType: self.out)
        return(instance)
        }
        
    let left: Type
    let operation: Token.Operator
    let right: Type
    let out: Type
    
    init(left: String,_ op: String,right: String,out: String)
        {
        self.left = TypeVariable(label: left)
        self.operation = Token.Operator(op)
        self.right = right == left ? self.left : TypeVariable(label: right)
        self.out = out == left ? self.left : ( out == right ? self.right : TypeVariable(label: out))
        }
        
    init(_ a:Type,_ op:String,_ b:Type,_ out:Type)
        {
        self.left = a
        self.right = b == a ? a : b
        self.out = out == a ? a : (out == b ? b : out)
        self.operation = Token.Operator(op)
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
    var method: SystemPrefixOperator
        {
        let method = SystemPrefixOperator(self.operation)
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: [Parameter(label: "a", type: self.left)], returnType: self.out)
        method.addInstance(instance)
        return(method)
        }
        
    let left: Type
    let operation: Token.Operator
    let right: Type?
    let out: Type
    
    init(_ op: String,_ left: Type,_ right: Type? = nil,out: Class)
        {
        let r = right == left ? left : right
        self.left = left
        self.operation = Token.Operator(op)
        self.right = right.isNil ? nil : r
        self.out = out.type
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
    var method: SystemPostfixOperator
        {
        let method = SystemPostfixOperator(self.operation)
        var parms = [Parameter(label: "a", type: self.left)]
        if self.right.isNotNil
            {
            parms.append(Parameter(label: "b", type: self.right!))
            }
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: parms, returnType: self.out)
        method.addInstance(instance)
        return(method)
        }
        
    let left: Type
    let operation: Token.Operator
    let right: Type?
    let out: Type
    
    init(_ op: String,_ left: Type,_ right: Type? = nil,out: Type)
        {
        self.left = left
        self.operation = Token.Operator(op)
        self.right = right.isNil ? nil : (right! == left ? left : right!)
        self.out = out
        }
    }
