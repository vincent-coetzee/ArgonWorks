//
//  InnerDictionaryPointer.swift
//  InnerDictionaryPointer
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InnerDictionaryPointer: InnerPointer
    {
    public var count:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"count")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"count")
            }
        }
        
    public var size:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"size")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"size")
            }
        }
        
    public var prime:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"prime")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"prime")
            }
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kDictionarySizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count","size","hashFunction","prime"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
