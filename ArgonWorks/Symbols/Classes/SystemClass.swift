//
//  SystemClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class SystemClass:Class
    {
//    public override class func classForKeyedUnarchiver() -> AnyClass
//        {
//        return(self.self)
//        }
        
    public override var isEnumerationInstanceClass: Bool
        {
        self.label == "EnumerationInstance"
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        return(self._typeCode)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    private let _typeCode:TypeCode
    
    required init(label: Label)
        {
        self._typeCode = .class
        super.init(label: label)
        }
    
    internal override func createType() -> Type
        {
        TypeClass(systemClass: self,generics: [])
        }
        
    public required init?(coder: NSCoder)
        {
        self._typeCode = .class
        super.init(coder: coder)
        }
    ///
    ///
    /// Don't mess with the names of this method or the next one because they are here solely
    /// for the use of the ArgonModule.
    ///
    ///
    init(label:Label,superclasses: Types)
        {
        self._typeCode = .class
        super.init(label:label)
        for aClass in superclasses
            {
            self.addSuperclass(aClass)
            }
        }
    }
