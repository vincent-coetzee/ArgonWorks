//
//  SystemClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class SystemClass:Class
    {
    public override var typeCode:TypeCode
        {
        return(self._typeCode)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    private let _typeCode:TypeCode
    
    init(label:Label,typeCode:TypeCode = .class)
        {
        self._typeCode = typeCode
        super.init(label: label)
        }
}
