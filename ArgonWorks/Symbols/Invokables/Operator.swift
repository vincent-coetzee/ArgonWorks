//
//  Operator.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public typealias ParameterTuple = (Label,Type)
    
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
