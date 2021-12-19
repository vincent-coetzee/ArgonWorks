//
//  ParameterizedSystemClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class GenericSystemClass:GenericClass
    {
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    internal override func createType() -> Type
        {
        TypeClass(systemClass: self,generics: self.types)
        }
    }
