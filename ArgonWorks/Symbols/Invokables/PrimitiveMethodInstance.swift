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
        [T3AInstruction(nil, "PRIM", .literal(.integer(self.primitiveIndex)), .none, .none)]
        }
        
    public var primitiveIndex:Argon.Integer = 0
    
    convenience init(label: Label,parameters: Parameters,returnType:Type)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType
        }
        
    public override func deepCopy() -> Self
        {
        PrimitiveMethodInstance(label: self.label,parameters: self.parameters.map{$0.deepCopy()},returnType: self.returnType.deepCopy()) as! Self
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.type = TypeFunction(types: self.parameters.map{$0.type},returnType: self.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        }
 
    public override func emitCode(into buffer: T3ABuffer, using: CodeGenerator) throws
        {
        buffer.append("PRIM",.literal(.integer(self.primitiveIndex)),.none,.none)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.parameters.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }
