//
//  LocalSlot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class LocalSlot:Slot
    {
//    public var wasAddedToBlockContext = false

    public var frame: StackFrame?
    
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
        
    public override func emitRValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        self.place = .frameOffset(self.offset)
        }
        
    public override func emitLValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        self.place = .frameOffset(self.offset)
        }
    }

public typealias LocalSlots = Array<LocalSlot>
