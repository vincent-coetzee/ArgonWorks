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
        case integer =   0b000      /// an integer or uinteger value
        case float =     0b001      /// a float value
        case byte =      0b010      /// a byte value 0 - 255
        case character = 0b011      /// a two byte value 0 - 65535
        case boolean =   0b100      /// true or false
        case header =    0b101      /// marks an object header
        case object =    0b111      /// an object address which is followed
        
        public var displayString: String
            {
            switch(self)
                {
                case .integer:
                    return("INTG")
                case .float:
                    return("FLOT")
                case .byte:
                    return("BYTE")
                case .character:
                    return("CHAR")
                case .boolean:
                    return("BOOL")
                case .header:
                    return("HEAD")
                case .object:
                    return("OBJT")
                }
            }
        }
    
    public enum Segment:UInt64
        {
        case none =     0b000       /// This is a raw address and has no segment
        case managed =  0b001       /// The segment where all runtime allocations take place, this is a garbage collected segment
        case `static` = 0b010       /// Objects such as classes, slots and certain strings go in this segment
        case data =     0b011       /// General data area
        case stack =    0b101       /// This segment grows from the top down and is managed in blocks, the runtime activation frames are stored here
        }
        
    ///
    /// The top bit of an address is unused because the sign bit of integers goes there,
    /// the next 3 bits contain the ag which indicates the type of value this word
    /// contains, the next 3 bits store the segment this address belongs to ( if it is an address ).
    ///
    ///
    
    public static let kSegmentMask:Word = 0b111
    public static let kSegmentExtendedMask:Word = Argon.kSegmentMask << Argon.kSegmentShift
    public static let kSegmentShift: Word = 56
    
    public static let kIntegerTag = Self.Tag.integer.rawValue << 60
    public static let kFloatTag = Self.Tag.float.rawValue << 60
    public static let kByteTag = Self.Tag.byte.rawValue << 60
    public static let kCharacterTag = Self.Tag.character.rawValue << 60
    public static let kBooleanTag = Self.Tag.boolean.rawValue << 60
    public static let kHeaderTag = Self.Tag.header.rawValue << 60
    public static let kObjectTag = Self.Tag.object.rawValue << 60
    
    public static let kTagMask:Word = 0b111 << 60
    public static let kTagShift:Word = 60
    
    public static let kWordSizeInBytes = 8
    public static let kArgumentSizeInBytes = 8
    public static let kHandleSizeInBytes = 8
    
    public static let kWordSizeInBytesInt = MemoryLayout<Word>.size
    public static let kWordSizeInBytesWord = Word(MemoryLayout<Word>.size)
    
    public static let kIsEnumerationInstancePointerShift: Word = 59
    public static let kIsEnumerationInstancePointerBits: Word = 0b1
    public static let kIsEnumerationInstancePointerBitMask = Argon.kIsEnumerationInstancePointerBits << Argon.kIsEnumerationInstancePointerShift
    
    public enum ObjectType:UInt64
        {
        case none = 0
        case string = 1
        case `class` = 2
        case metaclass = 3
        case symbol = 4
        case date = 5
        case time = 6
        case dateTime = 7
        case enumeration = 8
        case enumerationCase = 9
        case enumrationCaseInstance = 10
        case tuple = 11
        case module = 12
        case slot = 13
        case function = 14
        case methodInstance = 15
        case array = 16
        case dictionaryBucket = 17
        case dictionary = 18
        case set = 19
        case list = 20
        case bitSet = 21
        case pointer = 22
        case listNode = 23
        case vector = 24
        case closure = 25
        case frame = 26
        case object = 27
        case magnitude = 28
        case error = 29
        case block = 30
        case index = 31
        case number = 32
        case void = 33
        case address = 34
        case type = 35
        case genericClass = 36
        case parameter = 37
        case variadicParameter = 38
        case `nil` = 39
        case invokable = 40
        case collection = 41
        case integer = 42
        case float = 43
        case uInteger = 44
        case character = 45
        case byte = 46
        case boolean = 47
        case instruction = 48
        case opcode = 49
        case operand = 50
        case wordBlock = 51
        case arrayBlock = 52
        case vectorBlock = 53
        case setBlock = 54
        case custom = 100
        }
        
    public enum Boolean:Argon.Integer8
        {
        case trueValue = 1
        case falseValue = 0
        }
        
    public static var staticTable = Array<StaticObject>()
    
    @discardableResult
    public static func addStatic<T>(_ staticObject: T) -> T where T:StaticObject
        {
        for element in self.staticTable
            {
            if element.hash == staticObject.hash
                {
                return(element as! T)
                }
            }
        self.staticTable.append(staticObject)
        return(staticObject)
        }
        
    public static var typeTable = Dictionary<Int,Type>()
    
    @discardableResult
    public static func addType(_ type: Type) -> Type
        {
//        return(type)
        if self.typeTable.isEmpty
            {
            print("halt")
            }
        if let oldType = Self.typeTable[type.argonHash]
            {
            print("FOUND EXISTING TYPE \(type)")
            return(oldType)
            }
        print("DID NOT FIND \(type)")
        Self.typeTable[type.argonHash] = type
        return(type)
        }
        
    public static func typeAtKey(_ key: Int) -> Type?
        {
        Self.typeTable[key]
        }
        
    public static func resetStatics()
        {
        self.staticTable = []
        }
        
    public static func resetTypes()
        {
        self.typeTable = [:]
        }
    }

