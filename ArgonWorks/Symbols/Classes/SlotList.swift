//
//  SlotList.swift
//  SlotList
//
//  Created by Vincent Coetzee on 21/8/21.
//

import Foundation

public class SlotList:Collection
    {
    public var parent: Symbol!
    public var slots: Array<Slot> = []
    
    public var startIndex:Int
        {
        return(self.slots.startIndex)
        }
        
    public var endIndex:Int
        {
        return(self.slots.startIndex)
        }
        
    public var count: Int
        {
        return(slots.count)
        }
        
    public init(_ slotList: SlotList)
        {
        self.parent = slotList.parent
        self.slots = []
        for slot in slotList.slots
            {
            self.slots.append(slot.deepCopy())
            }
        }
        
    public init()
        {
        self.parent = .none
        self.slots = []
        }
        
    public func index(after: Int) -> Int
        {
        return(after + 1)
        }
        
    public func append(_ slot: Slot)
        {
        self.slots.append(slot)
        slot.setParent(self.parent)
        }
        
    public subscript(at: Int) -> Slot
        {
        return(self.slots[at])
        }
    }
