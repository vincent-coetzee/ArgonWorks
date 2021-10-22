//
//  Cobalt.swift
//  CobaltX
//
//  Created by Vincent Coetzee on 2020/02/25.
//  Copyright © 2020 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct Argon
    {
    private static var nextIndexNumber = 0
    private static var uuidIndex:UInt8 = 64
    
    public static func nextName(_ prefix:String) -> String
        {
        return("\(prefix)_\(Argon.nextSymbolIndex())")
        }
        
    public static func nextSymbolIndex() -> Int
        {
        let index = self.nextIndexNumber
        self.nextIndexNumber += 1
        return(index)
        }
        
    public static let sampleSource =
        {
        () -> String in
        let url = Bundle.main.url(forResource: "Basics", withExtension: "argon")!
        let string = try! String(contentsOf: url)
        return(string)
        }()
        
    public static func nextUUIDIndex() -> UInt8
        {
        let index = self.uuidIndex
        self.uuidIndex += 1
        return(index)
        }
        
    public static let kArgonDefaultObjectFileDirectory = "/Users/vincent/Desktop"
    
    public typealias Integer = Int64
    public typealias UInteger = UInt64
    public typealias Integer32 = Int32
    public typealias UInteger32 = UInt32
    public typealias Integer16 = Int16
    public typealias UInteger16 = UInt16
    public typealias Integer8 = Int8
    public typealias UInteger8 = UInt8
    public typealias Integer64 = Int64
    public typealias UInteger64 = UInt64
    public typealias Float = Float64
    public typealias Float64 = Swift.Double
    public typealias Float32 = Swift.Float
    public typealias Float16 = Swift.Float
    public typealias Character = UInt16
    public typealias Address = UInt64
    public typealias Symbol = Swift.String
    public typealias String = Swift.String
    public typealias Byte = UInt8
    public typealias Date = ArgonDate
    public typealias DateTime = ArgonDateTime
    public typealias Time = ArgonTime
//    public typealias Range = ArgonRange
//    public typealias FullRange = ArgonFullRange
//    public typealias HalfRange = ArgonHalfRange
    public typealias Word = UInt64
    
    public enum Tag:UInt64
        {
        case integer =      0b0000  // PACK, COPY AND DON'T FOLLOW
        case float =        0b0001  // PACK, COPY AND DON'T FOLLOW
        case byte =         0b0010  // PACK, COPY AND DON'T FOLLOW
        case `nil` =        0b0011  // PACK, COPY AND DON'T FOLLOW
        case boolean =      0b0100  // PACK, COPY AND DON'T FOLLOW
        case bits =         0b0101  // PACK, COPY AND DON'T FOLLOW
        case header =       0b0110  // HANDLE
        case pointer =      0b0111  // FOLLOW
        case persistent =   0b1000  // HANDLE ACCORDINGLY
        }
        
    public enum Boolean:Argon.Integer8
        {
        case trueValue = 1
        case falseValue = 0
        }
        
    }

