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
public class StandardMethodInstance: MethodInstance, StackFrame
    {
    public override var instructions: Array<T3AInstruction>
        {
        self.buffer.instructions
        }
        
    public var localSlots: Slots
        {
        self.localSymbols.filter{$0 is Slot}.map{$0 as! Slot}.sorted(by: {$0.offset < $1.offset})
        }
        
    internal private(set) var block: MethodInstanceBlock! = nil
    

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
        
    public var method: ArgonWorks.Method
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
        
//    convenience init(left:String,_ operation:Token.Symbol,right:String,out:String)
//        {
//        let leftParm = Parameter(label: "left", type: Class(label: left).type,isVisible: false)
//        let rightParm = Parameter(label: "right", type: Class(label: right).type,isVisible: false)
//        let name = "\(operation)"
//        let result = Class(label:out)
//        self.init(label: name)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(left:String,_ operation:String,right:String,out:String)
//        {
//        let leftParm = Parameter(label: "left", type: Class(label: left).type,isVisible: false)
//        let rightParm = Parameter(label: "right", type: Class(label: right).type,isVisible: false)
//        let name = "\(operation)"
//        let result = Class(label:out)
//        self.init(label: name)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(left:String,_ operation:String,right:String,out:Class)
//        {
//        let leftParm = Parameter(label: "left", type: Class(label: left).type,isVisible: false)
//        let rightParm = Parameter(label: "right", type: Class(label: right).type,isVisible: false)
//        let name = "\(operation)"
//        let result = out
//        self.init(label: name)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(left:Class,_ operation:Token.Symbol,right:Class,out:Class)
//        {
//        let leftParm = Parameter(label: "left", type: left.type,isVisible: false)
//        let rightParm = Parameter(label: "right", type: right.type,isVisible: false)
//        let name = "\(operation)"
//        let result = out
//        self.init(label: name)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//   convenience init(left:Class,_ operation: String,right:Class,out:Class)
//        {
//        let leftParm = Parameter(label: "left", type: left.type,isVisible: false)
//        let rightParm = Parameter(label: "right", type: right.type,isVisible: false)
//        let name = "\(operation)"
//        let result = out
//        self.init(label: name)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//   convenience init(_ operation: String,arg:Class,out:Class)
//        {
//        let rightParm = Parameter(label: "arg", type: arg.type,isVisible: false)
//        let name = "\(operation)"
//        let result = out
//        self.init(label: name)
//        self.parameters = [rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ op2:String,_ out:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let rightParm = Parameter(label: "op2", type: Class(label:op2).type,isVisible: false)
//        let result = out
//        self.init(label: label)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ out:String)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let result = Class(label:out)
//        self.init(label: label)
//        self.parameters = [leftParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        self.init(label: label)
//        self.parameters = [leftParm]
//        self.returnType = VoidClass.voidClass.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:String,_ out:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
//        let lastParm = Parameter(label: "op3", type: Class(label:op3).type,isVisible: false)
//        let result = out
//        self.init(label: label)
//        self.parameters = [leftParm,rightParm,lastParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:Class,_ out:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
//        let lastParm = Parameter(label: "op3", type: op3.type,isVisible: false)
//        let result = out
//        self.init(label: label)
//        self.parameters = [leftParm,rightParm,lastParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:String)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
//        let result = Class(label:out)
//        self.init(label: label)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
//        let result = out
//        self.init(label: label)
//        self.parameters = [leftParm,rightParm]
//        self.returnType = result.type
//        }
//        
//    convenience init(_ label:String,_ op1:Class,_ out:Class)
//        {
//        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
//        let result = out
//        self.init(label: label)
//        self.parameters = [leftParm]
//        self.returnType = result.type
//        }
        
    convenience init(label: Label,parameters: Parameters,returnType:Type)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType
        for parameter in parameters
            {
            self.addLocalSlot(parameter)
            }
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        self.localSymbols.append(symbol)
        symbol.frame = self
        }
        
//    public func generic(_ name:String) -> Self
//        {
//        self.parameters.append(Parameter(label: name,type: GenericType(label: name).type))
//        return(self)
//        }
        
    public func `where`(_ name:String,_ aClass:Class) -> MethodInstance
        {
        return(self)
        }
        
    public func type(atIndex: Int) -> Type
        {
        parameters[atIndex].type
        }
        
    public func mergeTemporaryScope(_ scope: TemporaryLocalScope)
        {
        for symbol in scope.symbols
            {
            self.localSymbols.append(symbol)
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
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localSymbols
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.parent.lookup(label: label))
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
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.block.initializeType(inContext: context)
        self.type = TypeFunction(types: self.parameters.map{$0.type},returnType: self.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        print("INIT CONSTRAINTS FOR \(self.label)")
        try self.block.initializeTypeConstraints(inContext: context)
        let parameterTypes = self.parameters.map{$0.type}
        context.append(TypeConstraint(left: self.type,right: TypeFunction(types: parameterTypes, returnType: self.block.type),origin: .symbol(self)))
        print("AFTER ADDING CONSTRAINTS \(context.constraints.count) CONSTRAINTS")
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
    }
