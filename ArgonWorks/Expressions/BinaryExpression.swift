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
    internal var methodInstances: MethodInstances = []
    
    internal var selectedMethodInstance: MethodInstance?
//        {
//        didSet
//            {
//            self.selectedMethodInstance?.setParent(self)
//            }
//        }
    
    init(_ lhs:Expression,_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operation) \(self.rhs.displayString)")
        }
        
    required init?(coder: NSCoder)
        {
        self.operation = coder.decodeTokenSymbol(forKey: "operation")
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        self.selectedMethodInstance = coder.decodeObject(forKey: "selectedMethodInstance") as? MethodInstance
        super.init(coder: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encodeTokenSymbol(self.operation,forKey: "operation")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        coder.encode(self.selectedMethodInstance,forKey: "selectedMethodInstance")
        super.encode(with: coder)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = context.freshTypeVariable()
        context.extended(withContentsOf: [])
            {
            newContext in
            newContext.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
            newContext.append(TypeConstraint(left: self.type,right: self.lhs.type,origin: .expression(self)))
            newContext.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .expression(self)))
            self.lhs.initializeTypeConstraints(inContext: newContext)
            self.rhs.initializeTypeConstraints(inContext: newContext)
            let substitution = newContext.unify()
            let leftType = substitution.substitute(self.lhs.type)
            let rightType = substitution.substitute(self.rhs.type)
            self.type = leftType
            self.selectedMethodInstance = MethodInstance(label: self.operation.rawValue)
            self.selectedMethodInstance!.parameters = [Parameter(label: "left", relabel: nil, type: leftType, isVisible: false, isVariadic: false),Parameter(label: "right", relabel: nil, type: rightType, isVisible: false, isVariadic: false)]
            self.selectedMethodInstance!.returnType = leftType
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = BinaryExpression(self.lhs.freshTypeVariable(inContext: context),self.operation,self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.selectedMethodInstance = self.selectedMethodInstance?.freshTypeVariable(inContext: context)
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = BinaryExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        expression.selectedMethodInstance = self.selectedMethodInstance.isNil ? nil : substitution.substitute(self.selectedMethodInstance!)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)BINARY EXPRESSION: \(self.operation)")
        print("\(indent)LHS: \(self.lhs.type.displayString)")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS: \(self.rhs.type.displayString)")
        self.rhs.display(indent: indent + "\t")
        if self.selectedMethodInstance.isNil
            {
            print("\(indent)SELECTED INSTANCE - NONE")
            }
        else
            {
            print("\(indent)SELECTED INSTANCE \(self.selectedMethodInstance!.displayString)")
            }
        }
        
    public override func emitValueCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        try self.emitCode(into: instance,using: generator)
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        guard let methodInstance = self.selectedMethodInstance else
            {
            print("ERROR: Can not generate code for BinaryExpression because method instance not selected.")
            return
            }
        try self.lhs.emitValueCode(into: instance, using: generator)
        try self.rhs.emitValueCode(into: instance, using: generator)
        let temporary = instance.nextTemporary()
        switch(self.operation.rawValue,methodInstance.returnType.label)
            {
            case ("+","Integer"):
                instance.append(.IADD64,self.lhs.place,self.rhs.place,temporary)
            case ("+","Float"):
                instance.append(.FADD64,self.lhs.place,self.rhs.place,temporary)
            case ("+","UInteger"):
                instance.append(.IADD64,self.lhs.place,self.rhs.place,temporary)
            case ("+","String"):
                instance.append(.SADD,self.lhs.place,self.rhs.place,temporary)
            case ("+","Byte"):
                instance.append(.IADD8,self.lhs.place,self.rhs.place,temporary)
            case ("+","Character"):
                instance.append(.IADD16,self.lhs.place,self.rhs.place,temporary)
            case ("-","Integer"):
                instance.append(.ISUB64,self.lhs.place,self.rhs.place,temporary)
            case ("-","Float"):
                instance.append(.FSUB64,self.lhs.place,self.rhs.place,temporary)
            case ("-","UInteger"):
                instance.append(.ISUB64,self.lhs.place,self.rhs.place,temporary)
            case ("-","Byte"):
                instance.append(.ISUB8,self.lhs.place,self.rhs.place,temporary)
            case ("-","Character"):
                instance.append(.ISUB16,self.lhs.place,self.rhs.place,temporary)
            case ("*","Integer"):
                instance.append(.IMUL64,self.lhs.place,self.rhs.place,temporary)
            case ("*","Float"):
                instance.append(.FMUL64,self.lhs.place,self.rhs.place,temporary)
            case ("*","UInteger"):
                instance.append(.IMUL64,self.lhs.place,self.rhs.place,temporary)
            case ("*","Byte"):
                instance.append(.IMUL8,self.lhs.place,self.rhs.place,temporary)
            case ("*","Character"):
                instance.append(.IMUL16,self.lhs.place,self.rhs.place,temporary)
            case ("/","Integer"):
                instance.append(.IDIV64,self.lhs.place,self.rhs.place,temporary)
            case ("/","Float"):
                instance.append(.FDIV64,self.lhs.place,self.rhs.place,temporary)
            case ("/","UInteger"):
                instance.append(.IDIV64,self.lhs.place,self.rhs.place,temporary)
            case ("/","Byte"):
                instance.append(.IDIV8,self.lhs.place,self.rhs.place,temporary)
            case ("/","Character"):
                instance.append(.IDIV16,self.lhs.place,self.rhs.place,temporary)
            case ("%","Integer"):
                instance.append(.IMOD64,self.lhs.place,self.rhs.place,temporary)
            case ("%","Float"):
                instance.append(.FMOD64,self.lhs.place,self.rhs.place,temporary)
            case ("%","UInteger"):
                instance.append(.IMOD64,self.lhs.place,self.rhs.place,temporary)
            case ("%","Byte"):
                instance.append(.IMOD8,self.lhs.place,self.rhs.place,temporary)
            case ("%","Character"):
                instance.append(.IMOD16,self.lhs.place,self.rhs.place,temporary)
            case ("**","Integer"):
                instance.append(.IPOW64,self.lhs.place,self.rhs.place,temporary)
            case ("**","Float"):
                instance.append(.FPOW64,self.lhs.place,self.rhs.place,temporary)
            case ("**","UInteger"):
                instance.append(.IPOW64,self.lhs.place,self.rhs.place,temporary)
            case ("&","Integer"):
                instance.append(.IAND64,self.lhs.place,self.rhs.place,temporary)
            case ("&","UInteger"):
                instance.append(.IAND64,self.lhs.place,self.rhs.place,temporary)
            case ("&","Byte"):
                instance.append(.IAND8,self.lhs.place,self.rhs.place,temporary)
            case ("&","Character"):
                instance.append(.IAND16,self.lhs.place,self.rhs.place,temporary)
            case ("|","Integer"):
                instance.append(.IOR64,self.lhs.place,self.rhs.place,temporary)
            case ("|","UInteger"):
                instance.append(.IOR64,self.lhs.place,self.rhs.place,temporary)
            case ("|","Byte"):
                instance.append(.IOR8,self.lhs.place,self.rhs.place,temporary)
            case ("|","Character"):
                instance.append(.IOR16,self.lhs.place,self.rhs.place,temporary)
            case ("^","Integer"):
                instance.append(.IXOR64,self.lhs.place,self.rhs.place,temporary)
            case ("^","UInteger"):
                instance.append(.IXOR64,self.lhs.place,self.rhs.place,temporary)
            case ("^","Byte"):
                instance.append(.IXOR8,self.lhs.place,self.rhs.place,temporary)
            case ("^","Character"):
                instance.append(.IXOR16,self.lhs.place,self.rhs.place,temporary)
            default:
                fatalError("This should be handled with a dynamic call.")
            }
        self._place = temporary
        }
    }



