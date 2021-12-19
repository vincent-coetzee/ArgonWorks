//
//  Header.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation
    
public class Header
    {
    public static let kSizeBits:UInt64 = 0b11111111_11111111_111111111_11111111_11111111
    public static let kSizeShift:UInt64 = 18
    public static let kHasBytesBits:UInt64 = 0b1
    public static let kHasBytesShift = 17
    public static let kFlipBits:UInt64 = 0b11111111
    public static let kFlipShift = 9
    public static let kForwardedBits:UInt64 = 0b1
    public static let kForwardedShift = 8
    public static let kTagBits:UInt64 = 0b111
    public static let kTagShift:UInt64 = 60
    public static let kPersistentBits:UInt64 = 0b1
    public static let kPersistentShift:UInt64 = 7
    public static let kTypeBits:UInt64 = 0b1111111
    public static let kTypeShift:UInt64 = 0
    
    public static let kTagBitsMask = Header.kTagBits << Header.kTagShift
    
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
        assert(header.sizeInWords == Int(Self.kSizeBits),"Header.sizeInWords should be \(Self.kSizeBits) but is \(header.sizeInWords)")
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
            let mask = Self.kSizeBits << Self.kSizeShift
            return(Int((self.bytes & mask) >> Self.kSizeShift))
            }
        set
            {
            let theValue = UInt64(newValue) > Self.kSizeBits ? Self.kSizeBits : UInt64(newValue)
            let value = (theValue & Self.kSizeBits) << Self.kSizeShift
            self.bytes = (self.bytes & ~(Self.kSizeBits << Self.kSizeShift)) | value
            }
        }
        
    public var sizeInBytes: Word
        {
        get
            {
            let mask = Self.kSizeBits << Self.kSizeShift
            return(((self.bytes & mask) >> Self.kSizeShift) * Argon.kWordSizeInBytesWord)
            }
        set
            {
            var theValue = newValue / Argon.kWordSizeInBytesWord
            theValue = theValue > Self.kSizeBits ? Self.kSizeBits : theValue
            let value = (theValue & Self.kSizeBits) << Self.kSizeShift
            self.bytes = (self.bytes & ~(Self.kSizeBits << Self.kSizeShift)) | value
            }
        }
        
    public var isPersistent: Bool
        {
        get
            {
            let mask = Self.kPersistentBits << Self.kPersistentShift
            return(((self.bytes & mask) >> Self.kPersistentShift) == 1)
            }
        set
            {
            let value = ((newValue ? 1 : 0) & Self.kPersistentBits) << Self.kPersistentShift
            self.bytes = (self.bytes & ~(Self.kPersistentBits << Self.kPersistentShift)) | value
            }
        }
        
    public var typeCode:TypeCode
        {
        get
            {
            let mask = Self.kTypeBits << Self.kTypeShift
            return(TypeCode(rawValue: Int((self.bytes & mask) >> Self.kTypeShift))!)
            }
        set
            {
            let value = (UInt64(newValue.rawValue) & Self.kTypeBits) << Self.kTypeShift
            self.bytes = (self.bytes & ~(Self.kTypeBits << Self.kTypeShift)) | value
            }
        }
        
    public var objectType:Argon.ObjectType
        {
        get
            {
            let mask = Self.kTypeBits << Self.kTypeShift
            return(Argon.ObjectType(rawValue: UInt64((self.bytes & mask) >> Self.kTypeShift))!)
            }
        set
            {
            let value = (newValue.rawValue & Self.kTypeBits) << Self.kTypeShift
            self.bytes = (self.bytes & ~(Self.kTypeBits << Self.kTypeShift)) | value
            }
        }
        
    public var tag:Argon.Tag
        {
        get
            {
            let mask = Self.kTagBits << Self.kTagShift
            return(Argon.Tag(rawValue: (self.bytes & mask) >> Self.kTagShift)!)
            }
        set
            {
            let value = (newValue.rawValue & Self.kTagBits) << Self.kTagShift
            self.bytes = (self.bytes & ~(Self.kTagBits << Self.kTagShift)) | value
            }
        }
        
    public var hasBytes: Bool
        {
        get
            {
            let mask = Self.kHasBytesBits << Self.kHasBytesShift
            return(((self.bytes & mask) >> Self.kHasBytesShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Self.kHasBytesBits) << Self.kHasBytesShift
            self.bytes = (self.bytes & ~(Self.kHasBytesBits << Self.kHasBytesShift)) | value
            }
        }
        
    public var isForwarded: Bool
        {
        get
            {
            let mask = Self.kForwardedBits << Self.kForwardedShift
            return(((self.bytes & mask) >> Self.kForwardedShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Self.kForwardedBits) << Self.kForwardedShift
            self.bytes = (self.bytes & ~(Self.kForwardedBits << Self.kForwardedShift)) | value
            }
        }
        
    public var flipCount:Int
        {
        get
            {
            let mask = Self.kFlipBits << Self.kFlipShift
            return(Int((self.bytes & mask) >> Self.kFlipShift))
            }
        set
            {
            let value = (UInt64(newValue) & Self.kFlipBits) << Self.kFlipShift
            self.bytes = (self.bytes & ~(Self.kFlipBits << Self.kFlipShift)) | value
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

