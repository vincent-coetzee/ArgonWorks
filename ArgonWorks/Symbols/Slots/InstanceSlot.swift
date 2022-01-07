//
//  InstanceSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/12/21.
//

import Foundation

public class InstanceSlot: Slot
    {
    public var `class`:TypeClass!
        
    public override var isSystemSymbol: Bool
        {
        return(self.class.isSystemSymbol)
        }
        
    public required init?(coder: NSCoder)
        {
        self.class = coder.decodeObject(forKey: "class") as? TypeClass
        super.init(coder: coder)
        }
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
    
    required init(labeled: Label, ofType: Type)
        {
        super.init(label: labeled)
        self.type = ofType
        }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.class,forKey: "class")
        super.encode(with: coder)
        }
    }
