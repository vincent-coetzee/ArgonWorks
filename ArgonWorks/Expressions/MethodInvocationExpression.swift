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
        return("\(self.methodInstances.first!.label)\(values)")
        }
        
    private var methodInstances: ArgonWorks.MethodInstances
    private var arguments: Arguments
    private var methodInstance: MethodInstance?
    
    init(methodInstances: MethodInstances,arguments:Arguments)
        {
        self.methodInstances = methodInstances
        self.arguments = arguments
        super.init()
        }
        
    init(methodInstance: MethodInstance,arguments: Arguments)
        {
        self.methodInstances = []
        self.arguments = arguments
        self.methodInstance = methodInstance
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.methodInstances = coder.decodeObject(forKey: "methodInstances") as! MethodInstances
        self.arguments = coder.decodeArguments(forKey: "arguments")
        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.methodInstances,forKey: "methodInstances")
        coder.encodeArguments(self.arguments,forKey: "arguments")
        coder.encode(self.methodInstance,forKey: "methodInstance")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let new = MethodInvocationExpression(methodInstances: self.methodInstances,arguments: self.arguments.map{$0.freshTypeVariable(inContext: context)})
        new.methodInstances = self.methodInstances.map{$0.freshTypeVariable(inContext: context)}
        return(new as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.arguments.forEach{$0.initializeType(inContext: context)}
        if self.methodInstance.isNotNil
            {
            self.type = self.methodInstance!.returnType
            }
        else
            {
            self.type = self.methodInstances.first!.returnType
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = MethodInvocationExpression(methodInstances: self.methodInstances.map{substitution.substitute($0)},arguments: self.arguments.map{substitution.substitute($0)})
        let types = expression.arguments.map{$0.value.type}
        let sorted = expression.methodInstances.filter{$0.arity == self.arguments.count}.filter{$0.parameterTypesAreSupertypes(ofTypes: types)}.sorted{$0.moreSpecific(than: $1, forTypes: types)}
        expression.methodInstance = sorted.first
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)METHOD INVOCATION EXPRESSION: \(self.methodInstances.first!.label)")
        print("\(indent)ARGUMENTS:")
        for argument in self.arguments
            {
            print("\(indent)\t\(argument.tag ?? "") \(argument.value.type.displayString)")
            }
        if let instance = self.methodInstance
            {
            print("\(indent)\tSELECTED METHOD INSTANCE: \(instance.displayString)")
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
        var list = Array<MethodInstance>()
        for instance in self.methodInstances
            {
            context.extended(withContentsOf: [])
                {
                newContext in
                for (left,right) in zip(instance.parameters,self.arguments)
                    {
                    newContext.append(TypeConstraint(left: left.type,right: right.value.type,origin: .expression(self)))
                    }
                newContext.append(TypeConstraint(left: self.type,right: instance.returnType,origin: .expression(self)))
                let substitution = newContext.unify()
                let newInstance = substitution.substitute(instance)
                if !newInstance.hasVariableTypes
                    {
                    list.append(newInstance)
                    }
                }
            }
        let types = self.arguments.map{$0.value.type}
        self.methodInstance = list.sorted{$0.moreSpecific(than: $1, forTypes: types)}.first
//        if self.methodInstance.isNil
//            {
//            let methodMatcher = MethodInstanceMatcher(typeContext: context,methodInstances: self.methodInstances, argumentExpressions: newArguments.map{$0.value}, reportErrors: true)
//            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
//            methodMatcher.appendReturnType(self.type)
//            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
//                {
//                self.methodInstance = specificInstance
//                assert(self.methodInstance!.originalMethodInstance.isNotNil,"Original method instance is nil and should not be.")
//                print("FOUND MOST SPECIFIC INSTANCE FOR \(self.methodInstances.first!.label) = \(specificInstance.displayString)")
//                }
//            else
//                {
//                print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE FOR \(self.methodInstances.first!.label)")
//                self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.methodInstances.first!.label)' ) can not be resolved. Try making it more specific.")
//                }
//            }
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
        if self.methodInstance.isNotNil && self.methodInstance!.isInlineMethodInstance
            {
            (self.methodInstance as! InlineMethodInstance).emitCode(into: buffer, using: generator, arguments: self.arguments)
            }
        else if self.methodInstance.isNotNil && self.methodInstance!.isPrimitiveMethodInstance
            {
            for argument in self.arguments.reversed()
                {
                try argument.value.emitValueCode(into: buffer, using: generator)
                buffer.add(.PUSH,argument.value.place,.none,.none)
                }
            let index = (self.methodInstance as! PrimitiveMethodInstance).primitiveIndex
            buffer.add(.PRIM,.integer(index),.register(.RR))
            }
        else
            {
            for argument in self.arguments.reversed()
                {
                try argument.value.emitValueCode(into: buffer, using: generator)
                buffer.add(.PUSH,argument.value.place,.none,.none)
                }
            if let instance = self.methodInstance
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
                let instruction = buffer.add(.CALL,.address(address))
                let future = Future(root: instruction, path: \Instruction.operand1)
                instance.instructionAddressHolder.addFuture(future)
                instance.module?.queueOnBox(instance)
                print(instance.index)
                }
            else
                {
                let label = "#" + self.methodInstances.first!.label
                let labelSymbol = generator.payload.symbolRegistry.registerSymbol(label)
                generator.payload.symbolRegistry.dump()
                buffer.add(.SEND,.integer(Argon.Integer(labelSymbol)),.register(.RR))
                }
            buffer.add(.POPN,.integer(Argon.Integer(self.arguments.count * Argon.kArgumentSizeInBytes)))
            self._place = .register(.RR)
            }
        }
    }
