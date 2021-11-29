//
//  Argument.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct Argument:Displayable
    {
    public var displayString: String
        {
        let aTag = self.tag ?? "="
        return("\(aTag)::\(self.value.displayString)")
        }
    public var tag:String?
    public let value:Expression
    
    init(tag: Label?,value: Expression)
        {
        self.tag = tag
        self.value = value
        }
        
    public func allocateAddresses(using: AddressAllocator)
        {
        self.value.allocateAddresses(using: using)
        }
        
    public func analyzeSemantics(using: SemanticAnalyzer)
        {
        self.value.analyzeSemantics(using: using)
        }
        
    @discardableResult
    public func inferType(context: TypeContext) throws -> Type
        {
        try self.value.inferType(context: context)
        }
        
    public func deepCopy() -> Self
        {
        Argument(tag: self.tag,value: value.deepCopy())
        }
        
    public func visit(visitor: Visitor) throws
        {
        try self.value.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public func substitute(from: TypeContext) -> Argument
        {
        let expression = self.value.deepCopy()
        expression.substitute(from: from)
        return(Argument(tag: self.tag,value: expression))
        }
        
    public func taggedType(context:TypeContext) throws -> TaggedType
        {
        let valueType = try self.value.inferType(context: context)
        return(TaggedType(tag: self.tag,type: valueType))
        }
        
    public func initializeType(inContext context: TypeContext) throws -> Argument
        {
        let newValue = self.value.deepCopy()
        try newValue.initializeType(inContext: context)
        return(Argument(tag: self.tag,value: newValue))
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.value.initializeTypeConstraints(inContext: context)
        }
    }

public struct TaggedType
    {
    internal let tag: String?
    internal let type: Type
    
    init(tag: String?,type: Type)
        {
        self.tag = tag
        self.type = type
        }
    }
    
public typealias TaggedTypes = Array<TaggedType>

public typealias Arguments = Array<Argument>

extension Arguments
    {
    public var resultTypes: Array<Type>
        {
        return(self.map{$0.value.type})
        }
        
    public func allocateAddresses(using: AddressAllocator)
        {
        for argument in self
            {
            argument.allocateAddresses(using: using)
            }
        }
        
    public func analyzeSemantics(using: SemanticAnalyzer)
        {
        for argument in self
            {
            argument.analyzeSemantics(using: using)
            }
        }
    }
//
//public typealias TypeResults = Array<TypeResult>
//
//extension TypeResults
//    {
//    public var isMisMatched: Bool
//        {
//        for result in self
//            {
//            switch(result)
//                {
//                case .undefined:
//                    return(true)
//                case .mismatch:
//                    return(true)
//                default:
//                    break
//                }
//            }
//        return(false)
//        }
//    }
