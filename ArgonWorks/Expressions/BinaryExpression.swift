//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation
    
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
        
    internal let operation: Token.Symbol
    internal let rhs: Expression
    internal let lhs: Expression
    
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

    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
//        let left = self.lhs.type
//        let right = self.rhs.type
//        switch(self.operation)
//            {
//            case .and:
//                fallthrough
//            case .or:
//                if left.isSameClass(self.enclosingScope.topModule.argonModule.boolean) && right.isSameClass(self.enclosingScope.topModule.argonModule.boolean)
//                    {
//                    break
//                    }
//                analyzer.cancelCompletion()
//                analyzer.dispatchError(at: self.declaration!,message: "Invalid argument types for \(self.operation).")
//            case .leftBrocket:
//                fallthrough
//            case .leftBrocketEquals:
//                fallthrough
//            case .equals:
//                fallthrough
//            case .rightBrocket:
//                fallthrough
//            case .rightBrocketEquals:
//                if left.isPrimitiveClass && right.isPrimitiveClass
//                    {
//                    break
//                    }
//                if left.isEnumeration && right.isEnumeration
//                    {
//                    break
//                    }
//                if left.isObjectClass && right.isObjectClass
//                    {
//                    break
//                    }
//                analyzer.cancelCompletion()
//                analyzer.dispatchError(at: self.declaration!,message: "The types on the left side and right side of this expression do not match.")
//                return
//        default:
//            if left == right
//                {
//                break
//                }
//            analyzer.cancelCompletion()
//            analyzer.dispatchError(at: self.declaration!,message: "The types on the left side and right side of this expression do not match.")
//            }
        }
        
    required init?(coder: NSCoder)
        {
        self.operation = coder.decodeTokenSymbol(forKey: "operation")
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
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
        
    public override func deepCopy() -> Self
        {
        return(BinaryExpression(self.lhs.deepCopy(),self.operation,self.rhs.deepCopy()) as! Self)
        }
        
    public override func substitute(from context: TypeContext)
        {
        self.lhs.substitute(from: context)
        self.rhs.substitute(from: context)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        if let method = self.enclosingScope.lookup(label: operation.rawValue) as? Method
            {
            let instance = method.mostSpecificInstance(forTypes: [self.lhs.type,self.rhs.type])
            print(instance)
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The method \(self.operation) can not be resolved.")
            }
        }
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        if let method = self.enclosingScope.lookup(label: operation.rawValue) as? Method
            {
            try self.lhs.initializeTypeConstraints(inContext: context)
            try self.rhs.initializeTypeConstraints(inContext: context)
            let argTypes = [self.lhs.type,self.rhs.type]
            let functionType = TypeFunction(types: argTypes, returnType: method.returnType)
            context.append(TypeConstraint(left: self.type, right: functionType, origin: .expression(self)))
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "Unable to resolve binary operation '\(self.operation)' so method can not be dispatched.")
            }
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
//        if let location = self.declaration
//            {
//            instance.append(lineNumber: location.line)
//            }
//        var opcode: String = "NOP"
//        switch(self.operation)
//            {
//            case .add:
//                if self.type == generator.argonModule.float.type
//                    {
//                    opcode = "FADD"
//                    }
//                else
//                    {
//                    opcode = "IADD"
//                    }
//            case .sub:
//                if self.type == generator.argonModule.float.type
//                    {
//                    opcode = "FSUB"
//                    }
//                else
//                    {
//                    opcode = "ISUB"
//                    }
//            case .mul:
//                if self.type == generator.argonModule.float.type
//                    {
//                    opcode = "FMUL"
//                    }
//                else
//                    {
//                    opcode = "IMUL"
//                    }
//            case .div:
//                if self.type == generator.argonModule.float.type
//                    {
//                    opcode = "FDIV"
//                    }
//                else
//                    {
//                    opcode = "IDIV"
//                    }
//            case .modulus:
//                if self.type == generator.argonModule.float.type
//                    {
//                    opcode = "FMOD"
//                    }
//                else
//                    {
//                    opcode = "IMOD"
//                    }
//            case .and:
//                opcode = "AND"
//            case .or:
//                opcode = "OR"
//            case .rightBrocket:
//                fallthrough
//            case .rightBrocketEquals:
//                fallthrough
//            case .equals:
//                fallthrough
//            case .leftBrocket:
//                fallthrough
//            case .leftBrocketEquals:
//                if self.type.isNotClass
//                    {
//                    print(self.rhs.displayString)
//                    generator.dispatchError(at: self.declaration!, message: "The type of this expression is not defined.")
//                    generator.cancelCompletion()
//                    break
//                    }
//                if self.type.isPrimitiveClass
//                    {
//                    opcode = "CMPW"
//                    }
//                else
//                    {
//                    opcode = "CMPO"
//                    }
//            default:
//                break
//            }
//        let temp = instance.nextTemporary()
//        try self.lhs.emitCode(into: instance, using: generator)
//        instance.append(nil,"MOV",self.lhs.place,.none,temp)
//        try self.rhs.emitCode(into: instance, using: generator)
//        instance.append(nil,opcode,temp,rhs.place,.none)
//        if rhs.place.isNone
//            {
//            print("WARNING: In AssignmentExpression in line \(self.declaration!) RHS.place == .none")
//            }
//        self._place = temp
        }
    }

public class ComparisonExpression: BinaryExpression
    {
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        self.type = context.booleanType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        }
        
    public override func deepCopy() -> Self
        {
        return(ComparisonExpression(self.lhs.deepCopy(),self.operation,self.rhs.deepCopy()) as! Self)
        }
    }

public class BooleanExpression: BinaryExpression
    {
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        self.type = context.booleanType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: context.booleanType,origin: .expression(self)))
        context.append(TypeConstraint(left: self.rhs.type,right: context.booleanType,origin: .expression(self)))
        }
        
    public override func deepCopy() -> Self
        {
        return(BooleanExpression(self.lhs.deepCopy(),self.operation,self.rhs.deepCopy()) as! Self)
        }
    }
