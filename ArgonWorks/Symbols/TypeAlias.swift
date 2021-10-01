//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class TypeAlias:Symbol
    {
    public override var defaultColor: NSColor
        {
        Palette.shared.typeAliasColor
        }
        
    public var mangledName: String
        {
        return(self._type.mangledName)
        }
        
    public override var imageName: String
        {
        "IconType"
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
