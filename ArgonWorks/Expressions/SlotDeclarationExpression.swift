//
//  SlotDefclaringExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Foundation

public class SlotDeclarationExpression: Expression
    {
    public override var isSlotDeclarationExpression: Bool
        {
        return(true)
        }
        
    private let label: Label
    private let type: Type
    
    init(label: Label,type:Type)
        {
        self.label = label
        self.type = type
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.label = coder.decodeString(forKey: "label")!
        self.type = coder.decodeType(forKey: "type")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.label,forKey: "label")
        coder.encodeType(self.type,forKey: "type")
        super.encode(with: coder)
        }
        
    public override func activate(context: Context,withInitialValue value: Expression)
        {
        let localSlot = LocalSlot(label: self.label, type: self.type, value: value)
        context.addSymbol(localSlot)
        }
    }
