//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation
    
public class BinaryExpression: Expression
    {
    public override var diagnosticString: String
        {
        "BinaryExpression(\(self.operation.rawValue))"
        }
        
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
    internal var method: Method?
    internal var methodInstance: MethodInstance?
    
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
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        if let methods = self.enclosingScope.lookupN(label: operation.rawValue)
            {
            if let selectedMethod = methods.filter({$0 is InfixOperator}).first as? InfixOperator
                {
                self.method = selectedMethod
                self.type = selectedMethod.returnType
                }
            else
                {
                self.appendIssue(at: self.declaration!, message: "The operator \(self.operation) of the correct type can not be resolved.")
                self.type = context.voidType
                }
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The operator \(self.operation) can not be resolved.")
            self.type = context.voidType
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = BinaryExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        return(expression as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        print("BINARY EXPRESSION")
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        if let method = self.method
            {
            let methodMatcher = MethodInstanceMatcher(method: method, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
            methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
            methodMatcher.appendReturnType(self.type!)
            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
                {
                self.methodInstance = specificInstance
                print("FOUND MOST SPECIFIC INSTANCE FOR \(self.operation.rawValue) = \(specificInstance.displayString)")
                methodMatcher.appendTypeConstraints(for: specificInstance, argumentTypes: [self.lhs.type!], returnType: self.type!, to: context)
                }
            else
                {
                print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE FOR \(method.label)")
                self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(method.label)' ) can not be resolved. Try making it more specific.")
                }
            }
        }
        
    public override func display(indent: String)
        {
        print("\(indent)BINARY EXPRESSION: \(self.operation)")
        print("\(indent)LHS: \(self.lhs.type.displayString)")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS: \(self.rhs.type.displayString)")
        self.rhs.display(indent: indent + "\t")
        if self.methodInstance.isNil
            {
            print("\(indent)SELECTED INSTANCE - NONE")
            }
        else
            {
            print("\(indent)SELECTED INSTANCE \(self.methodInstance!.displayString)")
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



