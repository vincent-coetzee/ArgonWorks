//
//  TypeVariable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeVariable: Type
    {
    public static func ==(lhs: TypeVariable,rhs: Type) -> Bool
        {
        if !(rhs is TypeVariable)
            {
            return(false)
            }
        let right = rhs as! TypeVariable
        return(lhs.id == right.id)
        }
    
    internal static var typeVariableCount = 0
    
    public static func newTypeVariable() -> TypeVariable
        {
        let variable = TypeVariable(index: self.typeVariableCount)
        self.typeVariableCount += 1
        return(variable)
        }
        
    public override var isTypeVariable: Bool
        {
        true
        }
        
    public override var hasVariableTypes: Bool
        {
        true
        }
        
    public override var typeVariables: TypeVariables
        {
        [self]
        }
        
    public override var type: Type!
        {
        get
            {
            self.boundType.isNil ? Type() : self.boundType!.type
            }
        set
            {
            }
        }
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.id
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }

    public override var displayString: String
        {
        "TypeVariable(\(self.label)=\(self.id))"
        }
        
    internal var id: Int
    internal var boundType: Type?
    
    init(index: Int)
        {
        self.id = index
        super.init(label: "\(index)")
        }
        
    required init(label: Label)
        {
        self.id = 0
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self.id = coder.decodeInteger(forKey:"id")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.id,forKey:"id")
        super.encode(with: coder)
        }
        
    public func occurs(in type: Type) -> Bool
        {
        if self.boundType.isNil
            {
            return(false)
            }
        return(type.contains(self))
        }
        
    public override func freshTypeVariable(inContext context:TypeContext) -> Self
        {
//        let variable = context.freshTypeVariable(forTypeVariable: self)
        let variable = context.freshTypeVariable()
        self.boundType = variable
        return(variable as! Self)
        }
        
//    public override func setParent(_ parent: Parent)
//        {
//        self.parent = parent
//        }
//        
//    public override func setParent(_ symbol: Symbol)
//        {
//        self.parent = .node(symbol)
//        }
//        
//    public override func setParent(_ expression: Expression)
//        {
//        self.parent = .expression(expression)
//        }
//        
//    public override func setParent(_ block: Block)
//        {
//        self.parent = .block(block)
//        }
    }
    
public typealias TypeVariables = Array<TypeVariable>
