//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class TypeAlias:Type
    {
    public override var symbolType: SymbolType
        {
        .typeAlias
        }
        
    public override var argonHash: Int
        {
        var hashValue = self.type.argonHash
        hashValue = hashValue << 13 ^ self.type.argonHash
        return(hashValue)
        }
        
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public override var isTypeAlias: Bool
        {
        true
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        fatalError()
        }

    public override var isClassType: Bool
        {
        self.type.isClassType
        }
        
    public override var isEnumerationType: Bool
        {
        self.type.isEnumerationType
        }
        
    public override var identityHash: Int
        {
        var hash = super.identityHash
        hash = hash << 13 ^ self.type.identityHash
        return(hash)
        }
        
    public override var mangledName: String
        {
        return(self.type.mangledName)
        }
        
    public override var iconName: String
        {
        "IconType"
        }
        
    public override var iconTint: NSColor
        {
        SyntaxColorPalette.typeColor
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
        super.init(coder: coder)
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

    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let alias = TypeAlias(label: self.label)
        alias.type = substitution.substitute(self.type)
        return(alias as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let typeAlias = TypeAlias(label: self.label)
        typeAlias.type = self.type.freshTypeVariable(inContext: context)
        return(typeAlias as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type.initializeType(inContext: context)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.type.initializeTypeConstraints(inContext: context)
        }
        
    public func isSubtype(of alias: TypeAlias) -> Bool
        {
        self.type.isSubtype(of: alias.type)
        }
        
    public func isInclusiveSubclass(of aClass: TypeClass) -> Bool
        {
        self.type.isSubtype(of: aClass)
        }
        
    public override func withGenerics(_ types: Types) -> Type
        {
        self.type.withGenerics(types)
        }
    }
