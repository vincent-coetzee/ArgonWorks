//
//  StandardMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/11/21.
//

import Foundation

///
///
/// A MethodInstance is the functional part of a method. A method has multiple
/// instance of itself, but one of those instances will get selected based on the
/// typesof the arguments and that instance will then execute. A Method is not
/// directly executable. When the method instances are compiled code is actually
/// generated for each method instance but not for the method.
///
/// A MethodInstance has an instruction buffer, which is a high level form
/// of the generated code, that instruction buffer is translated into an
/// InnerInstructionBufferPointer which contains the encoded form of the
/// instructions and the buffer represented by the InnerInstructionBufferPointer
/// will actually be used when this instance of a method is called.
///
///
public class StandardMethodInstance: MethodInstance
    {
    public override var allIssues: CompilerIssues
        {
        var myIssues = self.issues
        myIssues.append(contentsOf: self.block.allIssues)
        return(myIssues)
        }
        
    public override var instructions: Array<T3AInstruction>
        {
        self.codeBuffer.instructions
        }

    internal var block: MethodInstanceBlock! = nil
        {
        didSet
            {
            self.block?.setParent(self)
            }
        }
        
    public var genericParameters = Types()
    
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as? MethodInstanceBlock
        self.genericParameters = coder.decodeObject(forKey: "genericParameters") as! Types
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.block,forKey: "block")
        coder.encode(self.genericParameters,forKey: "genericParameters")
        super.encode(with: coder)
        }
        
    required init(label:Label)
        {
        super.init(label:label)
        self.block = MethodInstanceBlock(methodInstance: self)
        self.block.setParent(self)
        }
        
    public init(_ label:Label)
        {
        super.init(label:label)
        self.block = MethodInstanceBlock(methodInstance: self)
        self.block.setParent(self)
        }
        
    convenience init(label: Label,parameters: Parameters,returnType:Type)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType
        for parameter in parameters
            {
            self.addParameterSlot(parameter)
            }
        }

    public func `where`(_ name:String,_ aClass:Class) -> MethodInstance
        {
        return(self)
        }
        
    public func type(atIndex: Int) -> Type?
        {
        parameters[atIndex].type
        }
        
    public func mergeTemporaryScope(_ scope: TemporaryLocalScope)
        {
        for symbol in scope.symbols
            {
            self.block.addSymbol(symbol)
            }
        }
        
    public func hasSameReturnType(_ clazz: Class) -> Bool
        {
        return(self.returnType == clazz.type)
        }

    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        buffer.appendEntry(temporaryCount: self.localCount)
        try block.emitCode(into: buffer,using: generator)
        buffer.appendExit()
        buffer.append("RET",.none,.none,.none)
        }
        
    public override func addDeclaration(_ location: Location)
        {
        super.addDeclaration(location)
        self.block.addDeclaration(location)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newParameters = self.parameters.map{$0.freshTypeVariable(inContext: context)}
        let newReturnType = self.returnType.freshTypeVariable(inContext: context)
        let newInstance = Self(label: self.label)
        newInstance.parameters = newParameters
        newInstance.returnType = newReturnType
        newInstance.block = (self.block.freshTypeVariable(inContext: context))
        newInstance.block._methodInstance = newInstance
        newInstance.block.setParent(newInstance)
        newInstance.type = self.type?.freshTypeVariable(inContext: context)
        return(newInstance)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = StandardMethodInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.block.setParent(instance)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }

    public override func initializeType(inContext context: TypeContext)
        {
        self.parameters.forEach{$0.initializeType(inContext: context)}
        self.returnType.initializeType(inContext: context)
        self.block.initializeType(inContext: context)
        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!.freshTypeVariable(inContext: context)},returnType: self.returnType.freshTypeVariable(inContext: context))
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.parameters.forEach{$0.initializeTypeConstraints(inContext: context)}
        self.returnType.initializeTypeConstraints(inContext: context)
        self.block.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.returnType,right: self.block.type,origin: .symbol(self)))
        let parameterTypes = self.parameters.map{$0.type!}
        context.append(TypeConstraint(left: self.type,right: TypeFunction(label: self.label,types: parameterTypes, returnType: self.block.type!),origin: .symbol(self)))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func typeCheck() throws
        {
        try self.block.typeCheck()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.parameters.visit(visitor: visitor)
        try self.block.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)STANDARD METHOD INSTANCE \(self.label)")
        var index = 0
        for parameter in self.parameters
            {
            print("\(indent)\tPARAMETER[\(index)] \(parameter.label) \(parameter.type.displayString)")
            index += 1
            }
        print("\(indent)\tRETURN TYPE \(self.returnType.displayString)")
        self.block.display(indent: indent + "\t")
        self.codeBuffer.display(indent: indent + "\t\t")
        }
    }
