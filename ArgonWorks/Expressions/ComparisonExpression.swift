//
//  ComparisonExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 3/12/21.
//

import Foundation

public class ComparisonExpression: BinaryExpression
    {
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
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ComparisonExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        expression.selectedMethodInstance = self.selectedMethodInstance
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try super.initializeType(inContext: context)
        self.type = context.booleanType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        if !self.methodInstances.isEmpty
            {
            let methodMatcher = MethodInstanceMatcher(methodInstances: self.methodInstances, argumentExpressions: [self.lhs,self.rhs], reportErrors: true)
            methodMatcher.setEnclosingScope(self.enclosingScope, inContext: context)
            methodMatcher.setOrigin(TypeConstraint.Origin.expression(self),location: self.declaration!)
            methodMatcher.appendTypeConstraint(lhs: self.lhs.type,rhs: self.rhs.type)
            methodMatcher.appendTypeConstraint(lhs: self.type,rhs: context.booleanType)
            methodMatcher.appendReturnType(context.booleanType)
            if let specificInstance = methodMatcher.findMostSpecificMethodInstance()
                {
                self.selectedMethodInstance = specificInstance
                print("FOUND MOST SPECIFIC INSTANCE = \(specificInstance.displayString)")
                }
            else
                {
                print("COULD NOT FIND MOST SPECIFIC METHOD INSTANCE")
                self.appendIssue(at: self.declaration!, message: "The most specific method for this invocation of ( '\(self.operation.rawValue)' ) can not be resolved. Try making it more specific.")
                }
            }
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        guard let methodInstance = self.selectedMethodInstance else
            {
            print("ERROR: Can not generate code for BinaryExpression because method instance not selected.")
            return
            }
        try self.lhs.emitRValue(into: instance, using: generator)
        try self.rhs.emitRValue(into: instance, using: generator)
        let temporary = instance.nextTemporary()
        switch(self.operation.rawValue,methodInstance.returnType.label)
            {
            case ("<","Integer"):
                instance.append("ILT64",self.lhs.place,self.rhs.place,temporary)
            case ("<","Float"):
                instance.append("FLT64",self.lhs.place,self.rhs.place,temporary)
            case ("<","UInteger"):
                instance.append("ILT64",self.lhs.place,self.rhs.place,temporary)
            case ("<","String"):
                instance.append("SLT",self.lhs.place,self.rhs.place,temporary)
            case ("<","Byte"):
                instance.append("ILT8",self.lhs.place,self.rhs.place,temporary)
            case ("<","Character"):
                instance.append("ILT16",self.lhs.place,self.rhs.place,temporary)
            case ("<=","Integer"):
                instance.append("ILTE64",self.lhs.place,self.rhs.place,temporary)
            case ("<=","Float"):
                instance.append("FLTE64",self.lhs.place,self.rhs.place,temporary)
            case ("<=","UInteger"):
                instance.append("ILTE64",self.lhs.place,self.rhs.place,temporary)
            case ("<=","String"):
                instance.append("SLTE",self.lhs.place,self.rhs.place,temporary)
            case ("<=","Byte"):
                instance.append("ILTE8",self.lhs.place,self.rhs.place,temporary)
            case ("<=","Character"):
                instance.append("ILTE16",self.lhs.place,self.rhs.place,temporary)
            case ("==","Integer"):
                instance.append("IEQ64",self.lhs.place,self.rhs.place,temporary)
            case ("==","Float"):
                instance.append("FEQ64",self.lhs.place,self.rhs.place,temporary)
            case ("==","UInteger"):
                instance.append("IEQ64",self.lhs.place,self.rhs.place,temporary)
            case ("==","String"):
                instance.append("SEQ",self.lhs.place,self.rhs.place,temporary)
            case ("==","Byte"):
                instance.append("IEQ8",self.lhs.place,self.rhs.place,temporary)
            case ("==","Character"):
                instance.append("IEQ16",self.lhs.place,self.rhs.place,temporary)
            case (">=","Integer"):
                instance.append("IGTE64",self.lhs.place,self.rhs.place,temporary)
            case (">=","Float"):
                instance.append("FGTE64",self.lhs.place,self.rhs.place,temporary)
            case (">=","UInteger"):
                instance.append("IGTE64",self.lhs.place,self.rhs.place,temporary)
            case (">=","String"):
                instance.append("SGTE",self.lhs.place,self.rhs.place,temporary)
            case (">=","Byte"):
                instance.append("IGTE8",self.lhs.place,self.rhs.place,temporary)
            case (">=","Character"):
                instance.append("IGTE16",self.lhs.place,self.rhs.place,temporary)
            case (">","Integer"):
                instance.append("IGT64",self.lhs.place,self.rhs.place,temporary)
            case (">","Float"):
                instance.append("FGT64",self.lhs.place,self.rhs.place,temporary)
            case (">","UInteger"):
                instance.append("IGT64",self.lhs.place,self.rhs.place,temporary)
            case (">","String"):
                instance.append("SGT",self.lhs.place,self.rhs.place,temporary)
            case (">","Byte"):
                instance.append("IGT8",self.lhs.place,self.rhs.place,temporary)
            case (">","Character"):
                instance.append("IGT16",self.lhs.place,self.rhs.place,temporary)
            default:
                fatalError("This should not happen.")
            }
        self._place = temporary
        }
    }
