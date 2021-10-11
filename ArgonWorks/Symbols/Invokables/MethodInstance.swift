//
//  MethodInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

///
///
/// A MethodSignature is used in generating the dispatch tree for a Method
///
///
public struct MethodSignature:Displayable,CustomDebugStringConvertible,CustomStringConvertible
    {
    public var description: String
        {
        return(self.displayString)
        }
        
    public var debugDescription: String
        {
        return(self.displayString)
        }
        
    public var displayString: String
        {
        let parmString = "[" + self.parameters.map{$0.type.displayString}.joined(separator: ",") + "]"
        return("\(self.instance.label) \(parmString)")
        }
        
    public let parameters: Parameters
    public let instance: MethodInstance
    
    public var isEmpty: Bool
        {
        self.parameters.isEmpty
        }
        
    public var firstParameter: Parameter
        {
        self.parameters.first!
        }
        
    public func withoutFirst() -> MethodSignature
        {
        MethodSignature(parameters: Parameters(self.parameters.dropFirst()),instance: self.instance)
        }
    }
    
public typealias MethodSignatures = Array<MethodSignature>

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
public class MethodInstance:Function,StackFrame
    {
    public var methodSignature: MethodSignature
        {
        MethodSignature(parameters: self.parameters,instance: self)
        }
        
    public override var iconName: String
        {
        "IconMethodInstance"
        }
        
    public var isSystemMethodInstance: Bool
        {
        return(false)
        }
        
    public override var displayString: String
        {
        let parmString = "(" + self.parameters.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.label) \(parmString) -> \(self.returnType.displayString)")
        }
        
    public var localSlots: Slots
        {
        self.localSymbols.filter{$0 is Slot}.map{$0 as! Slot}.sorted(by: {$0.offset < $1.offset})
        }
        
    internal private(set) var block: MethodInstanceBlock! = nil
    

    private var _method:Method?
    public let buffer:T3ABuffer
//    public var instructionsAddress: Word = 0
    public var isGenericMethod = false
    public var genericParameters = GenericClassParameters()
        
    public required init?(coder: NSCoder)
        {
        self._method = coder.decodeObject(forKey: "method") as? Method
        self.buffer = coder.decodeObject(forKey: "buffer") as! T3ABuffer
//        self.buffer = coder.decodeObject(forKey: "buffer") as! InstructionBuffer
//        self.instructionsAddress = Word(coder.decodeInteger(forKey: "instructionsAddress"))
        self.genericParameters = coder.decodeObject(forKey: "genericParameters") as! GenericClassParameters
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        print("ENCODE METHOD INSTANCE \(self.label)")
        super.encode(with: coder)
        coder.encode(self.method,forKey: "method")
        coder.encode(self.buffer,forKey: "buffer")
        coder.encode(self.genericParameters,forKey: "genericParameters")
        }
        
    public var systemMethod: ArgonWorks.Method
        {
        if self._method.isNotNil
            {
            return(self._method!)
            }
        let method = SystemMethod(label: self.label)
        method.addInstance(self)
        self._method = method
        return(method)
        }
        
    public var libraryMethod: ArgonWorks.Method
        {
        if self._method.isNotNil
            {
            return(self._method!)
            }
        let method = LibraryMethod(label: self.label)
        method.addInstance(self)
        self._method = method
        return(method)
        }
        
    public var intrinsicMethod: ArgonWorks.Method
        {
        if self._method.isNotNil
            {
            return(self._method!)
            }
        let method = IntrinsicMethod(label: self.label)
        method.addInstance(self)
        self._method = method
        return(method)
        }
        
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
        
    override init(label:Label)
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
        
    convenience init(left:String,_ operation:Token.Symbol,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: .class(Class(label: left)),isVisible: false)
        let rightParm = Parameter(label: "right", type: .class(Class(label: right)),isVisible: false)
        let name = "\(operation)"
        let result = Class(label:out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(left:String,_ operation:String,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: .class(Class(label: left)),isVisible: false)
        let rightParm = Parameter(label: "right", type: .class(Class(label: right)),isVisible: false)
        let name = "\(operation)"
        let result = Class(label:out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(left:String,_ operation:String,right:String,out:Class)
        {
        let leftParm = Parameter(label: "left", type: .class(Class(label: left)),isVisible: false)
        let rightParm = Parameter(label: "right", type: .class(Class(label: right)),isVisible: false)
        let name = "\(operation)"
        let result = out
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(left:Class,_ operation:Token.Symbol,right:Class,out:Class)
        {
        let leftParm = Parameter(label: "left", type: .class(left),isVisible: false)
        let rightParm = Parameter(label: "right", type: .class(right),isVisible: false)
        let name = "\(operation)"
        let result = out
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
   convenience init(left:Class,_ operation: String,right:Class,out:Class)
        {
        let leftParm = Parameter(label: "left", type: left.type,isVisible: false)
        let rightParm = Parameter(label: "right", type: right.type,isVisible: false)
        let name = "\(operation)"
        let result = out
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
   convenience init(_ operation: String,arg:Class,out:Class)
        {
        let rightParm = Parameter(label: "arg", type: arg.type,isVisible: false)
        let name = "\(operation)"
        let result = out
        self.init(label: name)
        self.parameters = [rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let rightParm = Parameter(label: "op2", type: Class(label:op2).type,isVisible: false)
        let result = out
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let result = Class(label:out)
        self.init(label: label)
        self.parameters = [leftParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        self.init(label: label)
        self.parameters = [leftParm]
        self.returnType = .class(VoidClass.voidClass)
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
        let lastParm = Parameter(label: "op3", type: Class(label:op3).type,isVisible: false)
        let result = out
        self.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
        let lastParm = Parameter(label: "op3", type: op3.type,isVisible: false)
        let result = out
        self.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
        let result = Class(label:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let rightParm = Parameter(label: "op2", type: op2.type,isVisible: false)
        let result = out
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = .class(result)
        }
        
    convenience init(_ label:String,_ op1:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: op1.type,isVisible: false)
        let result = out
        self.init(label: label)
        self.parameters = [leftParm]
        self.returnType = .class(result)
        }
        
    convenience init(label: Label,parameters: Parameters,returnType:Type? = nil)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType ?? .class(VoidClass.voidClass)
        for parameter in parameters
            {
            self.addLocalSlot(parameter)
            }
        }
        
    @discardableResult
    public override func addSymbol(_ symbol: Symbol) -> Symbol
        {
        self.localSymbols.append(symbol)
        symbol.frame = self
        return(symbol)
        }
        
    public func generic(_ name:String) -> Self
        {
        self.parameters.append(Parameter(label: name,type: GenericType(label: name).type))
        return(self)
        }
        
    public func `where`(_ name:String,_ aClass:Class) -> MethodInstance
        {
        return(self)
        }
        
    public func dump()
        {
        if self.isSystemMethodInstance
            {
            return
            }
        print(";; ====================================================")
        print(";; CODE FOR \(self.label)")
        print(";; \(self.buffer.count) INSTRUCTIONS")
        print(";;")
        print(";; LINE \(self.declaration!.line)")
        print(";;")
        for instruction in self.buffer.instructions
            {
            print(instruction.displayString)
            }
        }
        
    public func mergeTemporaryScope(_ scope: TemporaryLocalScope)
        {
        for symbol in scope.symbols
            {
            self.localSymbols.append(symbol as! Symbol)
            }
        }
    
    public func hasSameReturnType(_ clazz: Class) -> Bool
        {
        return(self.returnType == Type.class(clazz))
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
        var stackOffset = MemoryLayout<Word>.size
        for parameter in self.parameters
            {
//            parameter.addresses.append(.stack(.BP,stackOffset))
            stackOffset += MemoryLayout<Word>.size
            }
        stackOffset = 0
        for slot in self.localSymbols
            {
//            slot.addresses.append(.stack(.BP,stackOffset))
            stackOffset -= MemoryLayout<Word>.size
            }
        try block.emitCode(into: self.buffer,using: generator)
        }
        
    public override func realize(using realizer: Realizer)
        {
        for parameter in self.parameters
            {
            parameter.realize(using: realizer)
            }
        self.returnType.realize(using: realizer)
        self.block.realize(using: realizer)
        }

    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.block.analyzeSemantics(using: analyzer)
        }
    
        
    public func isParameterSetCoherent(with input: Arguments) -> Bool
        {
        if self.parameters.count != input.count
            {
            return(false)
            }
        for (mine,yours) in zip(self.parameters,input)
            {
            if !yours.value.type.isEquivalent(to: mine.type)
                {
                return(false)
                }
            }
        return(true)
        }
        
    public func dispatchScore(for classes:Types) -> Int
        {
//        var answer = 0
//        for (mine,theirs) in zip(self.parameters.map{$0.type},classes)
//            {
//            answer  += theirs.depth - mine.depth
//            }
//        return(answer)
        return(0)
        }
    }

public typealias MethodInstances = Array<MethodInstance>
