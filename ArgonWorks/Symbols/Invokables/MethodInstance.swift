//
//  MethodInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

   public enum SpecificOrdering
        {
        case more
        case unordered
        case less
        }
        
public struct TagSignature: Equatable
    {
    internal let tags: Array<Label?>
    
    init(tags:  Array<Label?>)
        {
        self.tags = tags
        }
        
    init(arguments: Arguments)
        {
        self.tags = arguments.map{$0.tag}
        }
        
    internal func withArguments(_ arguments: Arguments) -> TagSignature
        {
        var newTags = Array<Label>()
        var index = 0
        for argument in arguments
            {
            if argument.tag.isNil
                {
                newTags.append(self.tags[index]!)
                }
            else
                {
                newTags.append(argument.tag!)
                }
            index += 1
            }
        return(TagSignature(tags: newTags))
        }
    }
    
public class MethodInstance: Function,Scope
    {
    public override var declaration: Location?
        {
        self.method.declaration
        }
        
    public var isSlotScope: Bool
        {
        false
        }
        
    public var typeSignature:TypeSignature
        {
        TypeSignature(label: self.label,types: self.parameters.map{$0.type},returnType: self.returnType)
        }
        
    public var mangledName: String
        {
        let start = self.label
        let next = self.parameters.map{$0.type.mangledName}.joined(separator: "_")
        let end = "=" + self.returnType.mangledName
        return(start + "." + next + end)
        }
        
    ///
    ///
    /// A method instance is concrete if all the parameters and the return type
    /// have types that contain a concrete type, i.e. there are no type variables
    /// in place of types anywhere.
    ///
    ///
    public var isConcreteInstance: Bool
        {
        if self.returnType.isTypeVariable
            {
            return(false)
            }
        for parameter in self.parameters
            {
            if parameter.type.isTypeVariable
                {
                return(false)
                }
            }
        return(true)
        }
        
    public var isMethodInstanceScope: Bool
        {
        return(true)
        }
        
    public var isClosureScope: Bool
        {
        return(false)
        }
        
    public var isInitializerScope: Bool
        {
        return(false)
        }
        
    public override var enclosingScope: Scope
        {
        return(self)
        }
        
    public override var iconName: String
        {
        "IconMethodInstance"
        }
        
    public var isSystemMethodInstance: Bool
        {
        return(false)
        }
        
    public var tagSignature: TagSignature
        {
        TagSignature(tags: self.parameters.map{$0.tag})
        }
        
    public override var displayString: String
        {
        let parmString = "(" + self.parameters.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.label)\(parmString) -> \(self.returnType.displayString)")
        }
        
    public var hasVariableTypes: Bool
        {
        for parameter in self.parameters
            {
            if parameter.type.isTypeVariable
                {
                return(true)
                }
            }
        return(self.returnType.isTypeVariable)
        }
        
    public var isGenericMethod = false
    public var conditionalTypes: Types = []
    public weak var method: Method!
    
    public required init?(coder: NSCoder)
        {
        self.isGenericMethod = coder.decodeBool(forKey: "isGeneric")
        self.conditionalTypes = coder.decodeObject(forKey: "conditionalTypes") as! Types
        super.init(coder: coder)
        }
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.isGenericMethod,forKey: "isGeneric")
        coder.encode(self.conditionalTypes,forKey: "conditionalTypes")
        super.encode(with: coder)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = MethodInstance(label: self.label)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
        
    public func freshTypeVariable(inContext context: TypeContext) -> MethodInstance
        {
        let newParameters = self.parameters.map{$0.freshTypeVariable(inContext: context)}
        let newReturnType = self.returnType.freshTypeVariable(inContext: context)
        let newInstance = Self(label: self.label)
        newInstance.parameters = newParameters
        newInstance.returnType = newReturnType
        return(newInstance)
        }
        
    public func printInstance()
        {
        let types = self.parameters.map{$0.type.displayString}.joined(separator: ",")
        print("\(self.label)(\(types)) -> \(self.returnType.displayString)")
        }
        
    public func moreSpecific(than instance:MethodInstance,forTypes types: Types) -> Bool
        {
        var orderings = Array<SpecificOrdering>()
        for index in 0..<types.count
            {
            let argumentType = types[index]
            let typeA = self.parameters[index].type
            let typeB = instance.parameters[index].type
            if typeA.isSubtype(of: typeB)
                {
                orderings.append(.more)
                }
            else if typeA.isClass && typeB.isClass && argumentType.isClass
                {
                let argumentClassList = argumentType.classValue.precedenceList
                if let typeAIndex = argumentClassList.firstIndex(of: typeA.classValue),let typeBIndex = argumentClassList.firstIndex(of: typeB.classValue)
                    {
                    orderings.append(typeAIndex > typeBIndex ? .more : .less)
                    }
                else
                    {
                    orderings.append(.unordered)
                    }
                }
            else
                {
                orderings.append(.unordered)
                }
            }
        for ordering in orderings
            {
            if ordering == .more
                {
                return(true)
                }
            }
        return(false)
        }

    public func parametersAreCongruent(withArguments arguments: TaggedTypes) -> Bool
        {
        guard self.parameters.count == arguments.count else
            {
            return(false)
            }
        for (parameter,argument) in zip(self.parameters,arguments)
            {
            if argument.tag.isNil && parameter.isVisible
                {
                return(false)
                }
            if argument.tag.isNotNil && argument.tag! != parameter.label
                {
                return(false)
                }
            if argument.type.isClass && parameter.type.isClass && !argument.type.isSubtype(of: parameter.type)
                {
                return(false)
                }
            if argument.type.isEnumeration && parameter.type.isEnumeration && argument.type != parameter.type
                {
                return(false)
                }
            }
        return(true)
        }
        
    public func parameterTypesAreSupertypes(ofTypes types: Types) -> Bool
        {
        for (inType,myType) in zip(types,self.parameters.map{$0.type})
            {
            if !inType.isSubtype(of: myType)
                {
                return(false)
                }
            }
        return(true)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.type = context.freshTypeVariable()
        }
        
    public func instanciate() -> MethodInstance
        {
        fatalError()
        }
        
    public func flatten() -> MethodInstance
        {
        let instance = MethodInstance(label: self.label)
        instance.parameters = self.parameters.map{$0.flatten()}
        instance.returnType = self.returnType.type
        return(instance)
        }
    }

public typealias MethodInstances = Array<MethodInstance>

public protocol NSCodable
    {
    init(coder: NSCoder,forKey: String)
    func encode(with coder: NSCoder,forKey: String)
    }
    
extension NSCoder
    {
    func encode<T:NSCodable>(_ array:Array<T>,forKey: String)
        {
        self.encode(array.count,forKey: forKey + "count")
        var index = 0
        for element in array
            {
            element.encode(with: self,forKey: forKey + "\(index)")
            index += 1
            }
        }
        
    func decode<T>(_ type:Array<T>.Type,forKey: String) -> Array<T> where T:NSCodable
        {
        let theCount = self.decodeInteger(forKey: forKey + "count")
        var elements = Array<T>()
        for index in 0..<theCount
            {
            let element = T(coder: self,forKey: forKey + "\(index)")
            elements.append(element)
            }
        return(elements)
        }
    }
