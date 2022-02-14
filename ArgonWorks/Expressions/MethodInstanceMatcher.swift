//
//  MethodInstanceMatcher.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/12/21.
//

import Foundation

public class MethodInstanceMatcher
    {
    private let methodInstances: MethodInstances
    private let argumentTypes: Types
    private let argumentExpressions: Expressions
    private var origin: TypeConstraint.Origin!
    private let reportErrors: Bool
    private var methodInstance: MethodInstance?
    private var location: Location!
    private var typeContext:TypeContext!
    private var readyInstances: MethodInstances!
    private var constraints = TypeConstraints()
    private var returnType: Type!
    
    init(typeContext: TypeContext,methodInstances: MethodInstances,argumentExpressions:Expressions,reportErrors:Bool)
        {
        self.typeContext = typeContext
        self.methodInstances = methodInstances
        self.argumentExpressions = argumentExpressions
        self.argumentTypes = argumentExpressions.map{$0.type}
        self.reportErrors = reportErrors
        }
        
    internal func setOrigin(_ origin:TypeConstraint.Origin,location: Location)
        {
        self.origin = origin
        self.location = location
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
        guard self.foundSpecificInstance() else
            {
            return(nil)
            }
        return(self.methodInstance)
        }
        
    private func foundSpecificInstance() -> Bool
        {
//        print("OK: ARGUMENTS TYPES: \(self.argumentTypes)")
        let arity = self.argumentTypes.count
//        print("OK: ARITY IS \(arity)")
        let instances = methodInstances.filter{$0.parameters.count == arity}
        if instances.isEmpty
            {
//            print("FAIL: Could not find any instances with arity \(arity)")
            return(false)
            }
//        print("OK: FOUND \(instances.count) INSTANCES WITH ARITY \(arity)")
//        print("OK: INFERRING TYPES FOR \(instances.count) INSTANCES")
        var readyInstances = MethodInstances()
        var mostSpecificInstance:MethodInstance?
        if readyInstances.isEmpty && instances.isEmpty
            {
            fatalError("You need to handle this case.")
            }
        for instance in instances
            {
//            print("OK: TESTING INSTANCE \(instance.displayString)")
            self.typeContext.extended(withContentsOf: [])
                {
                newContext in
                instance.initializeType(inContext: newContext)
                instance.initializeTypeConstraints(inContext: newContext)
//                print("OK: GENERATED INSTANCE \(instance.displayString)")
                var offset = 0
                for (argument,parameter) in zip(self.argumentTypes,instance.parameters)
                    {
                    newContext.append(TypeConstraint(left: argument,right: parameter.type,origin: self.origin))
                    if parameter.type == instance.returnType
                        {
                        newContext.append(TypeConstraint(left: argument,right: instance.returnType,origin: self.origin))
                        }
                    for index in 0..<max(offset - 1,0)
                        {
                        if parameter.type == instance.parameters[index].type
                            {
                            newContext.append(TypeConstraint(left: argument,right: self.argumentTypes[index],origin: self.origin))
                            }
                        }
                    offset += 1
                    }
                newContext.append(TypeConstraint(left: instance.returnType,right: self.returnType,origin: self.origin))
                newContext.append(contentsOf: self.constraints)
//                print("OK: USING \(self.constraints.count) CONSTRAINTS")
                newContext.suppressWarnings()
                let substitution = newContext.unify()
//                print("OK: UNIFIED TYPES")
                let newInstance = substitution.substitute(instance)
                assert(instance.module != nil)
                newInstance.originalMethodInstance = instance
                newInstance.setMemoryAddress(instance.memoryAddress)
                newInstance.setModule(instance.module)
                let types = self.argumentTypes.map{substitution.substitute($0)}
//                print("OK: SUBSTITUTED INSTANCE \(newInstance.displayString)")
//                print("OK: ARGUMENTS ARE \(types)")
                if !newInstance.hasVariableTypes
                    {
//                    print("OK: NEW INSTANCE DOES NOT HAVE ANY TYPE VARIABLES")
                    if newInstance.parameterTypesAreSupertypes(ofTypes: types)
                        {
//                        print("OK: ARGUMENT TYPES \(types) ARE SUBTYPES OF NEW INSTANCE PARAMETERS \(newInstance.parameters)")
                        readyInstances.append(newInstance)
                        mostSpecificInstance = readyInstances.sorted(by: {$0.moreSpecific(than: $1, forTypes: types)}).last
//                        print("OK: \(newInstance.displayString) TESTED FOR SPECIFICITY")
                        }
                    else
                        {
//                        print("FAIL: \(newInstance.displayString) CAN NOT BE TESTED FOR SPECIFICITY BECAUSE ARGUMENTS ARE NOT SUBTYPES")
                        }
                    }
                else
                    {
//                    print("FAIL: NEW INSTANCE STILL HAS TYPE VARIABLES")
                    }
                
                }
            }
//        print("OK: COMPLETED TESTING OF \(readyInstances.count) INSTANCES")
        if mostSpecificInstance.isNil
            {
//            print("FAIL: UNABLE TO FIND MOST SPECIFIC INSTANCE - BOOM")
            return(false)
            }
//        print("OK: FOUND \(mostSpecificInstance.displayString) AS MOST SPECIFIC INSTANCE")
        self.methodInstance = mostSpecificInstance
        return(true)
        }
        
    public func appendTypeConstraints(to context: TypeContext)
        {
        var offset = 0
        for (argument,parameter) in zip(argumentTypes,self.methodInstance!.parameters)
            {
            context.append(TypeConstraint(left: argument,right: parameter.type,origin: self.origin))
            if parameter.type == self.methodInstance!.returnType
                {
                context.append(TypeConstraint(left: argument,right: self.methodInstance!.returnType,origin: self.origin))
                }
            for index in 0..<max(offset - 1,0)
                {
                if parameter.type == self.methodInstance!.parameters[index].type
                    {
                    context.append(TypeConstraint(left: argument,right: self.argumentTypes[index],origin: self.origin))
                    }
                }
            offset += 1
            }
        context.append(TypeConstraint(left: self.methodInstance!.returnType,right: self.returnType,origin: self.origin))
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
                case .tuple:
                    break
                }
            }
        }
    }
