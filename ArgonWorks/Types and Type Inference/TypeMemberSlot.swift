//
//  TypeInstanceSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/12/21.
//

import Foundation

public class TypeMemberSlot: Type
    {
    internal let slotLabel: Label
    internal let base: Type
    
    init(slotLabel: Label,base: Type)
        {
        self.base = base
        self.slotLabel = slotLabel
        super.init(label: slotLabel)
        }
        
    required init?(coder: NSCoder)
        {
        self.slotLabel = coder.decodeObject(forKey: "slotLabel") as! String
        self.base = coder.decodeObject(forKey: "base") as! Type
        super.init(coder: coder)
        }
    
    required init(label: Label)
        {
        self.slotLabel = label
        self.base = Type()
        super.init(label: label)
        }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.slotLabel,forKey: "slotLabel")
        coder.encode(self.base,forKey: "base")
        super.encode(with: coder)
        }
    }
