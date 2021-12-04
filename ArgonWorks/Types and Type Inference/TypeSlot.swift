//
//  TypeSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class TypeSlot: Type
    {
    public override var displayString: String
        {
        "TypeSlot(\(self.baseType.displayString)->\(self.slotLabel))"
        }
        
    internal let slotLabel: Label
    internal let baseType: Type
    
    init(baseType: Type,slotLabel: Label)
        {
        self.slotLabel = slotLabel
        self.baseType = baseType
        super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        required init(label: Label) {
            fatalError("init(label:) has not been implemented")
        }
    }
