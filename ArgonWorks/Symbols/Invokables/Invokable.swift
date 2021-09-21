//
//  Invokable.swift
//  Invokable
//
//  Created by Vincent Coetzee on 9/8/21.
//

import AppKit

public class Invokable: Symbol
    {
    internal var cName: String
    internal var parameters: Parameters
    public var returnType: Type = .class(VoidClass.voidClass)
    public var library:DynamicLibrary = .emptyLibrary
    
    public override var defaultColor: NSColor
        {
        NSColor.argonSeaGreen
        }
    
    public required init?(coder: NSCoder)
        {
        self.cName = coder.decodeString(forKey: "cName")!
        self.parameters = coder.decodeObject(forKey: "parameters") as! Parameters
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        self.library = coder.decodeObject(forKey: "library") as! DynamicLibrary
        super.init(coder: coder)
        }
        
    override init(label:Label)
        {
        self.cName = ""
        self.parameters = Parameters()
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.cName,forKey: "cName")
        coder.encode(self.parameters,forKey: "parameters")
        coder.encode(self.returnType,forKey: "returnType")
        coder.encode(self.library,forKey: "library")
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
    
    public static func with(label:Label,parameters parms: Parameters,returnType: Type) -> Array<SingleParameterInvokable>
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
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Array where Element == Parameter
    {
    public var second: Element
        {
        return(self[1])
        }
    }
