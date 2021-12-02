//
//  TypeContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

fileprivate var TypeContextStack = Stack<TypeContext>()

public class TypeContext
    {
    private struct Context
        {
        let environment: Environment
        let constraints: TypeConstraints
        }
        
    public class Substitution
        {
        private static var typeVariableIndex = 0
        
        private var typeVariables = Dictionary<Int,Type>()
        
        init()
            {
            }
            
        init(_ substitution: Substitution)
            {
            self.typeVariables = substitution.typeVariables
            }
            
        public func freshTypeVariable(forTypeVariable old: Type) -> TypeVariable
            {
            let oldTypeVariable = old as! TypeVariable
            if let newVariable = self.typeVariables[oldTypeVariable.id]
                {
                return(newVariable as! TypeVariable)
                }
            let variable = TypeVariable(index: Self.typeVariableIndex)
            Self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func freshTypeVariable() -> TypeVariable
            {
            let variable = TypeVariable(index: Self.typeVariableIndex)
            Self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func freshTypeVariable(named: String) -> TypeVariable
            {
            for variable in self.typeVariables.values
                {
                if variable.label == named
                    {
                    return(variable as! TypeVariable)
                    }
                }
            let variable = TypeVariable(label: named)
            variable.id = Self.typeVariableIndex
            Self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func hasType(atIndex:Int) -> Bool
            {
            let value = self.typeVariables[atIndex]
            if let typeVariable = value as? TypeVariable
                {
                return(typeVariable.id != atIndex)
                }
            else if value.isNotNil
                {
                return(true)
                }
            return(false)
            }
            
        public func type(atIndex: Int) -> Type
            {
            let value = self.typeVariables[atIndex]
            if let typeVariable = value as? TypeVariable
                {
                if typeVariable.id != atIndex
                    {
                    let type = self.type(atIndex: typeVariable.id)
                    self.typeVariables[atIndex] = type
                    return(type)
                    }
                }
            return(value!)
            }
            
        private func occursIn(_ index:Int,_ type: Type) -> Bool
            {
            if let variable = type as? TypeVariable
                {
                if self.hasType(atIndex: variable.id)
                    {
                    return(self.occursIn(index,self.type(atIndex: variable.id)))
                    }
                return(variable.id == index)
                }
            if let constructor = type as? TypeConstructor
                {
                for generic in constructor.generics
                    {
                    if self.occursIn(index,generic)
                        {
                        return(true)
                        }
                    }
                }
            return(false)
            }
            
        public func substitute(_ argument: Argument) -> Argument
            {
            Argument(tag: argument.tag, value: self.substitute(argument.value))
            }
            
        public func substitute(_ parameter: Parameter) -> Parameter
            {
            Parameter(label: parameter.label, relabel: parameter.relabel, type: self.substitute(parameter.type), isVisible: parameter.isVisible, isVariadic: parameter.isVariadic)
            }
            
        public func substitute(_ type: Type) -> Type
            {
            if let typeVariable = type as? TypeVariable
                {
                if self.hasType(atIndex: typeVariable.id)
                    {
                    return(self.substitute(self.type(atIndex: typeVariable.id)))
                    }
                return(type)
                }
            if let typeClass = type as? TypeClass
                {
                return(TypeClass(class: typeClass.theClass,generics: typeClass.generics.map{self.substitute($0)}))
                }
            if let typeEnumeration = type as? TypeEnumeration
                {
                return(TypeEnumeration(enumeration: typeEnumeration.enumeration,generics: typeEnumeration.generics.map{self.substitute($0)}))
                }
            if let constructor = type as? TypeConstructor
                {
                return(TypeConstructor(label: constructor.label,generics: constructor.generics.map{self.substitute($0)}))
                }
            if let function = type as? TypeFunction
                {
                return(TypeFunction(label: function.label,types: function.generics.map{self.substitute($0)},returnType: self.substitute(function.returnType)))
                }
            return(type)
            }
            
        public func substitute(_ literal: Literal) -> Literal
            {
            literal.substitute(from: self)
            }
            
        public func substitute(_ tuple: Tuple) -> Tuple
            {
            Tuple(elements: tuple.elements.map{$0.substitute(from: self)})
            }
            
        public func substitute(_ symbol: Symbol) -> Symbol
            {
            let newSymbol = symbol.substitute(from: self)
            newSymbol.type = self.substitute(symbol.type)
            return(newSymbol)
            }
            
        public func substitute(_ expression: Expression) -> Expression
            {
            let newExpression = expression.substitute(from: self)
            newExpression.type = self.substitute(expression.type)
            newExpression.setParent(expression.parent)
            newExpression.issues = expression.issues
            return(newExpression)
            }
            
        public func substitute(_ container: ContainerSymbol) -> ContainerSymbol
            {
            let newModule = container.substitute(from: self)
            for symbol in container.symbols
                {
                let newSymbol = self.substitute(symbol)
                newModule.addSymbol(newSymbol)
                }
            newModule.type = self.substitute(container.type)
            return(newModule)
            }
            
        public func substitute(_ block: Block) -> Block
            {
            block.substitute(from: self)
            }
            
        public func substitute(_ methodInstance: MethodInstance) -> MethodInstance
            {
            let newReturnType = self.substitute(methodInstance.returnType)
            let newParameters = methodInstance.parameters.map{Parameter(label: $0.label, relabel: $0.relabel, type: self.substitute($0.type), isVisible: $0.isVisible, isVariadic: $0.isVariadic)}
            let newInstance = methodInstance.substitute(from: self)
            newInstance.type = self.substitute(methodInstance.type)
            newInstance.setParent(methodInstance.parent)
            newInstance.issues = methodInstance.issues
            return(newInstance)
            }
            
        public func unifySubtypes(_ lhs: Type,_ rhs:Type) throws
            {
            if let left = lhs as? TypeClass,let right = rhs as? TypeClass
                {
                if !left.theClass.isSubclass(of: right.theClass)
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.theClass.fullName.displayString) is not subclass of \(right.theClass.fullName.displayString)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeEnumeration,let right = rhs as? TypeEnumeration
                {
                if left.enumeration != right.enumeration
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.enumeration.fullName.displayString) \(right.enumeration.fullName.displayString)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeFunction,let right = rhs as? TypeFunction
                {
                try self.unifySubtypes(left.returnType,right.returnType)
                for (leftType,rightType) in zip(left.types,right.types)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeVariable,let right = rhs as? TypeVariable
                {
                if left == right
                    {
                    return
                    }
//                throw(CompilerIssue(location: .zero,message: "Type mismatch \(left.displayString) \(right.displayString)"))
                }
            if let left = lhs as? TypeVariable
                {
                if self.hasType(atIndex: left.id)
                    {
                    try self.unifySubtypes(self.type(atIndex: left.id),rhs)
                    return
                    }
                if self.occursIn(left.id,rhs)
                    {
                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(left.displayString)"))
                    }
                self.typeVariables[left.id] = rhs
                return
                }
            if let right = rhs as? TypeVariable
                {
                if self.hasType(atIndex: right.id)
                    {
                    try self.unifySubtypes(lhs,self.type(atIndex: right.id))
                    return
                    }
                if self.occursIn(right.id,lhs)
                    {
                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(right.displayString)"))
                    }
                self.typeVariables[right.id] = lhs
                return
                }
            }
            
        public func unify(_ lhs: Type,_ rhs:Type) throws
            {
            if let left = lhs as? TypeClass,let right = rhs as? TypeClass
                {
                if left.theClass != right.theClass
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.theClass.fullName.displayString) \(right.theClass.fullName.displayString)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeEnumeration,let right = rhs as? TypeEnumeration
                {
                if left.enumeration != right.enumeration
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.enumeration.fullName.displayString) \(right.enumeration.fullName.displayString)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeFunction,let right = rhs as? TypeFunction
                {
                try self.unify(left.returnType,right.returnType)
                for (leftType,rightType) in zip(left.types,right.types)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeVariable,let right = rhs as? TypeVariable
                {
                if left == right
                    {
                    return
                    }
//                throw(CompilerIssue(location: .zero,message: "Type mismatch \(left.displayString) \(right.displayString)"))
                }
            if let left = lhs as? TypeVariable
                {
                if self.hasType(atIndex: left.id)
                    {
                    try self.unify(self.type(atIndex: left.id),rhs)
                    return
                    }
                if self.occursIn(left.id,rhs)
                    {
                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(left.displayString)"))
                    }
                self.typeVariables[left.id] = rhs
                return
                }
            if let right = rhs as? TypeVariable
                {
                if self.hasType(atIndex: right.id)
                    {
                    try self.unify(lhs,self.type(atIndex: right.id))
                    return
                    }
                if self.occursIn(right.id,lhs)
                    {
                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(right.displayString)"))
                    }
                self.typeVariables[right.id] = lhs
                return
                }
            }
        }
        
    internal typealias Environment = Dictionary<Label,Type>
    private static let initialSubstitution = Substitution()
    
    public static func freshTypeVariable() -> TypeVariable
        {
        self.initialSubstitution.freshTypeVariable()
        }

    public static func freshTypeVariable(named: String) -> TypeVariable
        {
        self.initialSubstitution.freshTypeVariable(named: named)
        }
        
    public var voidType: Type
        {
        self.scope.topModule.argonModule.void
        }
        
    public var arrayType: Type
        {
        self.scope.topModule.argonModule.array
        }
        
    public var integerType: Type
        {
        self.scope.topModule.argonModule.integer
        }
        
    public var uIntegerType: Type
        {
        self.scope.topModule.argonModule.uInteger
        }
        
    public var stringType: Type
        {
        self.scope.topModule.argonModule.string
        }
        
    public var booleanType: Type
        {
        self.scope.topModule.argonModule.boolean
        }
        
    public var byteType: Type
        {
        self.scope.topModule.argonModule.byte
        }
        
    public var characterType: Type
        {
        self.scope.topModule.argonModule.character
        }
        
    public var floatType: Type
        {
        self.scope.topModule.argonModule.float
        }
        
    public var symbolType: Type
        {
        self.scope.topModule.argonModule.symbol
        }
        
    public var nilType: Type
        {
        self.scope.topModule.argonModule.nilClass
        }
        
    public var moduleType: Type
        {
        self.scope.topModule.argonModule.module
        }
        
    public var iterableType: Type
        {
        self.scope.topModule.argonModule.iterable
        }
        
    public var classType: Type
        {
        self.scope.topModule.argonModule.class
        }
        
    public var methodType: Type
        {
        self.scope.topModule.argonModule.method
        }
        
    public var functionType: Type
        {
        self.scope.topModule.argonModule.function
        }
        
    public var enumerationCaseType: Type
        {
        self.scope.topModule.argonModule.enumerationCase
        }
        
    private let scope: Scope
    private var environment = Environment()
    private var stack = Stack<Context>()
    private var substitution:Substitution
    internal private(set) var constraints = TypeConstraints()
    
    init(scope: Scope)
        {
        self.scope = scope
        self.environment = [:]
        self.substitution = Self.initialSubstitution
        print("FLOAT CLASS \(self.floatType)")
        print("INDEX OF FLOAT CLASS IS \((self.floatType as! TypeClass).theClass.index)")
        }
        
    public func freshTypeVariable(forTypeVariable old: Type) -> TypeVariable
        {
        self.substitution.freshTypeVariable(forTypeVariable: old)
        }
            
    public func freshTypeVariable() -> TypeVariable
        {
        self.substitution.freshTypeVariable()
        }
        
    internal func cancelCompletion()
        {
        }
        
    internal func dispatchError(at: Location,message: String)
        {
        fatalError()
        }
        
    internal func append(_ constraint: TypeConstraint)
        {
        self.constraints.append(constraint)
        }

    private func deepCopy() -> TypeContext
        {
        let newContext = TypeContext(scope: self.scope)
        newContext.environment = self.environment
        newContext.substitution = Substitution(self.substitution)
        return(newContext)
        }
        
    public func push() -> TypeContext
        {
        self.stack.push(Context(environment: self.environment,constraints: self.constraints))
        return(self)
        }
        
    @discardableResult
    public func pop() -> TypeContext
        {
        let context = self.stack.pop()
        self.environment = context.environment
        self.constraints = context.constraints
        return(self)
        }
        
    public func extended<T>(withContentsOf: TaggedTypes,closure: (TypeContext) throws -> T) throws -> T
        {
        let newContext = self.push()
        defer
            {
            self.pop()
            }
//        for type in withContentsOf
//            {
//            newContext.environment[Name(type.tag!)] = type.type
//            }
        return(try closure(newContext))
        }
        
    public func extended(with type: Type,boundTo label: Label) -> TypeContext
        {
        let context = self.push()
//        context.environment[Name(label)] = type
        return(context)
        }
        
    public func unify() -> Substitution
        {
        let newSubstitution = Substitution(self.substitution)
        for constraint in self.constraints
            {
            do
                {
                if constraint is SubTypeConstraint
                    {
                    try newSubstitution.unifySubtypes(constraint.lhs,constraint.rhs)
                    }
                else
                    {
                    try newSubstitution.unify(constraint.lhs,constraint.rhs)
                    }
                }
            catch let compilerIssue as CompilerIssue
                {
                let lineNumber = constraint.line
                let originType = constraint.originTypeString
                let newMessage = compilerIssue.message + " in " + originType
                constraint.origin.appendIssue(CompilerIssue(location: Location(line: lineNumber, lineStart: 0, lineStop: 0, tokenStart: 0, tokenStop: 0),message: newMessage))
                }
            catch let error
                {
                constraint.origin.appendIssue(CompilerIssue(location: .zero,message: "Unexpected error: \(error)"))
                }
            }
        return(newSubstitution)
        }
    }

public struct MethodInstanceType
    {
    public let parameters: Types
    public let returnType: Type
    }
