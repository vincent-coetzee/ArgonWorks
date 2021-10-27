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
    public override var lhsValue: Expression?
        {
        return(self.lhs)
        }
        
    public override var rhsValue: Expression?
        {
        return(self.rhs)
        }
        
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
        
    public override var type: Type
        {
        let left = self.lhs.type
        let right = self.rhs.type
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
                return(.class(self.compiler.argonModule.boolean))
            default:
                return(left + right)
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        let left = self.lhs.type
        let right = self.rhs.type
        if left.isNotClass || right.isNotClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of this expression can not be ascertained.")
            return
            }
        switch(self.operation)
            {
            case .and:
                fallthrough
            case .or:
                if left.isSameClass(self.compiler.argonModule.boolean) && right.isSameClass(self.compiler.argonModule.boolean)
                    {
                    break
                    }
                analyzer.cancelCompletion()
                analyzer.dispatchError(at: self.declaration!,message: "Invalid argument types for \(self.operation).")
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
                if left.isEnumeration && right.isEnumeration
                    {
                    break
                    }
                if left.isObjectClass && right.isObjectClass
                    {
                    break
                    }
                analyzer.cancelCompletion()
                analyzer.dispatchError(at: self.declaration!,message: "The types on the left side and right side of this expression do not match.")
                return
        default:
            if left == right
                {
                break
                }
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!,message: "The types on the left side and right side of this expression do not match.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    required init?(coder: NSCoder)
        {
        self.operation = coder.decodeTokenSymbol(forKey: "operation")
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        super.init(coder: coder)
        }
        
     public override func becomeLValue()
        {
        self.lhs.becomeLValue()
        self.lhs.becomeLValue()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encodeTokenSymbol(self.operation,forKey: "operation")
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
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        var opcode: String = "NOP"
        switch(self.operation)
            {
            case .add:
                if self.type == generator.argonModule.float.type
                    {
                    opcode = "FADD"
                    }
                else
                    {
                    opcode = "IADD"
                    }
            case .sub:
                if self.type == generator.argonModule.float.type
                    {
                    opcode = "FSUB"
                    }
                else
                    {
                    opcode = "ISUB"
                    }
            case .mul:
                if self.type == generator.argonModule.float.type
                    {
                    opcode = "FMUL"
                    }
                else
                    {
                    opcode = "IMUL"
                    }
            case .div:
                if self.type == generator.argonModule.float.type
                    {
                    opcode = "FDIV"
                    }
                else
                    {
                    opcode = "IDIV"
                    }
            case .modulus:
                if self.type == generator.argonModule.float.type
                    {
                    opcode = "FMOD"
                    }
                else
                    {
                    opcode = "IMOD"
                    }
            case .and:
                opcode = "AND"
            case .or:
                opcode = "OR"
            case .rightBrocket:
                fallthrough
            case .rightBrocketEquals:
                fallthrough
            case .equals:
                fallthrough
            case .leftBrocket:
                fallthrough
            case .leftBrocketEquals:
                if self.type.isNotClass
                    {
                    print(self.rhs.displayString)
                    generator.dispatchError(at: self.declaration!, message: "The type of this expression is not defined.")
                    generator.cancelCompletion()
                    break
                    }
                if self.type.isPrimitiveClass
                    {
                    opcode = "CMPW"
                    }
                else
                    {
                    opcode = "CMPO"
                    }
            default:
                break
            }
        let temp = instance.nextTemporary()
        try self.lhs.emitCode(into: instance, using: generator)
        instance.append(nil,"MOV",self.lhs.place,.none,temp)
        try self.rhs.emitCode(into: instance, using: generator)
        instance.append(nil,opcode,temp,rhs.place,.none)
        if rhs.place.isNone
            {
            print("WARNING: In AssignmentExpression in line \(self.declaration!) RHS.place == .none")
            }
        self._place = temp
        }
    }
