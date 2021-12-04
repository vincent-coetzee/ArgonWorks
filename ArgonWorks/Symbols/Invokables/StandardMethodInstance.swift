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
        self.buffer.instructions
        }

    internal var block: MethodInstanceBlock! = nil
    private var _method:Method?
    public let buffer:T3ABuffer
    public var genericParameters = Types()
    public required init?(coder: NSCoder)
        {
//        print("START DECODE METHOD INSTANCE")
        self._method = coder.decodeObject(forKey: "method") as? Method
        self.buffer = coder.decodeObject(forKey: "buffer") as! T3ABuffer
        self.genericParameters = coder.decodeObject(forKey: "genericParameters") as! Types
        super.init(coder: coder)
//        print("END DECODE METHOD INSTANCE \(self.label)")
        }

    public override func encode(with coder:NSCoder)
        {
//        print("ENCODE METHOD INSTANCE \(self.label)")
        super.encode(with: coder)
        coder.encode(self.method,forKey: "method")
        coder.encode(self.buffer,forKey: "buffer")
        coder.encode(self.genericParameters,forKey: "genericParameters")
        }
        
//    public var systemMethod: ArgonWorks.Method
//        {
//        if self._method.isNotNil
//            {
//            return(self._method!)
//            }
//        let method = SystemMethod(label: self.label)
//        method.addInstance(self)
//        self._method = method
//        return(method)
//        }
        
    public override var method: ArgonWorks.Method!
        {
        get
            {
            if self._method.isNotNil
                {
                return(self._method!)
                }
            let method = Method(label: self.label)
            method.addInstance(self)
            self._method = method
            return(method)
            }
        set
            {
            self._method = newValue
            }
        }
        
    required init(label:Label)
        {
        self.buffer = T3ABuffer()
        super.init(label:label)
        self.block = MethodInstanceBlock(methodInstance: self)
        self.block.setParent(self)
        }
        
    public init(_ label:Label)
        {
        self.buffer = T3ABuffer()
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
    
    public override func deepCopy() -> Self
        {
        let instance = super.deepCopy()
        instance.block = self.block.deepCopy()
        instance.parameters = self.parameters.map{$0.deepCopy()}
        instance.returnType = self.returnType.deepCopy()
        return(instance)
        }
        
    public func hasSameReturnType(_ clazz: Class) -> Bool
        {
        return(self.returnType == clazz.type)
        }
        
    public func layoutSymbol(in vm: VirtualMachine)
        {
//        guard !self.isMemoryLayoutDone else
//            {
//            return
//            }
//        let pointer = InnerInstructionBufferPointer.allocate(bufferCount: buffer.count, in: vm)
//        for instruction in self.buffer.instructions
//            {
//            pointer.append(instruction)
//            }
//        self.addresses.append(Address.absolute(pointer.address))
//        self.isMemoryLayoutDone = true
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
//        var stackOffset = MemoryLayout<Word>.size
//        for parameter in self.parameters
//            {
//            parameter.addresses.append(.stack(.BP,stackOffset))
//            stackOffset += MemoryLayout<Word>.size
//            }
//        stackOffset = 0
//        for slot in self.localSymbols
//            {
//            slot.addresses.append(.stack(.BP,stackOffset))
//            stackOffset -= MemoryLayout<Word>.size
//            }
        self.buffer.appendEntry(temporaryCount: self.localSymbols.count)
        try block.emitCode(into: self.buffer,using: generator)
        self.buffer.appendExit()
        buffer.append("RET",.none,.none,.none)
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

    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.parameters.forEach{try $0.initializeType(inContext: context)}
        try self.returnType.initializeType(inContext: context)
        try self.block.initializeType(inContext: context)
        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!.freshTypeVariable(inContext: context)},returnType: self.returnType.freshTypeVariable(inContext: context))
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.parameters.forEach{try $0.initializeTypeConstraints(inContext: context)}
        try self.returnType.initializeTypeConstraints(inContext: context)
        try self.block.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.returnType,right: self.block.type,origin: .symbol(self)))
        let parameterTypes = self.parameters.map{$0.type!}
        context.append(TypeConstraint(left: self.type,right: TypeFunction(label: self.label,types: parameterTypes, returnType: self.block.type!),origin: .symbol(self)))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
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
        }
    }
