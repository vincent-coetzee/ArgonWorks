//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class TypeAlias:Symbol
    {
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
        self._type = coder.decodeObject(forKey: "_type") as! Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self._type,forKey: "_type")
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
