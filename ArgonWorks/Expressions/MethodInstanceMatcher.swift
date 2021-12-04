//
//  MethodInstanceMatcher.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/12/21.
//

import Foundation

public class MethodInstanceMatcher
    {
    private let method: Method
    private let argumentTypes: Types
    private let argumentExpressions: Expressions
    private var origin: TypeConstraint.Origin!
    private let reportErrors: Bool
    private var enclosingScope: Scope!
    private var methodInstance: MethodInstance?
    private var location: Location!
    private var typeContext:TypeContext!
    private var readyInstances: MethodInstances!
    private var constraints = TypeConstraints()
    private var returnType: Type!
    
    init(method: Method,argumentExpressions:Expressions,reportErrors:Bool)
        {
        self.method = method
        self.argumentExpressions = argumentExpressions
        self.argumentTypes = argumentExpressions.map{$0.type!}
        self.reportErrors = reportErrors
        }
        
    internal func setOrigin(_ origin:TypeConstraint.Origin,location: Location)
        {
        self.origin = origin
        self.location = location
        }
        
    internal func setEnclosingScope(_ scope: Scope,inContext context:TypeContext)
        {
        self.typeContext = context
        self.enclosingScope = scope
        }
        
    internal func appendReturnType(_ type:Type)
        {
        self.returnType = type
        }
        
    internal func appendTypeConstraint(lhs: Type?,rhs: Type?)
        {
        self.constraints.append(TypeConstraint(left: lhs,right: rhs,origin: self.origin))
        }
        
    public func append(_ constraint: TypeConstraint)
        {
        self.constraints.append(constraint)
        }
        
    public func findMostSpecificMethodInstance() -> MethodInstance?
        {
        do
            {
            guard try self.foundSpecificInstance() else
                {
                return(nil)
                }
            return(self.methodInstance)
            }
        catch let error as CompilerIssue
            {
            self.append(error)
            return(nil)
            }
        catch let error
            {
            self.append(CompilerIssue(location: self.location,message: "Unexpected error: \(error)"))
            return(nil)
            }
        }
        
    private func foundSpecificInstance() throws -> Bool
        {
        print("OK: ARGUMENTS TYPES: \(self.argumentTypes)")
        let arity = self.argumentTypes.count
        print("OK: ARITY IS \(arity)")
        let instances = method.instancesWithArity(arity)
        if instances.isEmpty
            {
            print("FAIL: Could not find any instances with arity \(arity)")
            return(false)
            }
        print("OK: FOUND \(instances.count) INSTANCES WITH ARITY \(arity)")
        let typedInstances = instances.filter{!$0.hasVariableTypes}
        let untypedInstances = instances.filter{$0.hasVariableTypes}
        var readyInstances = typedInstances
        print("OK: FOUND \(readyInstances.count) INSTANCES READY TO TEST")
        print("OK: INFERRING TYPES FOR \(untypedInstances.count) INSTANCES")
        var mostSpecificInstance:MethodInstance?
        for instance in untypedInstances
            {
            print("OK: TESTING INSTANCE \(instance.displayString)")
            try self.typeContext.extended(withContentsOf: [])
                {
                newContext in
                let freshInstance = instance.freshTypeVariable(inContext: newContext)
                try freshInstance.initializeType(inContext: newContext)
                try freshInstance.initializeTypeConstraints(inContext: newContext)
                print("OK: GENERATED INSTANCE \(freshInstance.displayString)")
                var offset = 0
                for (argument,parameter) in zip(self.argumentTypes,freshInstance.parameters)
                    {
                    newContext.append(TypeConstraint(left: argument,right: parameter.type,origin: self.origin))
                    if parameter.type == freshInstance.returnType
                        {
                        newContext.append(TypeConstraint(left: argument,right: freshInstance.returnType,origin: self.origin))
                        }
                    for index in 0..<max(offset - 1,0)
                        {
                        if parameter.type == freshInstance.parameters[index].type
                            {
                            newContext.append(TypeConstraint(left: argument,right: self.argumentTypes[index],origin: self.origin))
                            }
                        }
                    offset += 1
                    }
                newContext.append(TypeConstraint(left: freshInstance.returnType,right: self.returnType,origin: self.origin))
                newContext.append(contentsOf: self.constraints)
                print("OK: USING \(self.constraints.count) CONSTRAINTS")
                let substitution = newContext.unify()
                print("OK: UNIFIED TYPES")
                let newInstance = substitution.substitute(freshInstance)
                let types = self.argumentTypes.map{substitution.substitute($0)}
                print("OK: SUBSTITUTED INSTANCE \(newInstance.displayString)")
                print("OK: ARGUMENTS ARE \(types)")
                if !newInstance.hasVariableTypes
                    {
                    print("OK: NEW INSTANCE DOES NOT HAVE ANY TYPE VARIABLES")
                    if newInstance.parameterTypesAreSupertypes(ofTypes: types)
                        {
                        print("OK: ARGUMENT TYPES \(types) ARE SUBTYPES OF NEW INSTANCE PARAMETERS \(newInstance.parameters)")
                        print("OK: \(newInstance.displayString) TESTED FOR SPECIFICITY")
                        readyInstances.append(newInstance)
                        mostSpecificInstance = readyInstances.sorted(by: {$0.moreSpecific(than: $1, forTypes: types)}).last
                        }
                    else
                        {
                        print("FAIL: \(newInstance.displayString) CAN NOT BE TESTED FOR SPECIFICITY BECAUSE ARGUMENTS ARE NOT SUBTYPES")
                        }
                    }
                else
                    {
                    print("FAIL: NEW INSTANCE STILL HAS TYPE VARIABLES")
                    }
                }
            }
        print("OK: COMPLETED TESTING OF \(readyInstances.count) INSTANCES")
        if mostSpecificInstance.isNil
            {
            print("FAIL: UNABLE TO FIND MOST SPECIFIC INSTANCE - BOOM")
            return(false)
            }
        print("OK: FOUND \(mostSpecificInstance.displayString) AS MOST SPECIFIC INSTANCE")
        self.methodInstance = mostSpecificInstance
        return(true)
        }
        
    public func appendTypeConstraints(for instance: MethodInstance,argumentTypes: Types,returnType: Type,to context: TypeContext)
        {
        var offset = 0
        for (argument,parameter) in zip(self.argumentTypes,instance.parameters)
            {
            context.append(TypeConstraint(left: argument,right: parameter.type,origin: self.origin))
            if parameter.type == instance.returnType
                {
                context.append(TypeConstraint(left: argument,right: instance.returnType,origin: self.origin))
                }
            for index in 0..<max(offset - 1,0)
                {
                if parameter.type == instance.parameters[index].type
                    {
                    context.append(TypeConstraint(left: argument,right: self.argumentTypes[index],origin: self.origin))
                    }
                }
            offset += 1
            }
        context.append(TypeConstraint(left: instance.returnType,right: returnType,origin: self.origin))
        }
        
    private func append(_ issue: CompilerIssue)
        {
        if self.reportErrors
            {
            switch(self.origin)
                {
                case .expression(let expression):
                    expression.appendIssue(issue)
                case .symbol(let symbol):
                    symbol.appendIssue(issue)
                case .block(let block):
                    block.appendIssue(issue)
                case .none:
                    break
                }
            }
        }
    }
