//
//  Invokable.swift
//  Invokable
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class Invokable: Symbol
    {
    internal var cName: String
    internal var parameters: Parameters
    public var returnType: Class = VoidClass.voidClass
    public var library:DynamicLibrary = .emptyLibrary
    
    override init(label:Label)
        {
        self.cName = ""
        self.parameters = Parameters()
        super.init(label: label)
        }
        
    public func curried() -> Array<SingleParameterInvokable>
        {
        return(SingleParameterInvokable.with(label: self.label, parameters: self.parameters, returnType: self.returnType))
        }
    }
    
public class SingleParameterInvokable: Symbol
    {
    private var parameter: Parameter
    private var result: Parameter
    
    public static func with(label:Label,parameters parms: Parameters,returnType: Class) -> Array<SingleParameterInvokable>
        {
        let extra = Parameter(label:"returnType",type: returnType)
        let parameters = parms + [extra]
        var invokables = Array<SingleParameterInvokable>()
        for index in stride(from: 0, through: parameters.count, by: 2)
            {
            let parm = parameters[index]
            let value = parameters[index + 1]
            invokables.append(SingleParameterInvokable(label: label + "\(index)", parameter: parm,result: value))
            }
        return(invokables)
        }
        
    init(label:Label,parameter: Parameter,result: Parameter)
        {
        self.parameter = parameter
        self.result = result
        super.init(label: label)
        }
    }

extension Array where Element == Parameter
    {
    public var second: Element
        {
        return(self[1])
        }
    }
