//
//  InstanceSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/12/21.
//

import Foundation

public class InstanceSlot: MemberSlot
    {
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
    
    public init(label: Label,type: Type)
        {
        super.init(labeled: label,ofType: type)
        }
        
    required init(labeled: Label, ofType: Type)
        {
        super.init(label: labeled)
        self.type = ofType
        }
    
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        }
    }

public typealias InstanceSlots = Array<InstanceSlot>
