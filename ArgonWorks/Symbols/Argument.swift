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
        
    public func allocateAddresses(using: AddressAllocator) throws
        {
        try self.value.allocateAddresses(using: using)
        }
        
    public func analyzeSemantics(using: SemanticAnalyzer)
        {
        self.value.analyzeSemantics(using: using)
        }
        
    public func visit(visitor: Visitor) throws
        {
        try self.value.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    @discardableResult
    public func initializeType(inContext context: TypeContext) -> Argument
        {
        self.value.initializeType(inContext: context)
        return(self)
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.value.initializeTypeConstraints(inContext: context)
        }
    }

public struct TaggedType
    {
    internal let tag: String?
    internal let type: Type?
    
    init(tag: String?,type: Type?)
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
        return(self.map{$0.value.type!})
        }
        
    public func allocateAddresses(using: AddressAllocator) throws
        {
        for argument in self
            {
            try argument.allocateAddresses(using: using)
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
