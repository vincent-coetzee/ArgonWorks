//
//  EmptySegment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation


public class EmptySegment: Segment
    {
   public override var isEmptySegment: Bool
        {
        true
        }
        
    public init()
        {
        do
            {
            try super.init(memorySize: .bytes(8),argonModule: ArgonModule(instanceNumber: -1))
            }
        catch
            {
            fatalError()
            }
        }
    }
    

