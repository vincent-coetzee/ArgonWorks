//
//  LValues.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Foundation

public class LValue:NSObject,NSCoding
    {
    public var localSlot: LocalSlot?
        {
        return(nil)
        }
        
    func lookup(label: Label) -> Symbol?
        {
        return(nil)
        }
        
    func slot(_ slot:Slot) -> LValue
        {
        SlotLValue(lvalue: self,slot: slot)
        }
        
    func index(_ index: Expression) -> LValue
        {
        IndexLValue(lvalue: self,index: index)
        }
        
    public override init()
        {
        super.init()
        }
        
    required public init?(coder: NSCoder)
        {
        }
        
    public func encode(with coder:NSCoder)
        {
        }
    }
    
internal class IndexLValue: LValue
    {
    public override var localSlot: LocalSlot?
        {
        return(self.lvalue.localSlot)
        }
        
    let lvalue: LValue
    let index: Expression
    
    init(lvalue: LValue,index: Expression)
        {
        self.lvalue = lvalue
        self.index = index
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.lvalue = coder.decodeObject(forKey: "lvalue") as! LValue
        self.index = coder.decodeObject(forKey: "index") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lvalue,forKey: "lvalue")
        coder.encode(self.index,forKey: "index")
        super.encode(with: coder)
        }
        
    override func lookup(label: Label) -> Symbol?
        {
        if let aSlot = self.lvalue.localSlot
            {
            if !aSlot.type.isArrayClassInstance
                {
                return(nil)
                }
            let type = (aSlot.type.classValue as! ArrayClassInstance).elementType
            return(type.lookup(label: label))
            }
        return(nil)
        }
    }
    
internal class LocalLValue: LValue
    {
    public override var localSlot: LocalSlot?
        {
        return(self._localSlot)
        }
        
    let _localSlot: LocalSlot
    
    init(localSlot: LocalSlot)
        {
        self._localSlot = localSlot
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self._localSlot = coder.decodeObject(forKey: "_localSlot") as! LocalSlot
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self._localSlot,forKey: "_localSlot")
        super.encode(with: coder)
        }
        
    override func lookup(label: Label) -> Symbol?
        {
        switch(_localSlot.type)
            {
            case .class(let someClass):
                return(someClass.lookup(label: label))
            case .enumeration(let someEnumeration):
                return(someEnumeration.lookup(label: label))
            default:
                return(nil)
            }
        }
    }
    
public class SlotLValue: LValue
    {
    public override var localSlot: LocalSlot?
        {
        return(self.lvalue.localSlot)
        }
        
    let lvalue: LValue
    let slot: Slot
    
    public init(lvalue: LValue,slot: Slot)
        {
        self.lvalue = lvalue
        self.slot = slot
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.lvalue = coder.decodeObject(forKey: "lvalue") as! LValue
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lvalue,forKey: "lvalue")
        coder.encode(self.slot,forKey: "slot")
        }
        
    override func lookup(label: Label) -> Symbol?
        {
        switch(self.slot.type)
            {
            case .class(let someClass):
                return(someClass.lookup(label: label))
            case .enumeration(let someEnumeration):
                return(someEnumeration.lookup(label: label))
            default:
                return(nil)
            }
        }
    }
    
