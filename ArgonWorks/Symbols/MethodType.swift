//
//  FunctionReference.swift
//  FunctionReference
//
//  Created by Vincent Coetzee on 12/8/21.
//

import Foundation

public class MethodType: Class
    {
    private let types:Classes
    private let returnType: Class
    
    public static func ==(lhs:MethodType,rhs:MethodType) -> Bool
        {
        return(lhs.types == rhs.types && lhs.returnType == rhs.returnType)
        }
        
    public static func <(lhs:MethodType,rhs:MethodType) -> Bool
        {
        return(lhs.types < rhs.types && lhs.returnType < rhs.returnType)
        }
        
    public static func <=(lhs:MethodType,rhs:MethodType) -> Bool
        {
        return(lhs.types <= rhs.types && lhs.returnType <= rhs.returnType)
        }
        
    public init(label: Label,types: Classes,returnType: Class)
        {
        self.types = types
        self.returnType = returnType
        super.init(label: label)
        }
        

    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
