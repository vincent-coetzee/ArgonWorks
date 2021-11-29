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
    public static let blankPage = Page(virtualMachine: VirtualMachine.small)
    
    private static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
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
    private var pageAddress: Word = 0
    internal var virtualMachine: VirtualMachine
    private var nextOffset: Int = 88
    
    init(virtualMachine: VirtualMachine)
        {
        self.virtualMachine = virtualMachine
        self.memory = UnsafeMutableRawPointer(bitPattern: 0)!
        self.wordPointer = WordPointer(address: 0)!
        }

    public init(virtualMachine: VirtualMachine,lastPageOffset last: Word?,nextPageOffset next: Word?)
        {
        self.virtualMachine = virtualMachine
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
        
    @discardableResult
    public func nextPutWord(_ word:Word) -> Int
        {
        let after = self.nextOffset
        self.setValue(word,atOffset: self.nextOffset)
        self.nextOffset += MemoryLayout<Word>.size
        return(after)
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
        
    public func allocateObject(sizeInBytes: Int) -> Word
        {
        let offset = Word(self.nextFreeBlockOffset)
        self.nextFreeBlockOffset += sizeInBytes
        let objectPointer = WordPointer(address: self.address + offset)!
        var header = Header(0)
        header.sizeInWords = sizeInBytes / MemoryLayout<Word>.size
        header.flipCount = 0
        header.isForwarded = false
        header.hasBytes = false
        header.typeCode = .none
        objectPointer[0] = header
        return(address)
        }
        
    public func allocateString(_ input:String,in vm: VirtualMachine) -> Word
        {
//        let extraBytes = ((input.utf8.count / 7) + 1) * 8
//        let theClass = self.virtualMachine.topModule.argonModule.string
//        let totalBytes = theClass.sizeInBytes + extraBytes
//        let address = self.allocateObject(sizeInBytes: totalBytes)
//        if address.isZero
//            {
//            print("ERROR IN Page.allocateString")
//            print("ERROR ALLOCATING STRING AT \(address.addressString)")
//            return(0)
//            }
//        let object = WordPointer(address: address)!
//        object[1] = Word(bitPattern: Int64(theClass.magicNumber))      // WRITE THE _magicNumber
//        object[2] = theClass.memoryAddress                             // WRITE THE _classPointer
//        let objectClass = self.virtualMachine.topModule.argonModule.object
//        object[3] = Word(bitPattern: Int64(0))                         // WRITE THE _ObjectHeader
//        object[4] = Word(bitPattern: Int64(objectClass.magicNumber))   // WRITE THE _ObjectMagicNumber
//        object[5] = objectClass.memoryAddress                          // WRITE THE _ObjectClassPointer
//        let offset = UInt(address) + UInt(theClass.sizeInBytes)
//        let offsetOfCount = 56
//        let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
//        let countAddress = Word(offsetOfCount) + address
//        let wordPointer = WordPointer(address: countAddress)!          // WRITE THE count
//        wordPointer[0] = Word(input.utf8.count)
//        let string = input.utf8
//        var position = 0
//        var index = string.startIndex
//        var count = string.count
//        while position < count
//            {
//            if position % 7 == 0
//                {
//                bytePointer[position] = Self.kBitsByte
//                position += 1
//                count += 1
//                }
//            else
//                {
//                bytePointer[position] = string[index]
//                position += 1
//                index = string.index(after: index)
//                }
//            }
//        return(address)
        return(.zero)
        }
    }
