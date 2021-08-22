//
//  Header.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public typealias Header = UInt64
    
extension Header
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
    public static let kTagShift:UInt64 = 59
    public static let kPersistentBits:UInt64 = 0b1
    public static let kPersistentShift:UInt64 = 62
    public static let kTypeBits:UInt64 = 0b1111111
    public static let kTypeShift:UInt64 = 0
    }
    
extension Header
    {
    public static func test()
        {
        var header:Header = 0
        
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
        print(header.bitString)
        }
        
    public var sizeInWords:Int
        {
        get
            {
            let mask = Self.kSizeBits << Self.kSizeShift
            return(Int((self & mask) >> Self.kSizeShift))
            }
        set
            {
            let value = (UInt64(newValue) & Self.kSizeBits) << Self.kSizeShift
            self = (self & ~(Self.kSizeBits << Self.kSizeShift)) | value
            }
        }
        
    public var isPersistent: Bool
        {
        get
            {
            let mask = Self.kPersistentBits << Self.kPersistentShift
            return(((self & mask) >> Self.kPersistentShift) == 1)
            }
        set
            {
            let value = ((newValue ? 1 : 0) & Self.kPersistentBits) << Self.kPersistentShift
            self = (self & ~(Self.kPersistentBits << Self.kPersistentShift)) | value
            }
        }
        
    public var typeCode:TypeCode
        {
        get
            {
            let mask = Self.kTypeBits << Self.kTypeShift
            return(TypeCode(rawValue: Int((self & mask) >> Self.kTypeShift))!)
            }
        set
            {
            let value = (UInt64(newValue.rawValue) & Self.kTypeBits) << Self.kTypeShift
            self = (self & ~(Self.kTypeBits << Self.kTypeShift)) | value
            }
        }
        
        
    public var tag:Argon.Tag
        {
        get
            {
            let mask = Self.kTagBits << Self.kTagShift
            return(Argon.Tag(rawValue: (self & mask) >> Self.kTagShift)!)
            }
        set
            {
            let value = (newValue.rawValue & Self.kTagBits) << Self.kTagShift
            self = (self & ~(Self.kTagBits << Self.kTagShift)) | value
            }
        }
        
    public var hasBytes: Bool
        {
        get
            {
            let mask = Self.kHasBytesBits << Self.kHasBytesShift
            return(((self & mask) >> Self.kHasBytesShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Self.kHasBytesBits) << Self.kHasBytesShift
            self = (self & ~(Self.kHasBytesBits << Self.kHasBytesShift)) | value
            }
        }
        
    public var isForwarded: Bool
        {
        get
            {
            let mask = Self.kForwardedBits << Self.kForwardedShift
            return(((self & mask) >> Self.kForwardedShift) == 1)
            }
        set
            {
            let value = (UInt64(newValue ? 1 : 0) & Self.kForwardedBits) << Self.kForwardedShift
            self = (self & ~(Self.kForwardedBits << Self.kForwardedShift)) | value
            }
        }
        
    public var flipCount:Int
        {
        get
            {
            let mask = Self.kFlipBits << Self.kFlipShift
            return(Int((self & mask) >> Self.kFlipShift))
            }
        set
            {
            let value = (UInt64(newValue) & Self.kFlipBits) << Self.kFlipShift
            self = (self & ~(Self.kFlipBits << Self.kFlipShift)) | value
            }
        }
        
    public var stringRepresentation: String
        {
        
        let tag = self.bitString.substring(to:4)
        let size = "SIZE=\(self.sizeInWords * 8)"
        let hasBytes = self.hasBytes ? "BYTES=T" :"BYTES=F"
        let forward = self.isForwarded ? "FORW=T" : "FORW=F"
        let count = "FLIP=\(self.flipCount)"
        return("\(tag) \(size) \(hasBytes) \(forward) \(count)")
        }
    }

