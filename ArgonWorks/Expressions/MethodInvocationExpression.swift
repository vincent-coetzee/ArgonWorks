//
//  MethodInvocationExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

public class MethodInvocationExpression: Expression
    {
    public override var displayString: String
        {
        let values = "(" + self.arguments.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.method.instances.first!.label)\(values)")
        }
        
    private var method: ArgonWorks.Method
    private var arguments: Arguments
    private var selectedMethodInstance: MethodInstance?
    
    init(method: ArgonWorks.Method,arguments:Arguments)
        {
        self.method = method
        self.arguments = []
        super.init()
        method.container = .expression(self)
        self.arguments = arguments.map{$0.withContainer(Container.expression(self))}
        }
        
    init(methodInstance: MethodInstance,arguments: Arguments)
        {
        self.method = Method(label: methodInstance.label)
        self.arguments = arguments
        self.selectedMethodInstance = methodInstance
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.method = coder.decodeObject(forKey: "method") as! Method
        self.arguments = coder.decodeArguments(forKey: "arguments")
        self.selectedMethodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.method,forKey: "method")
        coder.encodeArguments(self.arguments,forKey: "arguments")
        coder.encode(self.selectedMethodInstance,forKey: "methodInstance")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let new = MethodInvocationExpression(method: self.method,arguments: self.arguments.map{$0.freshTypeVariable(inContext: context)})
        new.type = self.type.freshTypeVariable(inContext: context)
        new.method = self.method.freshTypeVariable(inContext: context)
        new.selectedMethodInstance = self.selectedMethodInstance
        new.locations = self.locations
        return(new as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.method.initializeType(inContext: context)
        self.arguments.forEach{$0.initializeType(inContext: context)}
        if self.selectedMethodInstance.isNotNil
            {
            self.type = self.selectedMethodInstance!.returnType
            }
        else
            {
            self.type = self.method.returnType
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = MethodInvocationExpression(method: self.method.substitute(from: substitution),arguments: self.arguments.map{substitution.substitute($0)})
        if self.selectedMethodInstance.isNotNil
            {
            expression.selectedMethodInstance = substitution.substitute(self.selectedMethodInstance!)
            }
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)METHOD INVOCATION EXPRESSION: \(self.method.label)")
        print("\(indent)ARGUMENTS:")
        for argument in self.arguments
            {
            print("\(indent)\t\(argument.tag ?? "") \(argument.value.type.displayString)")
            }
        if let instance = self.selectedMethodInstance
            {
            print("\(indent)\tSELECTED METHOD INSTANCE: \(instance.index) \(instance.displayString)")
            }
        else
            {
            print("\(indent)\tNO SELECTED METHOD INSTANCE")
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        print("METHOD INVOCATION EXPRESSION")
        self.arguments.forEach{$0.initializeTypeConstraints(inContext: context)}
        let set = MethodInstanceSet(instances: self.method.instances)
        if set.hasGenericInstances
            {
            var newArguments = Array<Argument>()
            context.extended(with: [])
                {
                inner in
                let sub = inner.unify()
                for aMethod in self.method.instances
                    {
                    let types = aMethod.parameters.map{($0.label,$0.type!)}
                    inner.extended(with: types)
                        {
                        newContext in
                        newArguments = arguments.map{sub.substitute($0).freshTypeVariable(inContext: newContext)}
                        let instance = aMethod.freshTypeVariable(inContext: newContext)
                        for (left,right) in zip(instance.parameters,newArguments)
                            {
                            newContext.append(TypeConstraint(left: left.type,right: right.value.type,origin: .expression(self)))
                            }
                        newContext.append(TypeConstraint(left: self.type,right: instance.returnType,origin: .expression(self)))
                        let substitution = newContext.unify()
                        let newInstance = substitution.substitute(instance)
                        if !newInstance.hasVariableTypes
                            {
                            set.addInstance(newInstance)
                            }
                        newArguments = newArguments.map{substitution.substitute($0)}
                        }
                    }
                }
            let types = newArguments.map{$0.value.type}
            self.selectedMethodInstance = set.mostSpecificInstance(forTypes: types)
            }
        else
            {
            var newArguments = Array<Argument>()
            context.extended(with: [])
                {
                inner in
                let sub = inner.unify()
                newArguments = arguments.map{sub.substitute($0)}
                }
            let types = newArguments.map{$0.value.type}
            self.selectedMethodInstance = set.mostSpecificInstance(forTypes: types)
            }
//        if let instance = self.methodInstance
//            {
//            for (argument,parameter) in zip(newArguments,instance.parameters)
//                {
//                context.append(TypeConstraint(left: argument.value.type,right: parameter.type,origin: .expression(self)))
//                }
//            }
        if let method = self.selectedMethodInstance
            {
            context.append(TypeConstraint(left: self.type,right: method.returnType,origin: .expression(self)))
            }
        else if let first = self.method.instances.first
            {
            context.append(TypeConstraint(left: self.type,right: first.returnType,origin: .expression(self)))
            }
        }
        
    public override func assign(from expression: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        if let instance = self.selectedMethodInstance,instance.isSlotAccessor
            {
            let aClass = instance.parameters[0].type as! TypeClass
            let slotName = instance.label
            let slot = aClass.instanceSlot(atLabel: slotName)
            let offset = aClass.offsetInObject(ofSlot: slot)
            try self.arguments[0].value.emitValueCode(into: buffer,using: using)
            try expression.emitValueCode(into: buffer,using: using)
            buffer.add(.STOREP,expression.place,self.arguments[0].value.place,.integer(Argon.Integer(offset)))
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "IT is not possible to assign into an invalid slot.")
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    private func mapLabels(from: Array<Label>,to: TaggedTypes) -> TaggedTypes
        {
        var index = 0
        var types = TaggedTypes()
        for argument in to
            {
            types.append(TaggedType(tag: argument.tag.isNil ? from[index] : argument.tag!,type: argument.type))
            index += 1
            }
        return(types)
        }
        
    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.emitCode(into: into,using: using)
        }
        
    public override func emitCode(into buffer: InstructionBuffer, using generator: CodeGenerator) throws
        {
        if self.selectedMethodInstance.isNotNil && self.selectedMethodInstance!.isInlineMethodInstance
            {
            (self.selectedMethodInstance as! InlineMethodInstance).emitCode(into: buffer, using: generator, arguments: self.arguments)
            }
        else if self.selectedMethodInstance.isNotNil && self.selectedMethodInstance!.isPrimitiveMethodInstance
            {
            for argument in self.arguments.reversed()
                {
                try argument.value.emitValueCode(into: buffer, using: generator)
                buffer.add(.PUSH,argument.value.place,.none,.none)
                }
            let index = (self.selectedMethodInstance as! PrimitiveMethodInstance).primitiveIndex
            buffer.add(.PRIM,.integer(index),.register(.RR))
            }
        else if self.selectedMethodInstance.isNotNil && self.selectedMethodInstance!.isSlotAccessor
            {
            let aClass = self.selectedMethodInstance!.parameters[0].type as! TypeClass
            let slotLabel = self.selectedMethodInstance!.label
            let slot = aClass.instanceSlot(atLabel: slotLabel)
            let offset = aClass.offsetInObject(ofSlot: slot)
            try self.arguments[0].value.emitValueCode(into: buffer,using: generator)
            buffer.add(.LOADP,self.arguments[0].value.place,.integer(Argon.Integer(offset)),.register(.RR))
            self._place = .register(.RR)
            }
        else
            {
            for argument in self.arguments.reversed()
                {
                try argument.value.emitValueCode(into: buffer, using: generator)
                buffer.add(.PUSH,argument.value.place,.none,.none)
                }
            if let instance = self.selectedMethodInstance
                {
                generator.registerMethodInstanceIfNeeded(instance)
                var address = instance.memoryAddress
                if address == 0
                    {
                    address = AddressTable[instance.index]!
                    }
                assert(address != 100000000000)
                assert(address != 0)
                print("CALLING \(address)")
                let instruction = buffer.add(.CALL,.address(address),tail: instance.label)
                let future = Future(root: instruction, path: \Instruction.operand1)
                instance.instructionAddressHolder.addFuture(future)
                instance.module?.queueOnBox(instance)
                print(instance.index)
                }
            else
                {
                let label = "#" + self.method.label
                if label == "#append"
                    {
                    print(self)
                    }
                let labelSymbol = generator.payload.symbolRegistry.registerSymbol(label)
                generator.payload.symbolRegistry.dump()
                buffer.add(.SEND,.integer(Argon.Integer(labelSymbol)),.register(.RR),tail: label)
                }
            buffer.add(.POPN,.integer(Argon.Integer(self.arguments.count * Argon.kWordSizeInBytesInt)))
            self._place = .register(.RR)
            }
        }
    }
