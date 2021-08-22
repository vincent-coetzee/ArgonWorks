//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public enum TypeResult
    {
    public var isPrimitiveClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isPrimitiveClass)
            default:
                return(false)
            }
        }
        
    public var isObjectClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isObjectClass)
            default:
                return(false)
            }
        }
        
    public var isEnumerationClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isEnumeration)
            default:
                return(false)
            }
        }
        
    public var isNotClass: Bool
        {
        switch(self)
            {
            case .class:
                return(false)
            default:
                return(true)
            }
        }
        
    public var isMismatch: Bool
        {
        switch(self)
            {
            case .mismatch:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isUndefined: Bool
        {
        switch(self)
            {
            case .undefined:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isClass: Bool
        {
        switch(self)
            {
            case .class:
                return(true)
            default:
                return(false)
            }
        }
        
    case `class`(Class)
    case mismatch(Class,Class)
    case undefined
    
    public static func ==(lhs:TypeResult,rhs:TypeResult) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.class(let classA),.class(let classB)):
                return(classA == classB)
            default:
                return(false)
            }
        }
        
    public static func +(lhs:TypeResult,rhs:TypeResult) -> TypeResult
        {
        switch(lhs,rhs)
            {
            case (.class(let class1),.class(let class2)):
                if class1 == class2
                    {
                    return(.class(class1))
                    }
                return(.mismatch(class1,class2))
            case (.mismatch,_):
                fallthrough
            case (_,.mismatch):
                return(.undefined)
            case (.undefined,_):
                fallthrough
            case (_,.undefined):
                return(.undefined)
            default:
                return(.undefined)
            }
        }
        
    public static func ==(lhs:TypeResult,rhs:Class) -> Bool
        {
        switch(lhs)
            {
            case .class(let aClass):
                return(aClass == rhs)
            default:
                return(false)
            }
        }
        
    public func isSubclass(of: Class) -> Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isSubclass(of: of))
            default:
                return(false)
            }
        }
        
    public func isSameClass(_ aClass: Class) -> Bool
        {
        switch(self)
            {
            case .class(let theClass):
                return(aClass == theClass)
            default:
                return(false)
            }
        }
        
    public func isInclusiveSubclass(of: Class) -> Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isInclusiveSubclass(of: of))
            default:
                return(false)
            }
        }
        
    public var `class`: Class?
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass)
            default:
                return(nil)
            }
        }
    
    }
    
public class BinaryExpression: Expression
    {
    private let operation: Token.Symbol
    private let rhs: Expression
    private let lhs: Expression
    
    init(_ lhs:Expression,_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        self.lhs.setParent(self)
        self.rhs.setParent(self)
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operation) \(self.rhs.displayString)")
        }
        
    public override var resultType: TypeResult
        {
        let left = self.lhs.resultType
        let right = self.rhs.resultType
        switch(self.operation)
            {
            case .leftBrocket:
                fallthrough
            case .leftBrocketEquals:
                fallthrough
            case .equals:
                fallthrough
            case .rightBrocket:
                fallthrough
            case .rightBrocketEquals:
                if left.isClass && right.isClass
                    {
                    return(.class(self.topModule.argonModule.boolean))
                    }
                return(left + right)
            default:
                return(left + right)
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        let left = self.lhs.resultType
        let right = self.rhs.resultType
        if left.isNotClass || right.isNotClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration, message: "The type of this expression can not be ascertained.")
            return
            }
        switch(self.operation)
            {
            case .and:
                fallthrough
            case .or:
                if left.isSameClass(self.topModule.argonModule.boolean) && right.isSameClass(self.topModule.argonModule.boolean)
                    {
                    break
                    }
                analyzer.cancelCompletion()
                analyzer.dispatchError(at: self.declaration,message: "Invalid argument types for \(self.operation).")
            case .leftBrocket:
                fallthrough
            case .leftBrocketEquals:
                fallthrough
            case .equals:
                fallthrough
            case .rightBrocket:
                fallthrough
            case .rightBrocketEquals:
                if left.isPrimitiveClass && right.isPrimitiveClass
                    {
                    break
                    }
                if left.isEnumerationClass && right.isEnumerationClass
                    {
                    break
                    }
                if left.isObjectClass && right.isObjectClass
                    {
                    break
                    }
                analyzer.cancelCompletion()
                analyzer.dispatchError(at: self.declaration,message: "The types on the left side and right side of this expression do not match.")
                return
        default:
            if left == right
                {
                break
                }
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration,message: "The types on the left side and right side of this expression do not match.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    init(coder: NSCoder)
        {
        self.operation = coder.decodeObject(forKey: "operation") as! Token.Symbol
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.operation,forKey: "operation")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        }
        
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)BINARY EXPRESSION()")
        print("\(padding)\t\(self.operation)")
        lhs.dump(depth: depth + 1)
        rhs.dump(depth: depth + 1)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        var opcode:Instruction.Opcode = .NOP
        switch(self.operation)
            {
            case .add:
                if self.resultType == self.topModule.argonModule.float
                    {
                    opcode = .FADD
                    }
                else
                    {
                    opcode = .IADD
                    }
            case .sub:
                if self.resultType == self.topModule.argonModule.float
                    {
                    opcode = .FSUB
                    }
                else
                    {
                    opcode = .ISUB
                    }
            case .mul:
                if self.resultType == self.topModule.argonModule.float
                    {
                    opcode = .FMUL
                    }
                else
                    {
                    opcode = .IMUL
                    }
            case .div:
                if self.resultType == self.topModule.argonModule.float
                    {
                    opcode = .FDIV
                    }
                else
                    {
                    opcode = .IDIV
                    }
            case .modulus:
                if self.resultType == self.topModule.argonModule.float
                    {
                    opcode = .FMOD
                    }
                else
                    {
                    opcode = .IMOD
                    }
            case .and:
                opcode = .AND
            case .or:
                opcode = .OR
            case .rightBrocket:
                fallthrough
            case .rightBrocketEquals:
                fallthrough
            case .equals:
                fallthrough
            case .leftBrocket:
                fallthrough
            case .leftBrocketEquals:
                if self.resultType.isNotClass
                    {
                    print(self.rhs.displayString)
                    generator.dispatchError(at: self.declaration, message: "The type of this expression is not defined.")
                    generator.cancelCompletion()
                    break
                    }
                if self.resultType.class!.isPrimitiveClass
                    {
                    opcode = .CMPW
                    }
                else
                    {
                    opcode = .CMPO
                    }
            default:
                break
            }
        try self.lhs.emitCode(into: instance, using: generator)
        try self.rhs.emitCode(into: instance, using: generator)
        let outputRegister = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        instance.append(opcode,lhs.place,rhs.place,.register(outputRegister))
        self._place = .register(outputRegister)
        }
    }
