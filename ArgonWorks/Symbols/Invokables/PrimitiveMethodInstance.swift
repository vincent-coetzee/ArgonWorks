//
//  PrimitiveMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class PrimitiveMethodInstance: MethodInstance
    {
    convenience init(label: Label,parameters: Parameters,returnType:Type? = nil)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType ?? .class(VoidClass.voidClass)
        }
    }
