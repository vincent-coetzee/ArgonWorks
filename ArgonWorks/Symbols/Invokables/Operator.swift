//
//  Operator.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class Operator: Method
    {
    private let operation: Token.Operator
    
    init(_ operation: Token.Operator)
        {
        self.operation = operation
        super.init(label: operation.name)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR")
        self.operation = Token.Operator(coder.decodeString(forKey: "operation")!)
        super.init(coder: coder)
//        print("END DECODE OPERATOR \(self.label)")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.operation.name,forKey:"operation")
        super.encode(with: coder)
        }
    }
    
public class InfixOperator: Operator
    {
    }

public class SystemInfixOperator: InfixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }
    
public class Infix
    {
    var method: SystemInfixOperator
        {
        let classParameter = GenericClassParameter(self.left)
        let method = SystemInfixOperator(self.operation)
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: [Parameter(label: "a", type: .genericClassParameter(classParameter)),Parameter(label: "b", type: .genericClassParameter(classParameter))], returnType: .genericClassParameter(classParameter))
        method.addInstance(instance)
        return(method)
        }
        
    let left: String
    let operation: Token.Operator
    let right: String
    let out: String
    
    init(left: String,_ op: String,right: String,out: String)
        {
        self.left = left
        self.operation = Token.Operator(op)
        self.right = right
        self.out = out
        }
    }
    
public class PostfixOperator: Operator
    {
    }
    
public class SystemPostfixOperator: PostfixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }
    
public class PrefixOperator: Operator
    {

    }
    
public class Prefix
    {
    var method: SystemPrefixOperator
        {
        let method = SystemPrefixOperator(self.operation)
        let instance = PrimitiveMethodInstance(label: self.operation.name, parameters: [Parameter(label: "a", type: self.left)], returnType: self.out)
        method.addInstance(instance)
        return(method)
        }
        
    let left: Type
    let operation: Token.Operator
    let right: Type?
    let out: Type
    
    init(_ op: String,_ left: Class,_ right: Class? = nil,out: Class)
        {
        self.left = .class(left)
        self.operation = Token.Operator(op)
        self.right = right.isNil ? nil : right!.type
        self.out = out.type
        }
    }

public class SystemPrefixOperator: PrefixOperator
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
    }
