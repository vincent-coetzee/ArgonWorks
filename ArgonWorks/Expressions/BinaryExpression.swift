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
    internal var returnType: Type?
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
        self.type = self.rhs.type

        
//        context.extended(withContentsOf: [])
//            {
//            newContext in
//            newContext.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
//            newContext.append(TypeConstraint(left: self.type,right: self.lhs.type,origin: .expression(self)))
//            newContext.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .expression(self)))
//            self.lhs.initializeTypeConstraints(inContext: newContext)
//            self.rhs.initializeTypeConstraints(inContext: newContext)
//            let substitution = newContext.unify()
//            let leftType = substitution.substitute(self.lhs.type)
//            let rightType = substitution.substitute(self.rhs.type)
//            self.type = leftType
//            self.selectedMethodInstance = MethodInstance(label: self.operation.rawValue)
//            self.selectedMethodInstance!.parameters = [Parameter(label: "left", relabel: nil, type: leftType, isVisible: false, isVariadic: false),Parameter(label: "right", relabel: nil, type: rightType, isVisible: false, isVariadic: false)]
//            self.selectedMethodInstance!.returnType = leftType
//            }
        }
        
//    public func mostSpecificMethodInstance() -> MethodInstance?
//        {
//        let lhsType = self.lhs.type
//        let rhsType = self.rhs.type
//        let types = [lhsType,rhsType]
//        let sorted = self.methodInstances.sorted{$0.moreSpecific(than: $1, forTypes: types)}
//        return(sorted.first)
//        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
        context.append(TypeConstraint(left: self.type,right: self.rhs.type,origin: .expression(self)))
        context.append(TypeConstraint(left: self.type,right: self.lhs.type,origin: .expression(self)))
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = BinaryExpression(self.lhs.freshTypeVariable(inContext: context),self.operation,self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = BinaryExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
        let leftType = self.lhs.type
        let rightType = self.rhs.type
        if leftType == rightType
            {
            expression.returnType = leftType
            }
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
        
    public override func emitValueCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.emitCode(into: instance,using: generator)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitValueCode(into: instance, using: generator)
        try self.rhs.emitValueCode(into: instance, using: generator)
        let temporary = instance.nextTemporary
        let type = self.type
//            generator.registerMethodInstanceIfNeeded(methodInstance)
        var mode:Instruction.Mode
        switch(type.label)
            {
            case("Integer"):
                mode = .i64
            case("Float"):
                mode = .f64
            case("UInteger"):
                mode = .iu64
            case("String"):
                mode = .string
            case("Character"):
                mode = .i16
            case("Byte"):
                mode = .i8
            default:
                mode = .none
            }
        switch(self.operation.rawValue)
            {
            case("+"):
                instance.add(mode,.ADD,self.lhs.place,self.rhs.place,temporary)
            case("-"):
                instance.add(mode,.SUB,self.lhs.place,self.rhs.place,temporary)
            case("*"):
                instance.add(mode,.MUL,self.lhs.place,self.rhs.place,temporary)
            case("/"):
                instance.add(mode,.DIV,self.lhs.place,self.rhs.place,temporary)
            case("%"):
                instance.add(mode,.MOD,self.lhs.place,self.rhs.place,temporary)
            case("**"):
                instance.add(mode,.POW,self.lhs.place,self.rhs.place,temporary)
            case("&"):
                instance.add(mode,.LAND,self.lhs.place,self.rhs.place,temporary)
            case("|"):
                instance.add(mode,.LOR,self.lhs.place,self.rhs.place,temporary)
            case("^"):
                instance.add(mode,.LXOR,self.lhs.place,self.rhs.place,temporary)
            default:
                let label = "#" + self.operation.rawValue
                let symbol = Argon.Integer(generator.payload.symbolRegistry.registerSymbol(label))
                instance.add(.PUSH,self.lhs.place)
                instance.add(.PUSH,self.rhs.place)
                instance.add(.SEND,.integer(symbol),temporary)
                instance.add(.POPN,.integer(2))
            }
        self._place = temporary
        }
    }



