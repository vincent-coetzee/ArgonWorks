//
//  ObjectHandle.swift
//  ObjectHandle
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public typealias ObjectHandle = UInt64

extension ObjectHandle
    {
    public static let kPageIndexMask:Word = (Word(1) << ObjectHandle.kPageIndexBitSize) - 1
    public static let kOffsetMask:Word = Word(1) << ObjectHandle.kOffsetBitSize
    public static let kPageIndexBitSize:Word = 36
    public static let kPageIndexShift:Word = 20
    public static let kOffsetBitSize:Word = 20
    
    public var pageIndex: Word
        {
        self & (Self.kPageIndexMask << Self.kPageIndexShift) >> Self.kPageIndexShift
        }
        
    public var offset: Word
        {
        self & Self.kOffsetMask
        }
        
    public init(page: Word,offset: Word)
        {
        let pageWord = (page & Self.kPageIndexMask) << Self.kPageIndexShift
        let offsetWord = offset & Self.kOffsetMask
        self = pageWord | offsetWord
        }
    }


public class StringHandle
    {
    public var string: String
        {
        return("")
        }
        
    private let handle: ObjectHandle
    
    init(handle:ObjectHandle)
        {
        self.handle = handle
        }
    }
