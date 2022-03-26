//
//  Storable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/10/21.
//

import Foundation

//public struct StorageConstants
//    {
//    public static let kNilMarker = 0x00
//    public static let kIntMarker = 0x01
//    public static let kStringMarker = 0x02
//    public static let kObjectReferenceMarker = 0x03
//    public static let kArrayMarker = 0x04
//    public static let kSetMarker = 0x05
//    public static let kDictionaryMarker = 0x05
//    public static let kBoolMarker = 0x06
//    public static let kFloatMarker = 0x06
//    public static let kRawIntMarker = 0x07
//    public static let kRawStringMarker = 0x08
//    public static let kTypeNameMarker = 0x09
//    
//    public typealias ClassTable = Dictionary<String,Storable.Type>
//    
//    public private(set) static var classes = ClassTable()
//    
//        
//    public static func initClasses()
//        {
////        self.addType(Symbol.self)
////        self.addType(Class.self)
////        self.addType(Method.self)
////        self.addType(Invokable.self)
////        self.addType(Function.self)
////        self.addType(TypeAlias.self)
////        self.addType(Constant.self)
////        self.addType(Enumeration.self)
////        self.addType(EnumerationCase.self)
////        self.addType(Argument.self)
////        self.addType(Parameter.self)
////        self.addType(Slot.self)
////        self.addType(LocalSlot.self)
////        self.addType(ArraySlot.self)
////        self.addType(ObjectSlot.self)
////        self.addType(StringSlot.self)
////        self.addType(FloatSlot.self)
////        self.addType(HeaderSlot.self)
////        self.addType(BooleanSlot.self)
////        self.addType(VirtualSlot.self)
////        self.addType(IntegerSlot.self)
////        self.addType(SymbolGroup.self)
////        self.addType(Module.self)
////        self.addType(SystemModule.self)
////        self.addType(TopModule.self)
////        self.addType(ArgonModule.self)
////        self.addType(Import.self)
////        self.addType(SystemMethod.self)
////        self.addType(ArrayClass.self)
////        self.addType(ArrayClassInstance.self)
////        self.addType(ClosureClass.self)
////        self.addType(GenericClass.self)
////        self.addType(GenericClassInstance.self)
////        self.addType(GenericClassParameter.self)
////        self.addType(SystemClass.self)
////        self.addType(GenericSystemClass.self)
////        self.addType(GenericSystemClassInstance.self)
////        self.addType(Metaclass.self)
////        self.addType(SlotList.self)
////        self.addType(TaggedPrimitiveClass.self)
////        self.addType(VoidClass.self)
////        self.addType(Tuple.self)
////        self.addType(Initializer.self)
////        self.addType(Closure.self)
////        self.addType(Function.self)
////        self.addType(MethodInstance.self)
////        self.addType(SystemMethodInstance.self)
////        self.addType(LibraryModule.self)
////        self.addType(MainModule.self)
////        self.addType(Type.self)
////        self.addType(Parent.self)
////        self.addType(Node.self)
////        self.addType(Name.self)
////        self.addType(PrivacyScope.self)
////        self.addType(NodeLocation.self)
//        }
//        
//    private static func addType<T>(_ kind:T.Type) where T: Storable
//        {
//        let key = String(reflecting: kind)
//        if self.classes[key].isNotNil
//            {
//            fatalError("Classes is adding \(key) but it already has a value at that key.")
//            }
//        self.classes[key] = kind
//        }
//    }
//    
//public protocol Storable
//    {
////    init(input: InputFile) throws
//    func write(output: OutputFile) throws
//    }
//
//public protocol StorableObject: Storable
//    {
//    var index: UUID { get }
//    }
//
//public protocol File
//    {
//    var path: URL? { get set }
//    }
//    
//public protocol InputFile: File
//    {
//    }
//    
//public protocol OutputFile: File
//    {
//    func writeRootObject(_ root: StorableObject) throws
//    func writeType(of: Any) throws
//    func write(_ integer:Int) throws
//    func write(_ boolean:Bool) throws
//    func write(_ string:String) throws
//    func write(_ float:Double) throws
//    func write(_ array: Array<UInt8>) throws
//    func write(_ item: Storable) throws
//    func write(_ array: Array<Storable>) throws
//    func write<Item>(_ set: Set<Item>) throws where Item: Hashable,Item: Storable
//    func write<Key,Value>(_ dictionary: Dictionary<Key,Value>) throws
//        where Key: Hashable,Key: Storable,
//            Value: Storable
//    func write<Item>(_ storable: Item) throws where Item: Storable, Item: RawRepresentable, Item.RawValue == Int
//    func write<Item>(_ storable: Item) throws where Item: Storable, Item: RawRepresentable, Item.RawValue == String
//    }
//    
//extension OutputFile
//    {
//    public func write(_ array: Array<Storable>) throws
//        {
//        try self.write(StorageConstants.kArrayMarker.bytes)
//        try self.write(array.count.bytes)
//        for item in array
//            {
//            try self.write(item)
//            }
//        }
//        
//    public func write<Item>(_ set: Set<Item>) throws where Item: Hashable, Item: Storable
//        {
//        try self.write(StorageConstants.kSetMarker.bytes)
//        try self.write(set.count.bytes)
//        for item in set
//            {
//            try self.write(item)
//            }
//        }
//        
//    public func write<Key,Item>(_ dictionary: Dictionary<Key,Item>) throws where Key: Storable,Item: Storable
//        {
//        try self.write(StorageConstants.kSetMarker.bytes)
//        try self.write(dictionary.count.bytes)
//        for (key,value) in dictionary
//            {
//            try self.write(key)
//            try self.write(value)
//            }
//        }
//    }
//    
//public class Archiver: OutputFile
//    {
//    public var path: URL? = nil
//    private var buffer: Data
//    private var objectTable: Dictionary<UUID,StorableObject> = [:]
//    
//    public init(path: URL)
//        {
//        self.path = path
//        self.buffer = Data()
//        }
//        
//    public func writeRootObject(_ root: StorableObject) throws
//        {
//        try self.write(root)
//        try self.writeObjectTable()
//        }
//        
//    public func writeType(of: Any) throws
//        {
//        let typeName = String(reflecting: of)
//        self.buffer.append(contentsOf: StorageConstants.kTypeNameMarker.bytes)
//        try self.writeRawString(typeName)
//        }
//        
//    public func write(_ item: Storable) throws
//        {
//        try self.writeContents(of: item)
//        }
//        
//    public func writeType(_ type: Any.Type) throws
//        {
//        let baseType = Swift.type(of: type)
//        let typeName = String(reflecting: baseType)
//        try self.writeRawString(typeName)
//        }
//        
//    public func write<Item>(_ storable: Item) throws where Item : Storable, Item : RawRepresentable, Item.RawValue == String
//        {
//        let string = storable.rawValue
//        try self.write(StorageConstants.kRawStringMarker)
//        try self.writeType(Swift.type(of: storable))
//        try self.writeRawString(string)
//        }
//    
//    public func write<Item>(_ storable: Item) throws where Item : Storable, Item : RawRepresentable, Item.RawValue == Int
//        {
//        let integer = storable.rawValue
//        try self.write(StorageConstants.kRawIntMarker)
//        try self.writeType(Swift.type(of: storable))
//        self.buffer.append(contentsOf: integer.bytes)
//        }
//        
//    public func write(_ array: Array<UInt8>) throws
//        {
//        self.buffer.append(contentsOf: array)
//        }
//        
//    public func write(_ integer: Int) throws
//        {
//        self.buffer.append(contentsOf: StorageConstants.kIntMarker.bytes)
//        self.buffer.append(contentsOf: integer.bytes)
//        }
//        
//    public func write(_ float: Double) throws
//        {
//        self.buffer.append(contentsOf: StorageConstants.kFloatMarker.bytes)
//        self.buffer.append(contentsOf: float.bytes)
//        }
//    
//    public func write(_ boolean:Bool) throws
//        {
//        self.buffer.append(contentsOf: StorageConstants.kBoolMarker.bytes)
//        self.buffer.append(boolean ? 1 : 0)
//        }
//    ///
//    ///
//    /// Write a raw string, this is a string without a marker,
//    /// this is needed in some places for example when writing
//    /// the name of a type to the output.
//    ///
//    ///
//    private func writeRawString(_ rawString: String) throws
//        {
//        let utf8 = rawString.utf8
//        try self.write(utf8.count)
//        try self.write(Array(utf8))
//        }
//        
//    public func write(_ string:String) throws
//        {
//        self.buffer.append(contentsOf: StorageConstants.kStringMarker.bytes)
//        let utf8 = string.utf8
//        try self.write(utf8.count)
//        try self.write(Array(utf8))
//        }
//        
//    public func write(_ storable: StorableObject) throws
//        {
//        self.buffer.append(contentsOf: StorageConstants.kObjectReferenceMarker.bytes)
//        var bytes = Array<UInt8>()
//        let bits = storable.index.uuid
//        bytes.append(bits.0)
//        bytes.append(bits.1)
//        bytes.append(bits.2)
//        bytes.append(bits.3)
//        bytes.append(bits.4)
//        bytes.append(bits.5)
//        bytes.append(bits.6)
//        bytes.append(bits.7)
//        bytes.append(bits.8)
//        bytes.append(bits.9)
//        bytes.append(bits.10)
//        bytes.append(bits.11)
//        bytes.append(bits.12)
//        bytes.append(bits.13)
//        bytes.append(bits.14)
//        bytes.append(bits.15)
//        self.buffer.append(contentsOf: bytes)
//        self.objectTable[storable.index] = storable
//        try self.writeContents(of: storable)
//        }
//        
//    private func writeContents(of storable: Storable) throws
//        {
//        var mirror:Mirror? = Mirror(reflecting: storable)
//        try self.writeType(of: storable)
//        while mirror.isNotNil
//            {
//            if let kids = mirror?.children
//                {
//                for (label,value) in kids
//                    {
//                    if value is Array<StorableObject>
//                        {
//                        let array = value as! Array<Storable>
//                        try self.write(array)
//                        }
//                    else if value is Array<Storable>
//                        {
//                        let array = value as! Array<Storable>
//                        try self.write(array)
//                        }
//                    else if value is Storable
//                        {
//                        let storable = value as! Storable
//                        try storable.write(output: self)
//                        }
//                    else
//                        {
//                        print("WARNING: Unhandled type with name \(String(describing: label)) and value \(value) of type(Swift.type(of: value))")
//                        }
//                    }
//                }
//            mirror = mirror?.superclassMirror
//            }
//        }
//        
//    public func writeObjectTable() throws
//        {
//        }
//    }
