//
//  PrimitiveMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class PrimitiveMethodInstance: MethodInstance
    {
    public override var instructions: Array<T3AInstruction>
        {
        [T3AInstruction(nil, "PRIM", .literal(.string(self.label)), .none, .none)]
        }
        
    convenience init(label: Label,parameters: Parameters,returnType:Type? = nil)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType ?? .class(VoidClass.voidClass)
        }
        
    public override func emitCode(into buffer: T3ABuffer, using: CodeGenerator) throws
        {
        buffer.append("PRIM",.literal(.string(self.label)),.none,.none)
        }
    }
