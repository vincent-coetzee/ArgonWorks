//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class TypeAlias:Symbol
    {
    public override var isType: Bool
        {
        return(true)
        }
        
    public override var classValue: Class
        {
        self._type.classValue
        }
        
    public override var canBecomeAClass: Bool
        {
        return(self._type.canBecomeAClass)
        }
        
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
        return(self._type.mangledName)
        }
        
    public override var iconName: String
        {
        "IconType"
        }
        
    public override var asType: Type
        {
        return(self._type)
        }
        
    public override func emitCode(using: CodeGenerator)
        {
        }
        
    private let _type:Type
    
    init(label:Label,type:Type)
        {
        self._type = type
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        self._type = coder.decodeType(forKey: "_type")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encodeType(self._type,forKey: "_type")
        }
        
    public override var typeCode:TypeCode
        {
        .typeAlias
        }
        
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(ofType == .type)
        }
    }
