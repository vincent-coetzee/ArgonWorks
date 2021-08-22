//
//  InnerDictionaryBucketPointer.swift
//  InnerDictionaryBucketPointer
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InnerDictionaryBucketPointer: InnerPointer
    {
    public class func allocate(key:Word, value: Word,next: Word,in vm: VirtualMachine) -> InnerDictionaryBucketPointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: Self.kDictionaryBucketSizeInBytes)
        let pointer = InnerDictionaryBucketPointer(address: address)
        pointer.setClass(vm.topModule.argonModule.dictionaryBucket)
        pointer.key = key
        pointer.value = value
        pointer.next = next
        pointer.assignSystemSlots(from: vm.topModule.argonModule.dictionaryBucket)
        pointer.headerTypeCode = .dictionaryBucket
        assert(pointer.key == key,"Pointer.key != key")
        assert(pointer.value == value,"Pointer.value != value")
        assert(pointer.next == next,"Pointer.next != next")
        return(pointer)
        }
        
    public var key:Word
        {
        get
            {
            return(self.slotValue(atKey:"key"))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"key")
            }
        }
        
    public var value:Word
        {
        get
            {
            return(self.slotValue(atKey:"value"))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"value")
            }
        }
        
    public var next:Word
        {
        get
            {
            return(self.slotValue(atKey:"next"))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"next")
            }
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kDictionaryBucketSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","key","next","value"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
