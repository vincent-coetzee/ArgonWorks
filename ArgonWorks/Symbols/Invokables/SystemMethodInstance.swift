//
//  SystemMethodInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import Foundation

public class SystemMethodInstance:MethodInstance
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var isSystemMethodInstance: Bool
        {
        return(true)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        }
    }

public class IntrinsicMethodInstance: SystemMethodInstance
    {
    }

public class LibraryMethodInstance: SystemMethodInstance
    {
    public var rawFunctionName: String
        {
        var name = "M"
        let names = self.parameters.map{$0.type.label}.joined(separator: "P")
        name += "P" + names
        name += self.returnType.label
        return(name)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        }
    }
    
