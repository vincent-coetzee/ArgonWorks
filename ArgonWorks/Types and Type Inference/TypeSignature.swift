//
//  TypeSignature.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

//public struct TypeSignature: Equatable
//    {
//    public static func ==(lhs: TypeSignature,rhs: TypeSignature) -> Bool
//        {
//        lhs.label == rhs.label && lhs.types == rhs.types && lhs.returnType == rhs.returnType
//        }
//        
//    internal static func typeSignature(for instance: MethodInstance,inContext context: TypeContext) -> TypeSignature
//        {
//        let types = instance.parameters.map{$0.type!}
//        return(TypeSignature(label: instance.label, types: types, returnType: instance.returnType))
//        }
//        
//    internal let label: Label
//    internal let types: Types
//    internal let returnType: Type
//    
//    internal func instanciate(inContext: TypeContext) -> TypeSignature
//        {
//        TypeSignature(label: self.label,types: self.types.map{$0.freshTypeVariable(inContext: inContext)},returnType: self.returnType.freshTypeVariable(inContext: inContext))
//        }
//    }
