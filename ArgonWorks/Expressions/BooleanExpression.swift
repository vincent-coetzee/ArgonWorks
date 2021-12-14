//
//  BooleanExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 3/12/21.
//

import Foundation

public class BooleanExpression: BinaryExpression
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = BooleanExpression(substitution.substitute(self.lhs),self.operation,substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        expression.selectedMethodInstance = self.selectedMethodInstance
        expression.issues = self.issues
        return(expression as! Self)
        }
        
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
            case ("&&","Boolean"):
                instance.append("IADD64",self.lhs.place,self.rhs.place,temporary)
            case ("||","Boolean"):
                instance.append("IADD64",self.lhs.place,self.rhs.place,temporary)
            default:
                fatalError("This should not happen.")
            }
        self._place = temporary
        }
    }
