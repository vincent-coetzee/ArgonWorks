//
//  Header.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation
    
public class Header
    {
//    public static let kSizeBits:UInt64 = 0b11111111_11111111_11111111_11111111_11111111
//    public static let kSizeShift:UInt64 = 18
//    public static let kHasBytesBits:UInt64 = 0b1
//    public static let kHasBytesShift = 17
//    public static let kFlipBits:UInt64 = 0b11111111
//    public static let kFlipShift = 9
//    public static let kForwardedBits:UInt64 = 0b1
//    public static let kForwardedShift = 8
//    public static let kTagBits:UInt64 = 0b111
//    public static let kTagShift:UInt64 = 60
//    public static let kPersistentBits:UInt64 = 0b1
//    public static let kPersistentShift:UInt64 = 7
//    public static let kTypeBits:UInt64 = 0b1111111
//    public static let kTypeShift:UInt64 = 0
//
//    public static let kTagBitsMask = Header.kTagBits << Header.kTagShift
//
    public static func test()
        {
        let header = Header(word: 0)
        
        header.sizeInWords = 1024 * 1024
        print("HEADER: \(header.bitString)")
        assert(header.sizeInWords == 1024*1024,"Header.sizeInWords should equal 1024*1024 = \(1024*1024) but actually equals \(header.sizeInWords)")
        print((UInt64(1<<60)).bitString)
        header.hasBytes = true
        assert(header.hasBytes,"Header.hasBytes is false and should be true")
        header.hasBytes = false
        assert(!header.hasBytes,"Header.hasBytes is true and should be false")
        header.flipCount = 200
        assert(header.flipCount == 200,"Header.flipCount should be 200 but is \(header.flipCount)")
        header.flipCount = 0
        assert(header.flipCount == 0,"Header.flipCount should be 0 but is \(header.flipCount)")
        header.flipCount = 300
        assert(header.flipCount == 300 - 255 - 1,"Header.flipCount should be \(300-255-1) but is \(header.flipCount)")
        header.isForwarded = true
        assert(header.isForwarded,"Header.isForwarded is false and should be true")
        header.isForwarded = false
        assert(!header.isForwarded,"Header.isForwarded is true and should be false")
        header.tag = .boolean
        assert(header.tag == .boolean,"Header.tag should be 5 but is \(header.tag)")
        header.tag = .integer
        assert(header.tag == .integer,"Header.tag should be 0 but is \(header.tag)")
        header.tag = .header
        header.objectType = .array
        assert(header.objectType == .array,"Header.objectType should be array and is not.")
        let value = 2 << 40
        header.sizeInWords = value
        assert(header.sizeInWords == Int(Argon.kHeaderSizeInWordsBits),"Header.sizeInWords should be \(Argon.kHeaderSizeInWordsBits) but is \(header.sizeInWords)")
        print(header.bitString)
        }
        
    public var displayString: String
        {
        "SIZE: \(self.sizeInWords) TYPE: \(self.objectType) HASBYTES: \(self.hasBytes)"
        }
        
    public var sizeInWords:Int
        {
        get
            {
            let mask = Argon.kHeaderSizeInWordsBits << Argon.kHeaderSizeInWordsShift
            return(Int((self.bytes & mask) >> Argon.kHeaderSizeInWordsShift))
            }
        set
            {
            let theValue = UInt64(newValue) > Argon.kHeaderSizeInWordsBits ? Argon.kHeaderSizeInWordsBits : UInt64(newValue)
            let value = (theValue & Argon.kHeaderSizeInWordsBits) << Argon.kHeaderSizeInWordsShift
            self.bytes = (self.bytes & ~(Argon.kHeaderSizeInWordsBits << Argon.kHeaderSizeInWordsShift)) | value
            }
        }
        
    public var sizeInBytes: Word
        {
        get
            {
            Word(self.sizeInWords) * Argon.kWordSizeInBytesWord
            }
        set
            {
            self.sizeInWords = Int(newValue) / Argon.kWordSizeInBytesInt
            }
        }
        
    public var isPersistent: Bool
        {
        get
            {
            let mask = Argon.kHeaderPersistentBits << Argon.kHeaderPersistentShift
            return(((self.bytes & mask) >> Argon.kHeaderPersistentShift) == 1)
            }
        set
            {
            let value = ((newValue ? 1 : 0) & Argon.kHeaderPersistentBits) << Argon.kHeaderPersistentShift
            self.bytes = (self.bytes & ~(Argon.kHeaderPersistentBits << Argon.kHeaderPersistentShift)) | value
            }
        }
        
    public var typeCode:TypeCode
        {
        get
            {
            let mask = Argon.kHeaderTypeBits << Argon.kHeaderTypeShift
            return(TypeCode(rawValue: Int((self.bytes & mask) >> Argon.kHeaderTypeShift))!)
            }
        set
            {
            let value = (UInt64(newValue.rawValue) & Argon.kHeaderTypeBits) << Argon.kHeaderTypeShift
            self.bytes = (self.bytes & ~(Argon.kHeaderTypeBits << Argon.kHeaderTypeShift)) | value
            }
        }
        
    public var objectType:Argon.ObjectType
        {
        get
            {
            let mask = Argon.kHeaderTypeBits << Argon.kHeaderTypeShift
            return(Argon.ObjectType(rawValue: UInt64((self.bytes & mask) >> Argon.kHeaderTypeShift))!)
            }
        set
            {
            let value = (newValue.rawValue & Argon.kHeaderTypeBits) << Argon.kHeaderTypeShift
            self.bytes = (self.bytes & ~(Argon.kHeaderTypeBits << Argon.kHeaderTypeShift)) | value
            }
        }
        
    public var tag:Argon.Tag
        {
        get
            {
            let mask = Argon.kTagBits << Argon.kTagShift
            return(Argon.Tag(rawValue: (self.bytes & mask) >> Argon.kTagShift)!)
            }
        set
            {
            let value = (newValue.rawValue & Argon.kTagBits) << Argon.kTagShift
            self.bytes = (self.bytes & ~(Argon.kTagBits << Argon.kTagShift)) | value
            }
        }
        
    public var hasBytes: Bool
        {
        get
            {
            let mask = Argon.kHeaderHasBytesBits << Argon.kHeaderHasBytesShift
            return(((self.bytes & mask) >> Argon.kHeaderHasBytesShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Argon.kHeaderHasBytesBits) << Argon.kHeaderHasBytesShift
            self.bytes = (self.bytes & ~(Argon.kHeaderHasBytesBits << Argon.kHeaderHasBytesShift)) | value
            }
        }
        
    public var isForwarded: Bool
        {
        get
            {
            let mask = Argon.kHeaderForwardedBits << Argon.kHeaderForwardedShift
            return(((self.bytes & mask) >> Argon.kHeaderForwardedShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Argon.kHeaderForwardedBits) << Argon.kHeaderForwardedShift
            self.bytes = (self.bytes & ~(Argon.kHeaderForwardedBits << Argon.kHeaderForwardedShift)) | value
            }
        }
        
    public var flipCount:Int
        {
        get
            {
            let mask = Argon.kHeaderFlipBits << Argon.kHeaderFlipShift
            return(Int((self.bytes & mask) >> Argon.kHeaderFlipShift))
            }
        set
            {
            let value = (UInt64(newValue) & Argon.kHeaderFlipBits) << Argon.kHeaderFlipShift
            self.bytes = (self.bytes & ~(Argon.kHeaderFlipBits << Argon.kHeaderFlipShift)) | value
            }
        }
        
    public var bitString: String
        {
        self.bytes.bitString
        }
        
    internal var bytes: Word
        {
        get
            {
            pointer.pointee
            }
        set
            {
            pointer.pointee = newValue
            }
        }
        
    private let address: Word
    private let pointer: UnsafeMutablePointer<Word>
    private let wasAllocated: Bool
    
    public var stringRepresentation: String
        {
        
        let tag = self.bitString.substring(to:4)
        let size = "SIZE=\(self.sizeInWords * 8)"
        let hasBytes = self.hasBytes ? "BYTES=T" :"BYTES=F"
        let forward = self.isForwarded ? "FORW=T" : "FORW=F"
        let count = "FLIP=\(self.flipCount)"
        return("\(tag) \(size) \(hasBytes) \(forward) \(count)")
        }
        
    ///
    /// Purely for testing must not be used in production as it leaks memory like a sieve
    ///
    public init(word: Word)
        {
        self.address = 0
        self.pointer = UnsafeMutablePointer<Word>.allocate(capacity: 1)
        self.pointer.pointee = word
        self.wasAllocated = true
        }
        
    public init(atAddress: Word)
        {
        self.address = atAddress
        self.pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(atAddress.cleanAddress))!
        self.wasAllocated = false
        }
        
    deinit
        {
        if self.wasAllocated
            {
            self.pointer.deallocate()
            }
        }
    }

