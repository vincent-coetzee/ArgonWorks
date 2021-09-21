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
        
    ///
    ///
    /// Don't mess with the names of this method or the next one because they are here solely
    /// for the use of the ArgonModule.
    ///
    ///
    init(label:Label,superclasses:Array<Label>,typeCode:TypeCode = .none)
        {
        self._typeCode = typeCode
        super.init(label:label)
        self.superclassReferences = superclasses.map{ForwardReferenceClass(name:Name($0))}
        }
}
