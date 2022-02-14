//
//  PrimitiveMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class PrimitiveMethodInstance: MethodInstance,PrimitiveInstance
    {
    static func label(_ label:Label,_ arg1:Label,_ arg1Type: Type,ret: Type) -> PrimitiveMethodInstance
        {
        let instance = PrimitiveMethodInstance(label: label)
        instance.parameters = [Parameter(label: arg1, relabel: nil, type: arg1Type, isVisible: true, isVariadic: false)]
        instance.returnType = ret
        return(instance)
        }

//    public override var instructions: Array<T3AInstruction>
//        {
//        [T3AInstruction(.PRIM,.integer(self.primitiveIndex), .none, .none)]
//        }
        
    public var primitiveIndex:Argon.Integer = 0
    
    convenience init(label: Label,parameters: Parameters,returnType:Type)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType
        self.isPrimitiveMethodInstance = true
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        if self.primitiveIndex == 1000
            {
//            print("halt")
            }
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        allocator.allocateAddress(forPrimitiveInstance: self)
        self.wasAddressAllocationDone = true
        }
        
    public func prim(_ primIndex: Int) -> Self
        {
        self.primitiveIndex = Argon.Integer(primIndex)
        return(self)
        }
        
//    public override func initializeType(inContext context: TypeContext)
//        {
//        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type},returnType: self.returnType)
//        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.parameters.forEach{$0.initializeTypeConstraints(inContext: context)}
        self.returnType.initializeTypeConstraints(inContext: context)
        let parameterTypes = self.parameters.map{$0.type!}
//        context.append(TypeConstraint(left: self.type,right: TypeFunction(label: self.label,types: parameterTypes, returnType: self.returnType),origin: .symbol(self)))
        context.append(TypeConstraint(left: self.type,right: self.returnType,origin: .symbol(self)))
        }
 
    public override func emitCode(into buffer: InstructionBuffer, using: CodeGenerator) throws
        {
        buffer.add(.PRIM,.integer(self.primitiveIndex))
        }
        
    public func emitCode(into output:InstructionBuffer,using generator:CodeGenerator,arguments: Arguments) throws
        {
        for argument in arguments.reversed()
            {
            try argument.value.emitValueCode(into: output,using: generator)
            output.add(.PUSH,argument.value.place)
            }
        output.add(.PRIM,.integer(self.primitiveIndex),.register(.RR))
        output.add(.POPN,.integer(Argon.Integer(arguments.count)))
        }
        
    public override func typeCheck() throws
        {
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newInstance = super.freshTypeVariable(inContext: context)
        newInstance.primitiveIndex = self.primitiveIndex
        newInstance.type = self.type.freshTypeVariable(inContext: context)
        return(newInstance)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)PRIMITIVE METHOD INSTANCE \(self.label)")
        var index = 0
        for parameter in self.parameters
            {
            print("\(indent)\tPARAMETER[\(index)] \(parameter.label) \(parameter.type.displayString)")
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

public class Template
    {
    private var label: Label
    
    init(_ label: Label)
        {
        self.label = label
        }
        
    public func method(_ type1: Type,_ type2: Type,_ type3: Type) -> TemplateMethodInstance
        {
        let parameters = [Parameter(label: "a", relabel: nil, type: type1, isVisible: false, isVariadic: false),Parameter(label: "b", relabel: nil, type: type2, isVisible: false, isVariadic: false)]
        let instance = TemplateMethodInstance(label: self.label)
        instance.returnType = type3
        instance.parameters = parameters
        return(instance)
        }
    }
