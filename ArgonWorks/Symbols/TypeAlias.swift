//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class TypeAlias:Symbol
    {
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
        
    public override var classValue: Class
        {
        self.type.classValue
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
        
    public override var asType: Type
        {
        return(self.type)
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
        self.type = coder.decodeObject(forKey: "_type") as! Type
//        print("END DECODE TYPE ALIAS \(self.label)")
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        self.type = Type()
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.type,forKey: "_type")
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
        
    public func isSubtype(of enumeration: Enumeration) -> Bool
        {
        return(self.type == enumeration.type)
        }
        
    public func isInclusiveSubclass(of aClass: Class) -> Bool
        {
        return(self.type.isSubtype(of: aClass.type))
        }
    }
