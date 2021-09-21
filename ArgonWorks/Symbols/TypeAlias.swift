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
        fatalError("init(coder:) has not been implemented")
        }
    
    public override var typeCode:TypeCode
        {
        .typeAlias
        }
    }
