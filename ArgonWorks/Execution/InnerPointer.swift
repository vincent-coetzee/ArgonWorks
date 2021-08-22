//
//  InnerPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerPointer:Addressable
    {
    public static let kClassSizeInBytes = 152
    public static let kSlotSizeInBytes = 88
    public static let kArraySizeInBytes = 144
    public static let kVectorSizeInBytes = 152
    public static let kStringSizeInBytes = 64
    public static let kBlockSizeInBytes = 80
    public static let kMethodInstanceSizeInBytes = 144
    public static let kInstanceSizeInBytes = 24
    public static let kDictionarySizeInBytes = 136
    public static let kClosureSizeInBytes = 192
    public static let kEnumerationSizeInBytes = 112
    public static let kDictionaryBucketSizeInBytes = 80
    public static let kEnumerationCaseSizeInBytes = 104
    public static let kFunctionSizeInBytes = 168
    
    public static func ==(lhs:InnerPointer,rhs:InnerPointer) -> Bool
        {
        return(lhs.address == rhs.address)
        }
        
    public var headerSizeInWords: Int
        {
        return(self.header.sizeInWords)
        }
        
    public var headerHasBytes: Bool
        {
        return(self.header.hasBytes)
        }
        
    public var headerTag: Argon.Tag
        {
        return(self.header.tag)
        }
        
    public var headerFlipCount: Int
        {
        return(self.header.flipCount)
        }
        
    public var slotValues: Array<InnerSlotValue>
        {
        let clazz = self.classPointer
        var slotValues = Array<InnerSlotValue>()
        for slotWord in clazz.slots
            {
            let slotPointer = InnerSlotPointer(address: slotWord)
            let index = slotPointer.offset
            slotValues.append(InnerSlotValue(index: index, wordPointer: self.wordPointer, slotPointer: slotPointer))
            }
        return(slotValues)
        }
        
    public var headerTypeCode: TypeCode
        {
        get
            {
            return(self.header.typeCode)
            }
        set
            {
            self.header.typeCode = newValue
            }
        }
        
    public var headerIsForwarded: Bool
        {
        return(self.header.isForwarded)
        }
        
    public var classPointer:InnerClassPointer
        {
        get
            {
            if self._classPointer.isNil
                {
                self._classPointer = InnerClassPointer(address: self.slotValue(atKey:"_classPointer"))
                }
            return(self._classPointer!)
            }
        set
            {
            self._classPointer = newValue
            self.setSlotValue(newValue.address,atKey:"_classPointer")
            self.setSlotValue(newValue.magicNumber,atKey:"_magicNumber")
            }
        }
        
    internal struct Key
        {
        let name:String
        let offset:Int
        }

    public var isNil: Bool
        {
        return(self.address == 0)
        }
        
    private var header: Header
        {
        get
            {
            return(Header(self.wordPointer![0]))
            }
        set
            {
            self.wordPointer![0] = newValue
            }
        }
        
    internal var sizeInBytes:Int = 0
    internal var _keys:Dictionary<String,Key> = [:]
    var _classPointer:InnerClassPointer?
    public let address:Word
    var wordPointer:WordPointer?

    public required init(address:Word)
        {
        self._classPointer = nil
        self.address = address
        self.wordPointer = WordPointer(address:address)
        self.initKeys()
        }
        
    internal func initKeys()
        {
        self.sizeInBytes = 24
        let names = ["_header","_magicNumber","_classPointer"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func setClass(_ aClass:Class?)
        {
        self.setSlotValue(aClass?.memoryAddress ?? 0,atKey:"_classPointer")
        self.setSlotValue(aClass?.magicNumber ?? 0,atKey:"_magicNumber")
        }
        
    public func setEnumeration(_ enumeration:InnerEnumerationPointer,`case`:InnerEnumerationCasePointer,atKey: String)
        {
        let eAddress = enumeration.address
        let intValue = `case`.index
        let addressMask = (Word(1) << Word(16) - 1) << Word(48)
        if eAddress != (eAddress & addressMask)
            {
            fatalError("Address for enumeration exceeds 48 bits in length")
            }
        let intMask = (Word(1) << Word(14)) - 1
        let newValue = (Word(intValue) & intMask) << 48 | eAddress
        self.setSlotValue(newValue,atKey: atKey)
        }
        
    public func enumerationCase(atKey: String) -> (InnerEnumerationPointer,Int)
        {
        let value = self.slotValue(atKey: atKey)
        let addressMask = (Word(1) << Word(16) - 1) << Word(48)
        let address = value & ~addressMask
        let pointer = InnerEnumerationPointer(address: address)
        let index = (value & addressMask) >> 48 & (Word(1) << Word(14) - 1)
        return((pointer,Int(index)))
        }
        
    public func hasSlot(atKey:String) -> Bool
        {
        return(self._keys[atKey] != nil)
        }
        
    public func word(atOffset:Int) -> Word
        {
        return((self.wordPointer?[atOffset/8] ?? 0).tagDropped)
        }
        
    public func setWord(_ word:Word,atOffset:Int)
        {
        self.wordPointer?[atOffset/8] = word
        }
        
    public func slotValue(atKey:String) -> Word
        {
        if let offset = self._keys[atKey]?.offset
            {
            return((self.wordPointer?[offset/8].tagDropped) ?? Word.nilValue)
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func intSlotValue(atKey:String) -> Int
        {
        if let offset = self._keys[atKey]?.offset
            {
            return(Int(bitPattern: UInt((self.wordPointer?[offset/8].tagDropped) ?? Word.nilValue)))
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:Word,atKey:String)
        {
        if let offset = self._keys[atKey]?.offset
            {
            self.wordPointer![offset/8] = value
            return
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:Bool,atKey:String)
        {
        if let offset = self._keys[atKey]?.offset
            {
            var word = Word(value ? 1 : 0)
            word.tag = .boolean
            self.wordPointer![offset/8] = word
            return
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:String,in vm: VirtualMachine,atKey:String)
        {
        let stringPointer = InnerStringPointer.allocateString(value,in: vm)
        let offset = self._keys[atKey]!.offset
        var word = stringPointer.address
        word.tag = Argon.Tag.pointer
        self.wordPointer![offset/8] = word
        }
        
    public func setSlotValue(_ value:Int,atKey:String)
        {
        let offset = self._keys[atKey]!.offset
        self.wordPointer![offset/8] = Word(bitPattern: Int64(value))
        }
        
    public func assignSystemSlots(from aClass:Class)
        {
        var aKey = "_\(aClass.label)Header"
        if self.hasSlot(atKey: aKey)
            {
            var header = Header(0)
            header.tag = .header
            header.hasBytes = aClass.hasBytes
            header.isForwarded = false
            header.flipCount = 1
            header.sizeInWords = aClass.sizeInBytes / 8
            self.setSlotValue(header, atKey: aKey)
            }
        aKey = "_\(aClass.label)MagicNumber"
        if self.hasSlot(atKey: aKey)
            {
            self.setSlotValue(aClass.magicNumber,atKey: aKey)
            }
        aKey = "_\(aClass.label)ClassPointer"
        if self.hasSlot(atKey: aKey)
            {
            self.setSlotValue(aClass.memoryAddress,atKey: aKey)
            }
        for superclass in aClass.superclasses
            {
            self.assignSystemSlots(from: superclass)
            }
        }
    }
