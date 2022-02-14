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
        expression.type = substitution.substitute(self.type)
        expression.selectedMethodInstance = self.selectedMethodInstance
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = BooleanExpression(self.lhs.freshTypeVariable(inContext: context),self.operation,self.rhs.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.selectedMethodInstance = self.selectedMethodInstance?.freshTypeVariable(inContext: context)
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.lhs.initializeType(inContext: context)
        self.rhs.initializeType(inContext: context)
        self.type = ArgonModule.shared.boolean
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.lhs.initializeTypeConstraints(inContext: context)
        self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: ArgonModule.shared.boolean,origin: .expression(self)))
        context.append(TypeConstraint(left: self.rhs.type,right: ArgonModule.shared.boolean,origin: .expression(self)))
        context.append(TypeConstraint(left: self.rhs.type,right: self.lhs.type,origin: .expression(self)))
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let temporary = instance.nextTemporary
        try self.lhs.emitValueCode(into: instance, using: generator)
        try self.rhs.emitValueCode(into: instance, using: generator)
        switch(self.operation.rawValue,"Boolean")
            {
            case ("&&","Boolean"):
                instance.add(.AND,self.lhs.place,self.rhs.place,temporary)
            case ("||","Boolean"):
                instance.add(.OR,self.lhs.place,self.rhs.place,temporary)
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
