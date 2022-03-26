//
//  ComparisonExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 3/12/21.
//

import Foundation

public class ComparisonExpression: BinaryExpression
    {
    internal var valueType: Type?
    
    public override var diagnosticString: String
        {
        "\(self.lhs.displayString) \(self.operation) \(self.rhs.displayString)"
        }
        
    public override func display(indent: String)
        {
        print("\(indent)COMPARISON EXPRESSION: \(self.operation)")
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
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = ComparisonExpression(self.lhs.freshTypeVariable(inContext: context),self.operation,self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.selectedMethodInstance = self.selectedMethodInstance?.freshTypeVariable(inContext: context)
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ComparisonExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type)
//        expression.selectedMethodInstance = self.selectedMethodInstance.isNil ? nil : substitution.substitute(self.selectedMethodInstance!)
//        self.selectedMethodInstance = expression.mostSpecificMethodInstance()
        if expression.lhs.type == expression.rhs.type
            {
            expression.valueType = expression.lhs.type
            }
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        super.initializeType(inContext: context)
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = ArgonModule.shared.boolean
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
        context.append(TypeConstraint(left: self.type,right: ArgonModule.shared.boolean,origin: .expression(self)))
//        if !self.methodInstances.isEmpty
//            {
//            let methodMatcher = MethodInstanceMatcher(typeContext: context,methodInstances: self.methodInstances, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
//            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
//            methodMatcher.appendTypeConstraint(lhs: self.lhs.type,rhs: self.rhs.type)
//            methodMatcher.appendTypeConstraint(lhs: self.type,rhs: context.booleanType)
//            methodMatcher.appendReturnType(context.booleanType)
//            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
//                {
//                self.selectedMethodInstance = specificInstance
//                }
//            else
//                {
//                self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operation.rawValue)' ) can not be resolved. Try making it more specific.")
//                }
//            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitValueCode(into: instance, using: generator)
        try self.rhs.emitValueCode(into: instance, using: generator)
        let temporary = instance.nextTemporary
        if let type = self.valueType
            {
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
            switch(self.operation)
                {
                case("<"):
                    instance.add(mode,.LT,self.lhs.place,self.rhs.place,temporary)
                case("<="):
                    instance.add(mode,.LTE,self.lhs.place,self.rhs.place,temporary)
                case("=="):
                    instance.add(mode,.EQ,self.lhs.place,self.rhs.place,temporary)
                case(">="):
                    instance.add(mode,.GTE,self.lhs.place,self.rhs.place,temporary)
                case(">"):
                    instance.add(mode,.GT,self.lhs.place,self.rhs.place,temporary)
                case("!="):
                    instance.add(mode,.NEQ,self.lhs.place,self.rhs.place,temporary)
                default:
                    fatalError("Invalid comparison")
                }
//            generator.registerMethodInstanceIfNeeded(methodInstance)
            }
        else
            {
            let label = "#" + self.operation
            let symbol = Argon.Integer(generator.payload.symbolRegistry.registerSymbol(label))
            instance.add(.PUSH,self.lhs.place)
            instance.add(.PUSH,self.rhs.place)
            instance.add(.SEND,.integer(symbol),temporary)
            instance.add(.POPN,.integer(2))
            }
        self._place = temporary
        }
    }
