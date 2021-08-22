//
//  ObjectPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

//@dynamicMemberLookup
//public class ObjectPointer
//    {
//    private static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
//    
//    private let address:Word
//    private var wordPointer:UnsafeMutablePointer<Word>
//    private let theClass:Class
//    private let extraOffset:Int
//
//    init(address:Word,class:Class)
//        {
//        self.address = address
//        self.wordPointer = UnsafeMutablePointer<Word>(bitPattern: UInt(address))!
//        self.theClass = `class`
//        self.extraOffset = theClass.sizeInBytes / MemoryLayout<Word>.size
//        }
//        
//    init(address:Word)
//        {
//        self.address = address
//        self.wordPointer = UnsafeMutablePointer<Word>(bitPattern: UInt(address))!
//        fatalError()
//        self.extraOffset = 0
//        }
//        
//    public subscript(dynamicMember name:String) -> Word
//        {
//        get
//            {
//            if let slot = theClass.layoutSlot(atLabel:name)
//                {
//                return(self.wordPointer[slot.offset / 8])
//                }
//            fatalError("An object of class \(theClass.label) does not have a slot labeled \(name)")
//            }
//        set
//            {
//            if let slot = theClass.layoutSlot(atLabel:name)
//                {
//                self.wordPointer[slot.offset / 8] = newValue
//                return
//                }
//            fatalError("An object of class \(theClass.label) does not have a slot labeled \(name)")
//            }
//        }
//        
//    public func word(atSlot:String) -> Word
//        {
//        if let slot = self.theClass.layoutSlot(atLabel: atSlot)
//            {
//            return(self.word(atOffset: slot.offset))
//            }
//        return(0)
//        }
//        
//    public func setWord(_ word:Word,atSlot:String)
//        {
//        if let slot = self.theClass.layoutSlot(atLabel: atSlot)
//            {
//            self.setWord(word,atOffset: slot.offset)
//            }
//        }
//        
//    public func setBoolean(_ value:Bool,atSlot label:Label)
//        {
//        if let slot = theClass.layoutSlot(atLabel: label)
//            {
//            self.wordPointer[slot.offset / 8] = Word(boolean:value)
//            }
//        }
//        
//    public func word(atOffset:Int) -> Word
//        {
//        return(self.wordPointer[atOffset/8])
//        }
//        
//    public subscript(offset: Int) -> Word
//        {
//        get
//            {
//            return(self.wordPointer[offset/8])
//            }
//        set
//            {
//            self.wordPointer[offset/8] = newValue
//            }
//        }
//        
//    public func setWord(_ word:Word,atOffset:Int)
//        {
//        self.wordPointer[atOffset/8] = word
//        }
//        
//    public func pointer(for label:Label) -> ObjectPointer
//        {
//        if let slot = theClass.layoutSlot(atLabel: label)
//            {
//            let value = self.wordPointer[slot.offset / 8]
//            return(ObjectPointer(address: value))
//            }
//        fatalError("No such slot \(label)")
//        }
//        
//    public func pointer(for label:Label,ofClass:Class) -> ObjectPointer
//        {
//        if let slot = theClass.layoutSlot(atLabel: label)
//            {
//            let value = self.wordPointer[slot.offset / 8]
//            return(ObjectPointer(address: value,class:ofClass))
//            }
//        fatalError("No such slot \(label)")
//        }
//    }
