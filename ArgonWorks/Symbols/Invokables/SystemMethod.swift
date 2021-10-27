//
//  SystemMethod.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import Foundation

public class SystemMethod:Method
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }

public class Primitive
    {
    var method: SystemMethod
        {
        let method = SystemMethod(label: self.label)
        var parameters = Parameters()
        if self.left.isNotNil
            {
            parameters.append(Parameter(label: "left", type: self.left!))
            }
        if self.right.isNotNil
            {
            parameters.append(Parameter(label: "right", type: self.right!))
            }
        let instance = PrimitiveMethodInstance(label: self.label, parameters: parameters, returnType: self.out)
        method.addInstance(instance)
        return(method)
        }
        
    var instance: MethodInstance
        {
        var parameters = Parameters()
        if self.left.isNotNil
            {
            parameters.append(Parameter(label: "left", type: self.left!))
            }
        if self.right.isNotNil
            {
            parameters.append(Parameter(label: "right", type: self.right!))
            }
        let instance = PrimitiveMethodInstance(label: self.label, parameters: parameters, returnType: self.out)
        return(instance)
        }
        
    let left: Type?
    let label: String
    let right: Type?
    let out: Type
    
    init(_ label: String,arg: String,out: String)
        {
        self.left = .genericClassParameter(GenericClassParameter(arg))
        self.label = label
        self.right = nil
        self.out = .genericClassParameter(GenericClassParameter(out))
        }
        
    init(_ label: String,arg: Class,out: Class)
        {
        self.left = .class(arg)
        self.label = label
        self.right = nil
        self.out = .class(out)
        }
        
    init(_ label: String,_ arg: Class,_ out: Class)
        {
        self.left = .class(arg)
        self.label = label
        self.right = nil
        self.out = .class(out)
        }
        
    init(_ label: String,_ out: Class)
        {
        self.left = nil
        self.label = label
        self.right = nil
        self.out = .class(out)
        }
        
    init(_ label: String,left: Class)
        {
        self.left = left.type
        self.label = label
        self.right = nil
        self.out = .class(VoidClass.voidClass)
        }
        
    init(_ label: String,left: Class,right: Class)
        {
        self.left = left.type
        self.label = label
        self.right = right.type
        self.out = .class(VoidClass.voidClass)
        }
        
    init(_ label: String,_ left:Class,_ right:String,_ out: Class)
        {
        self.left = .class(left)
        self.label = label
        self.right = .genericClassParameter(GenericClassParameter(right))
        self.out = .class(out)
        }
        
    init(_ label: String,_ left:Class,_ right:Class,_ out: Class)
        {
        self.left = .class(left)
        self.label = label
        self.right = .class(right)
        self.out = .class(out)
        }
    }
