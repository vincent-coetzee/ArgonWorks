//
//  SystemEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class SystemEnumeration: Enumeration
    {
    public override var isSystemEnumeration: Bool
        {
        false
        }
        
    public override var isSystemSymbol: Bool
        {
        true
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
    }
