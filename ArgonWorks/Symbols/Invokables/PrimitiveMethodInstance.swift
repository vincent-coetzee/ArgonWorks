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
        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!},returnType: self.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.parameters.forEach{try $0.initializeTypeConstraints(inContext: context)}
        try self.returnType.initializeTypeConstraints(inContext: context)
        let parameterTypes = self.parameters.map{$0.type!}
        context.append(TypeConstraint(left: self.type,right: TypeFunction(label: self.label,types: parameterTypes, returnType: self.returnType),origin: .symbol(self)))
        }
 
    public override func emitCode(into buffer: T3ABuffer, using: CodeGenerator) throws
        {
        buffer.append("PRIM",.literal(.integer(self.primitiveIndex)),.none,.none)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PrimitiveMethodInstance(label: self.label)
        instance.primitiveIndex = self.primitiveIndex
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)PRIMITIVE METHOD INSTANCE \(self.label)")
        var index = 0
        for parameter in self.parameters
            {
            print("\(indent)\tPARAMETER[\(index)] \(parameter.label) \(parameter.type!.displayString)")
            index += 1
            }
        print("\(indent)\tRETURN TYPE \(self.returnType.displayString)")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.parameters.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }
