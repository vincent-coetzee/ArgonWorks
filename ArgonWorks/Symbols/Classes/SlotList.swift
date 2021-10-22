//
//  SlotList.swift
//  SlotList
//
//  Created by Vincent Coetzee on 21/8/21.
//

import Foundation

public class SlotList:NSObject,NSCoding,Collection,StorableObject
    {
    public let index = UUID()
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
            self.slots.append(slot.clone())
            }
        }
        
    public override init()
        {
        }
        
//    public override init()
//        {
//        self.parent = .none
//        self.slots = []
//        super.init()
//        }
//
    required public init?(coder: NSCoder)
        {
//        print("START DECODE SLOT LIST")
        self.parent = coder.decodeObject(forKey: "parent") as? Symbol
        self.slots = coder.decodeObject(forKey: "slots") as! Array<Slot>
        super.init()
//        print("END DECODE SLOT LIST")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.parent,forKey:"parent")
        coder.encode(self.slots,forKey:"slots")     
        }

    public init(input: InputFile)
        {
        fatalError()
        }
    
    public func write(output: OutputFile) throws
        {
//        try output.write(self.parent)
//        try output.write(slots)
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
