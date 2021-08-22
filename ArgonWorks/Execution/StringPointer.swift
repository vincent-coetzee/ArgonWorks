//
//  StringPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

//public class StringPointer
//    {
//    private static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
//    
//    private let address:Word
//    private var wordPointer:WordPointer?
////    private let theClass:Class = ArgonModule.argonModule.string
//    private let extraOffset:Int
//    private let countOffset:Int
//    
////    public var string:String
////        {
////        get
////            {
////            if self.address.isZero
////                {
////                return("nil")
////                }
////            let offset = UInt(address) + UInt(theClass.sizeInBytes)
////            let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
////            let count = self.count
////            var string = ""
////            var position = 0
////            var done = 0
////            while done < count
////                {
////                if position % 7 == 0
////                    {
////                    position += 1
////                    }
////                else
////                    {
////                    let byte = bytePointer[position]
////                    let character = UnicodeScalar(byte)
////                    string += character
////                    position += 1
////                    done += 1
////                    }
////                }
////            return(string)
////            }
////        set
////            {
////            if self.address.isZero
////                {
////                return
////                }
////            let offset = UInt(address) + UInt(theClass.sizeInBytes)
////            let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
////            self.count = newValue.utf8.count
////            let string = newValue.utf8
////            var position = 0
////            var index = string.startIndex
////            var count = string.count
////            while position < count
////                {
////                if position % 7 == 0
////                    {
////                    bytePointer[position] = Self.kBitsByte
////                    position += 1
////                    count += 1
////                    }
////                else
////                    {
////                    bytePointer[position] = string[index]
////                    position += 1
////                    index = string.index(after: index)
////                    }
////                }
////            }
////        }
//        
//    init(address:Word)
//        {
//        self.address = address
//        self.wordPointer = WordPointer(address: address)
//        fatalError()
////        self.extraOffset = theClass.sizeInBytes / MemoryLayout<Word>.size
////        self.countOffset = theClass.layoutSlot(atLabel: "count")!.offset / 8
//        }
//        
//    public var count:Int
//        {
//        get
//            {
//            return(Int(self.wordPointer?[self.countOffset] ?? 0))
//            }
//        set
//            {
//            self.wordPointer?[self.countOffset] = Word(newValue)
//            }
//        }
//    }
