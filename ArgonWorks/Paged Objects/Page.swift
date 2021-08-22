//
//  Page.swift
//  Page
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public typealias Pages = Array<Page>

public class Page
    {
    public static let blankPage = Page()
    
    internal static let kPageSizeInBytes = 4 * 1024
    private static let kPageAlignmentInBytes = 4 * 1024 * 1024
    
    private static let kBytesRemainingOffset = 0
    private static let kNextFreeBytesOffset = 8
    private static let kNextPageOffset = 16
    private static let kLastPageOffset = 24
    private static let kInMemoryAddress = 32
    private static let kOffsetOffset = 40
    private static let kBookeepingSizeInBytes = 80
    public static let kFirstOffset = 80
    
    private var nextFreeBlockOffset: Int
        {
        get
            {
            return(Int(self.intValue(atOffset: Self.kNextFreeBytesOffset)))
            }
        set
            {
            self.setValue(Word(newValue),atOffset: Self.kNextFreeBytesOffset)
            }
        }
        
    private var nextPageOffset: Int
        {
        get
            {
            return(Int(self.intValue(atOffset: Self.kNextPageOffset)))
            }
        set
            {
            self.setValue(Word(newValue),atOffset: Self.kNextPageOffset)
            }
        }
        
    private var lastPageOffset: Int
        {
        get
            {
            return(self.intValue(atOffset: Self.kLastPageOffset))
            }
        set
            {
            self.setValue(newValue,atOffset: Self.kLastPageOffset)
            }
        }
        
    private var freeSpaceInBytes: Int
        {
        Self.kPageSizeInBytes - self.nextFreeBlockOffset
        }
        
    private var memory: UnsafeMutableRawPointer
    public  var wordPointer: WordPointer
    private var isMapped: Bool = false
    private var isAllocated: Bool = false
    private var address: Word = 0
    private var offset: Int = 0
    
    init()
        {
        self.memory = UnsafeMutableRawPointer(bitPattern: 0)!
        self.wordPointer = WordPointer(address: 0)!
        }

    public init(lastPageOffset last: Word?,nextPageOffset next: Word?)
        {
        self.memory = UnsafeMutableRawPointer(bitPattern: 0)!
        self.wordPointer = WordPointer(address: 0)!
        memset(self.memory,0,Self.kPageSizeInBytes)
        self.setValue(Word(Self.kPageSizeInBytes - Self.kBookeepingSizeInBytes),atOffset: Self.kBytesRemainingOffset)
        self.setValue(Word(Self.kBookeepingSizeInBytes),atOffset: Self.kNextFreeBytesOffset)
        self.setValue(next ?? 0,atOffset: Self.kNextPageOffset)
        self.setValue(last ?? 0,atOffset: Self.kLastPageOffset)
        self.setValue(Int(last ?? 0) + Self.kPageSizeInBytes,atOffset: Self.kOffsetOffset)
        }
        
    public func allocate() -> Self
        {
        self.memory = UnsafeMutableRawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: Self.kPageAlignmentInBytes)
        self.isAllocated = true
        self.address = Word(Int(bitPattern: self.memory))
        self.wordPointer = WordPointer(address: self.address)!
        print("Address of aligned page memory is \(address.addressString) \(address.bitString)")
        return(self)
        }
        
    public func writeNew(pageServer: PageServer)
        {
        }
        
    @inline(__always)
    @inlinable
    public func value(atOffset: Int) -> Word
        {
        return(self.wordPointer[atOffset / 8])
        }
        
    @inline(__always)
    @inlinable
    public func intValue(atOffset: Int) -> Int
        {
        return(Int(Int64(bitPattern: self.wordPointer[atOffset / 8])))
        }
        
    @inline(__always)
    @inlinable
    public func setValue(_ word: Word,atOffset: Int)
        {
        self.wordPointer[atOffset / 8] = word
        }
        
    @inline(__always)
    @inlinable
    public func setValue(_ integer: Int,atOffset: Int)
        {
        self.wordPointer[atOffset / 8] = Word(bitPattern: Int64(integer))
        }
        
    public func writeToFile(_ handle:UnsafeMutablePointer<FILE>?,atIndex: Int)
        {
        let offset = atIndex * Self.kPageSizeInBytes
        fseek(handle,offset,SEEK_SET)
        fwrite(self.memory,1,Self.kPageSizeInBytes,handle)
        }
        
    public func writeToFile(_ handle:UnsafeMutablePointer<FILE>?)
        {
        fseek(handle,self.offset,SEEK_SET)
        fwrite(self.memory,1,Self.kPageSizeInBytes,handle)
        }
        
    public func fillTestBlock(with word:Word,count: Int)
        {
        var offset = self.nextFreeBlockOffset
        for _ in 1..<count
            {
            self.setValue(word,atOffset: offset)
            offset += MemoryLayout<Word>.size
            }
        self.nextFreeBlockOffset = offset
        }
        
    public func allocateObject(ofClass pointer: InnerClassPointer) -> Word
        {
        let offset = Word(self.nextFreeBlockOffset)
        self.nextFreeBlockOffset += pointer.instanceSizeInBytes
        let objectPointer = WordPointer(address: self.address + offset)!
        var header = Header(0)
        header.sizeInWords = pointer.instanceSizeInWords
        header.flipCount = 0
        header.isForwarded = false
        header.hasBytes = false
        header.typeCode = pointer.typeCode
        objectPointer[0] = header
        objectPointer[1] = Word(bitPattern: pointer.magicNumber)
        objectPointer[2] = pointer.address
        return(address)
        }
    }
