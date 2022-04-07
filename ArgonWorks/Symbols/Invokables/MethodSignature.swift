//
//  MethodSignature.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/2/22.
//

import Foundation

public struct MethodSignature: Equatable
    {
    public static func ==(lhs: MethodSignature,rhs: MethodSignature) -> Bool
        {
        if lhs.label != rhs.label
            {
            return(false)
            }
        if lhs.tags.count != rhs.tags.count
            {
            return(false)
            }
        if lhs.tags != rhs.tags
            {
            return(false)
            }
        if lhs.returnType != rhs.returnType
            {
            return(false)
            }
        return(true)
        }
        
    public typealias ParameterTuple = (Label?,Type)
    
    public enum ParameterTag: Equatable
        {
        case tag(String,Type)
        case hidden(Type)
        
        public func isEquivalent(_ rhs: ParameterTag) -> Bool
            {
            switch(self,rhs)
                {
                case(.tag(let label1,let type1),.tag(let label2,let type2)):
                    return(label1 == label2 && type1.isEquivalent(type2))
                case(.hidden(let type1),.hidden(let type2)):
                    return(type1.isEquivalent(type2))
                default:
                    return(false)
                }
            }
        }
        
    public typealias ParameterTags = Array<ParameterTag>
        
    public let label: String
    private var tags: ParameterTags
    private var returnType: Type
    
    init(methodInstance: MethodInstance,argonModule: ArgonModule)
        {
        self.label = methodInstance.label
        self.tags = methodInstance.parameters.map{$0.isHidden ? .hidden($0.type) : .tag($0.tag!,$0.type)}
        self.returnType = methodInstance.returnType
        }
        
    init(label: Label,parameters: Array<ParameterTuple>,returnType: Type? = nil,argonModule: ArgonModule)
        {
        self.label = label
        self.tags = parameters.map{$0.0.isNil ? .hidden($0.1) : .tag($0.0!,$0.1)}
        self.returnType = returnType.isNil ? argonModule.void : returnType!
        }
        
    init(label: Label,parameters: ParameterTuple...,returnType: Type? = nil,argonModule: ArgonModule)
        {
        self.label = label
        self.tags = parameters.map{$0.0.isNil ? .hidden($0.1) : .tag($0.0!,$0.1)}
        self.returnType = returnType.isNil ? argonModule.void : returnType!
        }
        
    public func isEquivalent(_ rhs: MethodSignature) -> Bool
        {
        if self.label != rhs.label
            {
            return(false)
            }
        if self.tags.count != rhs.tags.count
            {
            return(false)
            }
        for (left,right) in zip(self.tags,rhs.tags)
            {
            if !left.isEquivalent(right)
                {
                return(false)
                }
            }
        return(self.returnType.isEquivalent(rhs.returnType))
        }
    }
