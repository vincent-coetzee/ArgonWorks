//
//  Operator.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public typealias ParameterTuple = (Label,Type)
    
public typealias Operators = Array<Operator>

public enum Condition
    {
    case `in`(Type,[Type])
    case subtype(Type,Type)
    }
    
public struct ParameterReferenceType
    {
    public let referenceType: ReferenceType
    public let type: Type
    
    public static func byReference(_ type: Type) -> ParameterReferenceType
        {
        ParameterReferenceType(referenceType: .reference, type: type)
        }
        
    public static func byValue(_ type: Type) -> ParameterReferenceType
        {
        ParameterReferenceType(referenceType: .value, type: type)
        }
    }
    
public class Operator: MethodInstance
    {
    public static func `prefix`(_ label: Label,_ lhs: Type,_ returnType: Type,_ argonModule: ArgonModule) -> Operator
        {
        let parameters = [Parameter(label: "left", relabel: nil, type: lhs, isVisible: false, isVariadic: false)]
        let method = Operator(label: label,argonModule: argonModule)
        method.parameters = parameters
        method.returnType = returnType
        method.operatorType = .prefix
        return(method)
        }
        
    public static func `infix`(_ label: Label,_ lhs: Type,_ rhs: Type,_ returnType: Type,_ argonModule: ArgonModule) -> Operator
        {
        let parameters = [Parameter(label: "left", relabel: nil, type: lhs, isVisible: false, isVariadic: false),Parameter(label: "right", relabel: nil, type: rhs, isVisible: false, isVariadic: false)]
        let method = Operator(label: label,argonModule: argonModule)
        method.parameters = parameters
        method.returnType = returnType
        method.operatorType = .infix
        return(method)
        }
        
    public static func `postfix`(_ label: Label,_ lhs: Type,_ returnType: Type,_ argonModule: ArgonModule) -> Operator
        {
        let parameters = [Parameter(label: "left", relabel: nil, type: lhs, isVisible: false, isVariadic: false)]
        let method = Operator(label: label,argonModule: argonModule)
        method.parameters = parameters
        method.returnType = returnType
        method.operatorType = .postfix
        return(method)
        }
        
    public static func `infix`(_ label: Label,_ lhs: ParameterReferenceType,_ rhs: ParameterReferenceType,_ returnType: Type,_ argonModule: ArgonModule) -> Operator
        {
        let parameters = [Parameter(label: "left", relabel: nil, type: lhs.type, isVisible: false, isVariadic: false,referenceType: lhs.referenceType),Parameter(label: "right", relabel: nil, type: rhs.type, isVisible: false, isVariadic: false,referenceType: rhs.referenceType)]
        let method = Operator(label: label,argonModule: argonModule)
        method.parameters = parameters
        method.returnType = returnType
        method.operatorType = .infix
        return(method)
        }
        
    public static func `postfix`(_ label: Label,_ lhs: ParameterReferenceType,_ returnType: Type,_ argonModule: ArgonModule) -> Operator
        {
        let parameters = [Parameter(label: "left", relabel: nil, type: lhs.type, isVisible: false, isVariadic: false,referenceType: lhs.referenceType)]
        let method = Operator(label: label,argonModule: argonModule)
        method.parameters = parameters
        method.returnType = returnType
        method.operatorType = .postfix
        return(method)
        }
        
    public var isPrefix: Bool
        {
        self.operatorType == .prefix
        }
        
    public var isPostfix: Bool
        {
        self.operatorType == .postfix
        }
        
    public var isInfix: Bool
        {
        self.operatorType == .infix
        }
        
    public enum OperatorType
        {
        case none
        case prefix
        case infix
        case postfix
        }
        
    public private(set) var operatorType: OperatorType = .none
    public private(set) var mode: Instruction.Mode = .none
    public private(set) var opcode: Instruction.Opcode = .NOP
    public private(set) var conditions: Array<Condition> = []
    public private(set) var isGeneric: Bool = false
    
    public func primitive(_ index: Int) -> Self
        {
        return(self)
        }
        
    public func inline() -> Self
        {
        return(self)
        }
        
    public func intrinsic(_ mode: Instruction.Mode,_ opcode:Instruction.Opcode) -> Self
        {
        self.mode = mode
        self.opcode = opcode
        return(self)
        }
        
    public func `where`(_ conditions: Condition...) -> Self
        {
        self.isGeneric = true
        self.conditions = conditions
        return(self)
        }
    }
    
public class Infix
    {
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        }
        
    func triple(_ type1: Type,_ type2: Type,_ type3: Type) -> PrimitiveInfixOperatorInstance
        {
        let parameters = [Parameter(label: "n1", relabel: nil, type: type1, isVisible: false, isVariadic: false),Parameter(label: "n1", relabel: nil, type: type2, isVisible: false, isVariadic: false)]
        let returnType = type3
        let instance = PrimitiveInfixOperatorInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        return(instance)
        }
        
//    func triple(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type2:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitiveInfixOperatorInstance
//        {
//        let random = Int.random(in: 0..<1000000)
//        
//        let parameters = [type1.parameter(random),type2.parameter(random)]
//        let returnType = type3.value(random,argonModule)
//        let instance = PrimitiveInfixOperatorInstance(label: self.label)
//        instance.parameters = parameters
//        instance.returnType = returnType
//        return(instance)
//        }
        
//    public func double(_ argonModule: ArgonModule,_ type1:ArgumentType,_ type3:ArgumentType,where constraints: (String,Type)...) -> PrimitiveInfixOperatorInstance
//        {
//        let random = Int.random(in: 0..<1000000)
//
//        let parameters = [type1.parameter(random)]
//        let returnType = type3.value(random,argonModule)
//        let instance = PrimitiveInfixOperatorInstance(label: self.label)
//        instance.parameters = parameters
//        instance.returnType = returnType
//        return(instance)
//        }
        
    public func double(_ type1:Type,_ type3:Type) -> InfixInlineMethodInstance
        {
        let parameters = [Parameter(label: "a", relabel: nil, type: type1, isVisible: false, isVariadic: false),Parameter(label: "b", relabel: nil, type: type3, isVisible: false, isVariadic: false)]
        let returnType = type3
        let instance = InfixInlineMethodInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        instance.initClosure()
        return(instance)
        }
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

public class Postfix
    {
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        }
        
    public func double(_ type1:Type,_ type3:Type) -> PostfixInlineMethodInstance
        {
        let parameters = [Parameter(label: "a", relabel: nil, type: type1, isVisible: false, isVariadic: false)]
        let returnType = type3
        let instance = PostfixInlineMethodInstance(label: self.label)
        instance.parameters = parameters
        instance.returnType = returnType
        instance.initClosure()
        return(instance)
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
