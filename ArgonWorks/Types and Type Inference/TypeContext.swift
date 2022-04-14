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
        public weak var typeContext: TypeContext?
        private var typeVariableIndex = 0
        public var supressWarnings = false
        public var symbols = Dictionary<Int,Symbol>()
        
        private var typeVariables = Dictionary<Int,Type>()
        
        init(typeContext: TypeContext?)
            {
            self.typeContext = typeContext
            }
            
        init(_ substitution: Substitution)
            {
            self.typeVariables = substitution.typeVariables
            self.typeContext = substitution.typeContext
            self.typeVariableIndex = substitution.typeVariableIndex
            self.symbols = substitution.symbols
            }
            
        public func freshTypeVariable(forTypeVariable old: Type) -> TypeVariable
            {
            let oldTypeVariable = old as! TypeVariable
            if let newVariable = self.typeVariables[oldTypeVariable.id]
                {
                return(newVariable as! TypeVariable)
                }
            let variable = TypeVariable(index: self.typeVariableIndex)
            self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func freshTypeVariable() -> TypeVariable
            {
            let variable = TypeVariable(index: self.typeVariableIndex)
            self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func freshTypeVariable(named: String) -> TypeVariable
            {
            let variable = TypeVariable(label: named)
            variable.id = self.typeVariableIndex
            self.typeVariableIndex += 1
            self.typeVariables[variable.id] = variable
            return(variable)
            }
            
        public func freshTypeVariable(withId id: Int) -> TypeVariable
            {
            let variable = TypeVariable(index: id)
            self.typeVariableIndex = max(self.typeVariableIndex + 1,id + 1)
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
            
            
        public func substitute(_ enumeration: TypeEnumeration) -> TypeEnumeration
            {
            let new = enumeration.clone()
            new.cases = enumeration.cases.map{self.substitute($0)}
            return(new)
            }
            
        public func substitute(_ enumerationCase: EnumerationCase) -> EnumerationCase
            {
            let new = enumerationCase.clone()
            new.associatedTypes = enumerationCase.associatedTypes.map{self.substitute($0)}
            return(new)
            }
            
//        public func substitute(_ element: TupleElement) -> TupleElement
//            {
//            switch(element)
//                {
//                case .literal(let literal):
//                    return(.literal(self.substitute(literal)))
//                case .slot(let slot):
//                    return(.slot(self.substitute(slot)))
//                case .tuple(let tuple):
//                    return(.tuple(self.substitute(tuple)))
//                case .expression(let expression):
//                    return(.expression(self.substitute(expression)))
//                case .type(let type):
//                    return(.type(self.substitute(type)))
//                }
//            }
            
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
//                return(self.typeContext!.objectType)
                }
            if let symbol = self.symbols[type.argonHash] as? Type
                {
                return(symbol)
                }
            if let typeClass = type as? TypeMetaclass
                {
                if typeClass.generics.isEmpty
                    {
                    return(typeClass)
                    }
                let aType = typeClass.substitute(substitution: self)
                self.symbols[typeClass.argonHash] = aType
                return(aType)
                }
            if let typeClass = type as? TypeClass
                {
                if typeClass.generics.isEmpty
                    {
                    return(typeClass)
                    }
                let aType = typeClass.substitute(substitution: self)
                self.symbols[aType.argonHash] = aType
                return(aType)
                }
            if let typeEnumeration = type as? TypeEnumeration
                {
                let anEnum = TypeEnumeration(label: typeEnumeration.label,generics: typeEnumeration.generics.map{self.substitute($0)})
                self.symbols[typeEnumeration.argonHash] = anEnum
                return(anEnum)
                }
            if let application = type as? TypeApplication
                {
                return(TypeApplication(function: self.substitute(application.function) as! TypeFunction, types: application.types.map{self.substitute($0)}))
                }
            if let function = type as? TypeFunction
                {
                return(TypeFunction(label: function.label,types: function.generics.map{self.substitute($0)},returnType: self.substitute(function.returnType)))
                }
            if let constructor = type as? TypeConstructor
                {
                return(TypeConstructor(label: constructor.label,generics: constructor.generics.map{self.substitute($0)}))
                }
            return(type)
            }
            
        public func substitute(_ literal: Literal) -> Literal
            {
            literal.substitute(from: self)
            }
            
//        public func substitute(_ tuple: Tuple) -> Tuple
//            {
//            assert(!tuple.isEmpty)
//            let newTuple = Tuple(elements: tuple.elements.map{$0.substitute(from: self)})
//            assert(!newTuple.isEmpty)
//            return(newTuple)
//            }
            
        public func substitute(_ symbol: Symbol) -> Symbol
            {
            if let newSymbol = self.symbols[symbol.argonHash]
                {
                return(newSymbol)
                }
            let newSymbol = symbol.substitute(from: self)
            newSymbol.setMemoryAddress(symbol.memoryAddress)
            newSymbol.wasMemoryLayoutDone = symbol.wasMemoryLayoutDone
            newSymbol.wasSlotLayoutDone = symbol.wasSlotLayoutDone
            newSymbol.wasAddressAllocationDone = symbol.wasAddressAllocationDone
            newSymbol.type = symbol.type.isNil ? nil : self.substitute(symbol.type)
            self.symbols[symbol.argonHash] = newSymbol
            return(newSymbol)
            }
            
        public func substitute(_ slot: Slot) -> Slot
            {
            if let newSymbol = self.symbols[slot.argonHash] as? Slot
                {
                return(newSymbol)
                }
            let newSlot = slot.substitute(from: self)
            newSlot.type = self.substitute(slot.type)
            newSlot.offset = slot.offset
            self.symbols[slot.argonHash] = newSlot
            return(newSlot)
            }
            
        public func substitute(_ slot: MemberSlot) -> MemberSlot
            {
            if let newSymbol = self.symbols[slot.argonHash] as? MemberSlot
                {
                return(newSymbol)
                }
            let newSlot = slot.substitute(from: self)
            newSlot.owningType = slot.owningClass
            newSlot.type = self.substitute(slot.type)
            newSlot.offset = slot.offset
            self.symbols[slot.argonHash] = newSlot
            return(newSlot)
            }
            
        public func substitute(_ slot: LocalSlot) -> LocalSlot
            {
            if let newSymbol = self.symbols[slot.argonHash] as? LocalSlot
                {
                return(newSymbol)
                }
            let newSlot = slot.substitute(from: self)
            newSlot.type = self.substitute(slot.type)
            newSlot.offset = slot.offset
            self.symbols[slot.argonHash] = newSlot
            return(newSlot)
            }
            
        public func substitute(_ expression: Expression) -> Expression
            {
            let newExpression = expression.substitute(from: self)
            newExpression.type = self.substitute(expression.type)
            newExpression.issues = expression.issues
            return(newExpression)
            }
            
        public func substitute(_ closure: Closure) -> Closure
            {
            let newClosure = Closure(label: closure.label)
            newClosure.returnType = self.substitute(closure.returnType)
            for block in closure.block.blocks
                {
                newClosure.block.addBlock(self.substitute(block))
                }
            for symbol in closure.localSymbols
                {
                newClosure.localSymbols.append(self.substitute(symbol))
                }
            newClosure.type = self.substitute(closure.type)
            return(newClosure)
            }
            
        public func substitute(_ container: ContainerSymbol) -> ContainerSymbol
            {
            if let newSymbol = self.symbols[container.argonHash] as? ContainerSymbol
                {
                return(newSymbol)
                }
            let newModule = container.substitute(from: self)
            self.symbols[container.argonHash] = newModule
            for symbol in container.allSymbols
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
            if let symbol = self.symbols[methodInstance.argonHash] as? MethodInstance
                {
                return(symbol)
                }
            let newReturnType = self.substitute(methodInstance.returnType)
            let newParameters = methodInstance.parameters.map{Parameter(label: $0.label, relabel: $0.relabel, type: self.substitute($0.type), isVisible: $0.isVisible, isVariadic: $0.isVariadic)}
            let newInstance = methodInstance.substitute(from: self)
            newInstance.setIndex(methodInstance.index)
            newInstance.type = methodInstance.type.isNil ? nil : self.substitute(methodInstance.type)
            newInstance.issues = methodInstance.issues
            newInstance.parameters = newParameters
            newInstance.returnType = newReturnType
            newInstance.setMemoryAddress(methodInstance.memoryAddress)
            self.symbols[methodInstance.argonHash] = newInstance
            return(newInstance)
            }
            
        public func unifySubtypes(_ lhs: Type,_ rhs:Type) throws
            {
            if let left = lhs as? TypeAlias,let right = rhs as? TypeAlias
                {
                try self.unifySubtypes(left.type,right.type)
                return
                }
            if let left = lhs as? TypeMemberSlot,let right = rhs as? TypeMemberSlot
                {
                if left.slotLabel != right.slotLabel
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.base.displayString)->\(left.slotLabel) != \(right.base.displayString)->\(right.slotLabel)"))
                    }
                try self.unifySubtypes(left.base,right.base)
                return
                }
//            if let left = lhs as? TypeClass,let right = rhs as? TypeClass
//                {
//                if !left.isSubclass(of: right) || left.typeFlags != right.typeFlags
//                    {
//                    throw(CompilerIssue(location: .zero, message: "Type mismatch [\(left.fullName.displayString)] \(left.displayString)-\(left.index) is not equivalent to \(right.displayString)-\(right.index) [\(right.fullName.displayString)]"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unifySubtypes(leftType,rightType)
//                    }
//                return
//                }
//            if let left = lhs as? TypeMetaclass,let right = rhs as? TypeMetaclass
//                {
//                if !left.isSubclass(of: right) || left.typeFlags != right.typeFlags
//                    {
//                    throw(CompilerIssue(location: .zero, message: "Type mismatch [\(left.fullName.displayString)] \(left.displayString)-\(left.index) is not equivalent to \(right.displayString)-\(right.index) [\(right.fullName.displayString)]"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unifySubtypes(leftType,rightType)
//                    }
//                return
//                }
//            if let left = lhs as? TypeEnumeration,let right = rhs as? TypeEnumeration
//                {
//                if left != right
//                    {
//                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.fullName.displayString) \(right.fullName.displayString)"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unifySubtypes(leftType,rightType)
//                    }
//                return
//                }
            if let left = lhs as? TypeFunction,let right = rhs as? TypeFunction
                {
                try self.unifySubtypes(left.returnType,right.returnType)
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeConstructor,let right = rhs as? TypeConstructor
                {
                if let leftClass = left as? TypeClass,let rightClass = right as? TypeClass
                    {
                    if leftClass.isSubclass(of: rightClass)
                        {
                        return
                        }
                    }
                if left.label != right.label
                    {
                    throw(CompilerIssue(location: .zero, message: "Type mismatch \(left.label) != \(right.label)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeApplication,let right = rhs as? TypeApplication
                {
                try self.unifySubtypes(left.function,right.function)
                for (leftType,rightType) in zip(left.types,right.types)
                    {
                    try self.unifySubtypes(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeVariable,let right = rhs as? TypeVariable
                {
                if left.id == right.id
                    {
                    return
                    }
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
                    return
//                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(left.displayString) \(rhs.displayString)"))
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
                    return
//                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(right.displayString) \(lhs.displayString)"))
                    }
                self.typeVariables[right.id] = lhs
                return
                }
            }
            
        public func unify(_ lhs: Type,_ rhs:Type) throws
            {
            if let left = lhs as? TypeAlias,let right = rhs as? TypeAlias
                {
                try self.unify(left.type,right.type)
                return
                }
            if let left = lhs as? TypeMemberSlot,let right = rhs as? TypeMemberSlot
                {
                if left.slotLabel != right.slotLabel
                    {
                    throw(CompilerIssue(location: .zero, message: "Member slot mismatch \(left.base.displayString)->\(left.slotLabel) != \(right.base.displayString)->\(right.slotLabel)"))
                    }
                try self.unify(left.base,right.base)
                return
                }
//            if let left = lhs as? TypeClass,let right = rhs as? TypeClass
//                {
//                if left != right
//                    {
//                    throw(CompilerIssue(location: .zero, message: "Class mismatch [\(left.fullName.displayString)] \(left.displayString)-\(left.index) is not equivalent to \(right.displayString)-\(right.index) [\(right.fullName.displayString)]"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unify(leftType,rightType)
//                    }
//                return
//                }
//            if let left = lhs as? TypeMetaclass,let right = rhs as? TypeMetaclass
//                {
//                if left != right
//                    {
//                    throw(CompilerIssue(location: .zero, message: "Metaclass mismatch [\(left.fullName.displayString)] \(left.displayString)-\(left.index) is not equivalent to \(right.displayString)-\(right.index) [\(right.fullName.displayString)]"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unify(leftType,rightType)
//                    }
//                return
//                }
//            if let left = lhs as? TypeEnumeration,let right = rhs as? TypeEnumeration
//                {
//                if left != right
//                    {
//                    throw(CompilerIssue(location: .zero, message: "TypeEnumeration mismatch \(left.fullName.displayString) \(right.fullName.displayString)"))
//                    }
//                for (leftType,rightType) in zip(left.generics,right.generics)
//                    {
//                    try self.unify(leftType,rightType)
//                    }
//                return
//                }
            if let left = lhs as? TypeFunction,let right = rhs as? TypeFunction
                {
                try self.unify(left.returnType,right.returnType)
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeConstructor,let right = rhs as? TypeConstructor
                {
                if left.label != right.label || left.generics.count != right.generics.count
                    {
                    throw(CompilerIssue(location: .zero, message: "TypeConstructor mismatch \(left.label) != \(right.label)"))
                    }
                for (leftType,rightType) in zip(left.generics,right.generics)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeApplication,let right = rhs as? TypeApplication
                {
                if left.label != right.label
                    {
                    throw(CompilerIssue(location: .zero, message: "TypeApplication mismatch \(left.label) \(right.label)"))
                    }
                try self.unify(left.function,right.function)
                for (leftType,rightType) in zip(left.types,right.types)
                    {
                    try self.unify(leftType,rightType)
                    }
                return
                }
            if let left = lhs as? TypeVariable,let right = rhs as? TypeVariable
                {
                if left.id == right.id
                    {
                    return
                    }
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
                    return
//                    print("INFINITELY RECURSIVE TYPES")
//                    print("LHS: \(lhs.displayString)")
//                    print("RHS: \(rhs.displayString)")
//                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(left.displayString) \(rhs.displayString)"))
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
                    return
//                    throw(CompilerIssue(location: .zero,message: "Infinitely recursive type \(lhs.displayString) \(right.displayString)"))
                    }
                self.typeVariables[right.id] = lhs
                return
                }
            }
        }
        
    internal typealias Environment = Dictionary<Label,Type>
    internal var argonModule: ArgonModule!
    
    public static let initialSubstitution = Substitution(typeContext: nil)
    
    public static func freshTypeVariable() -> TypeVariable
        {
        self.initialSubstitution.freshTypeVariable()
        }

    public static func freshTypeVariable(named: String) -> TypeVariable
        {
        self.initialSubstitution.freshTypeVariable(named: named)
        }
        
    public static func freshTypeVariable(withId: Int) -> TypeVariable
        {
        self.initialSubstitution.freshTypeVariable(withId: withId)
        }
        
    public var objectType: Type
        {
        self.argonModule.object
        }
        
    public var objectClassType: Type
        {
        self.argonModule.objectClass
        }
        
    public var voidType: Type
        {
        self.argonModule.void
        }
    
    public var collectionType: Type
        {
        self.argonModule.collection
        }
        
    public var arrayType: Type
        {
        self.argonModule.array
        }
        
    public var integerType: Type
        {
        self.argonModule.integer
        }
        
    public var uIntegerType: Type
        {
        self.argonModule.uInteger
        }
        
    public var stringType: Type
        {
        self.argonModule.string
        }
        
    public var booleanType: Type
        {
        self.argonModule.boolean
        }
        
    public var byteType: Type
        {
        self.argonModule.byte
        }
        
    public var characterType: Type
        {
        self.argonModule.character
        }
        
    public var dateType: Type
        {
        self.argonModule.date
        }
        
    public var timeType: Type
        {
        self.argonModule.time
        }
        
    public var dateTimeType: Type
        {
        self.argonModule.dateTime
        }
        
    public var metaclassType: Type
        {
        self.argonModule.metaclassType
        }
        
    public var floatType: Type
        {
        self.argonModule.float
        }
        
    public var symbolType: Type
        {
        self.argonModule.symbol
        }
        
    public var nullType: Type
        {
        self.argonModule.null
        }
        
    public var moduleType: Type
        {
        self.argonModule.moduleType
        }
        
    public var iterableType: Type
        {
        self.argonModule.iterable
        }
        
    public var classType: Type
        {
        self.argonModule.classType
        }

    public var functionType: Type
        {
        self.argonModule.function
        }
        
    public var enumerationCaseType: Type
        {
        self.argonModule.enumerationCase
        }
        
//    private let scope: Scope
    private var environment = Environment()
    private static var stack = Stack<Context>()
    private var substitution:Substitution
    internal private(set) var constraints = TypeConstraints()
    
    init()
        {
//        self.scope = scope
        self.environment = [:]
        self.substitution = Self.initialSubstitution
        self.substitution.typeContext = self
        }
        
    public func suppressWarnings()
        {
        self.substitution.supressWarnings = true
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

    internal func append(contentsOf: [TypeConstraint])
        {
        self.constraints.append(contentsOf: contentsOf)
        }
        
    public func bind(_ type:Type,to label:Label)
        {
        self.environment[label] = type
        }
        
    public func lookupBinding(atLabel label: Label) -> Type?
        {
        self.environment[label]
        }
        
    public func extended<T>(with: Array<(Label,Type)>,closure: (TypeContext) -> T) -> T
        {
        let context = TypeContext()
        let newSubstitution = Substitution(self.substitution)
        context.substitution = newSubstitution
        context.substitution.typeContext = context
        context.environment = self.environment
        for value in with
            {
            context.environment[value.0] = value.1
            }
        context.constraints = self.constraints
//        for type in withContentsOf
//            {
//            newContext.environment[Name(type.tag!)] = type.type
//            }
        return(closure(context))
        }
        
    public func extended<T>(withContentsOf: TaggedTypes,closure: (TypeContext) -> T) -> T
        {
        let context = TypeContext()
        let newSubstitution = Substitution(self.substitution)
        context.substitution = newSubstitution
        context.substitution.typeContext = context
        context.environment = self.environment
        context.constraints = self.constraints
//        for type in withContentsOf
//            {
//            newContext.environment[Name(type.tag!)] = type.type
//            }
        return(closure(context))
        }
        
    public func extended(with type: Type,boundTo label: Label) -> TypeContext
        {
        let context = TypeContext()
        let newSubstitution = Substitution(self.substitution)
        context.substitution = newSubstitution
        context.substitution.typeContext = context
        context.environment = self.environment
        context.constraints = self.constraints
//        context.environment[Name(label)] = type
        return(context)
        }
        
    public func unify() -> Substitution
        {
        let newSubstitution = Substitution(self.substitution)
        let newConstraints = self.constraints
        for constraint in newConstraints
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
                let newMessage = compilerIssue.message + " in " + originType + constraint.origin.diagnosticString
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
