//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class TypeAlias:Symbol
    {
    public override var argonHash: Int
        {
        var hashValue = super.argonHash
        hashValue = hashValue << 13 ^ self.type.argonHash
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        fatalError()
        }
        
    public override var isType: Bool
        {
        return(true)
        }
//        
//    public override var canBecomeAClass: Bool
//        {
//        return(self._type.canBecomeAClass)
//        }
        
    public override var canBecomeAType: Bool
        {
        return(true)
        }
        
    public override var isTypeAlias: Bool
        {
        return(true)
        }
        
    public var mangledName: String
        {
        return(self.type.mangledName)
        }
        
    public override var iconName: String
        {
        "IconType"
        }
        
    public override func emitCode(using: CodeGenerator)
        {
        }
        
    init(label:Label,type:Type)
        {
        super.init(label: label)
        self.type = type
        }
    
    public required init?(coder: NSCoder)
        {
//        print("START DECODE TYPE ALIAS")
        super.init(coder: coder)
//        print("END DECODE TYPE ALIAS \(self.label)")
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        }
        
    public override var typeCode:TypeCode
        {
        .typeAlias
        }
        
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(ofType == .type)
        }
        
    public func isSubtype(of alias: TypeAlias) -> Bool
        {
        return(self.type.isSubtype(of: alias.type))
        }
        
    public func isInclusiveSubclass(of aClass: TypeClass) -> Bool
        {
        return(self.type.isSubtype(of: aClass))
        }
    }
