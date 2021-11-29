//
//  LocalSlot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class LocalSlot:Slot
    {
    public var place: T3AInstruction.Operand = .none
    
    init(label:Label,type:Type?,value:Expression?)
        {
        super.init(label: label,type: type.isNil ? TypeContext.freshTypeVariable() : type!)
        self.initialValue = value
        }
    
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
     public required init(label: Label)
        {
        super.init(label: label)
        }
    
    
    public override var typeCode:TypeCode
        {
        .localSlot
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator)
        {
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
    }

public typealias LocalSlots = Array<LocalSlot>
