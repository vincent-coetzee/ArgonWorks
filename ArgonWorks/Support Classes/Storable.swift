//
//  Storable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/10/21.
//

import Foundation

public struct StorageConstants
    {
    public static let kNilMarker = 0x00
    public static let kIntMarker = 0x01
    public static let kStringMarker = 0x0A
    public static let kObjectReferenceMarker = 0x0B
    public static let kArrayMarker = 0x0C
    
    public typealias ClassTable = Dictionary<String,Storable.Type>
    
    public private(set) static var classes = ClassTable()
    
        
    public static func initClasses()
        {
//        self.addType(Symbol.self)
//        self.addType(Class.self)
//        self.addType(Method.self)
//        self.addType(Invokable.self)
//        self.addType(Function.self)
//        self.addType(TypeAlias.self)
//        self.addType(Constant.self)
//        self.addType(Enumeration.self)
//        self.addType(EnumerationCase.self)
//        self.addType(Argument.self)
//        self.addType(Parameter.self)
//        self.addType(Slot.self)
//        self.addType(LocalSlot.self)
//        self.addType(ArraySlot.self)
//        self.addType(ObjectSlot.self)
//        self.addType(StringSlot.self)
//        self.addType(FloatSlot.self)
//        self.addType(HeaderSlot.self)
//        self.addType(BooleanSlot.self)
//        self.addType(VirtualSlot.self)
//        self.addType(IntegerSlot.self)
//        self.addType(SymbolGroup.self)
//        self.addType(Module.self)
//        self.addType(SystemModule.self)
//        self.addType(TopModule.self)
//        self.addType(ArgonModule.self)
//        self.addType(Import.self)
//        self.addType(SystemMethod.self)
//        self.addType(ArrayClass.self)
//        self.addType(ArrayClassInstance.self)
//        self.addType(ClosureClass.self)
//        self.addType(GenericClass.self)
//        self.addType(GenericClassInstance.self)
//        self.addType(GenericClassParameter.self)
//        self.addType(SystemClass.self)
//        self.addType(GenericSystemClass.self)
//        self.addType(GenericSystemClassInstance.self)
//        self.addType(Metaclass.self)
//        self.addType(SlotList.self)
//        self.addType(TaggedPrimitiveClass.self)
//        self.addType(VoidClass.self)
//        self.addType(Tuple.self)
//        self.addType(Initializer.self)
//        self.addType(Closure.self)
//        self.addType(Function.self)
//        self.addType(MethodInstance.self)
//        self.addType(SystemMethodInstance.self)
//        self.addType(LibraryModule.self)
//        self.addType(MainModule.self)
//        self.addType(Type.self)
//        self.addType(Parent.self)
//        self.addType(Node.self)
//        self.addType(Name.self)
//        self.addType(PrivacyScope.self)
//        self.addType(NodeLocation.self)
        }
        
    private static func addType<T>(_ kind:T.Type) where T: Storable
        {
        let key = String(reflecting: kind)
        if self.classes[key].isNotNil
            {
            fatalError("Classes is adding \(key) but it already has a value at that key.")
            }
        self.classes[key] = kind
        }
    }
    
public protocol Storable
    {
    init(input: InputFile) throws
    func write(output: OutputFile) throws
    }
    
public protocol StorableObject: Storable
    {
    var index: UUID { get }
    }
    
public protocol File
    {
    var path: URL? { get set }
    }
    
public protocol InputFile: File
    {
    }
    
public protocol OutputFile: File
    {
    func write(_ integer:Int) throws
    func write(_ array: Array<UInt8>) throws
    func write<Item>(_ item: Item) throws where Item: Storable
    func write<Item>(_ array: Array<Item>) throws where Item: Storable
    func write<Item>(_ storable: Item) throws where Item: Storable,Item: AnyObject
    func write<Item>(_ storable: Item) throws where Item: Storable, Item: RawRepresentable, Item.RawValue == Int
    func write<Item>(_ storable: Item) throws where Item: Storable, Item: RawRepresentable, Item.RawValue == String
    }
    
extension OutputFile
    {
    public func write<Item>(_ array: Array<Item>) throws where Item: Storable
        {
        try self.write(StorageConstants.kArrayMarker.bytes)
        try self.write(array.count.bytes)
        for item in array
            {
            try self.write(item)
            }
        }
    }
    
public class Archiver: OutputFile
    {
    public var path: URL? = nil
    private var buffer: Data
    
    public init(path: URL)
        {
        self.path = path
        self.buffer = Data()
        }
        
    public func write<Item>(_ item: Item) throws where Item: Storable
        {
        try item.write(output: self)
        }
        
    public func write<Item>(_ storable: Item) throws where Item : Storable, Item : RawRepresentable, Item.RawValue == String
        {
        let string = storable as! String
        let utf8 = string.utf8
        try self.write(StorageConstants.kStringMarker)
        try self.write(utf8.count)
        try self.write(Array(utf8))
        }
    
    public func write(_ array: Array<UInt8>) throws
        {
        self.buffer.append(contentsOf: array)
        }
        
    public func write(_ integer: Int) throws
        {
        self.buffer.append(contentsOf: StorageConstants.kIntMarker.bytes)
        self.buffer.append(contentsOf: integer.bytes)
        }
    
    public func write<Item>(_ storable: Item) throws where Item : AnyObject, Item : StorableObject
        {
        self.buffer.append(contentsOf: StorageConstants.kObjectReferenceMarker.bytes)
        var bytes = Array<UInt8>()
        let bits = storable.index.uuid
        bytes.append(bits.0)
        bytes.append(bits.1)
        bytes.append(bits.2)
        bytes.append(bits.3)
        bytes.append(bits.4)
        bytes.append(bits.5)
        bytes.append(bits.6)
        bytes.append(bits.7)
        bytes.append(bits.8)
        bytes.append(bits.9)
        bytes.append(bits.10)
        bytes.append(bits.11)
        bytes.append(bits.12)
        bytes.append(bits.13)
        bytes.append(bits.14)
        bytes.append(bits.15)
        self.buffer.append(contentsOf: bytes)
        }
    
    public func write<Item>(_ storable: Item) throws where Item: Storable, Item: RawRepresentable, Item.RawValue == Int
        {
        }
        

    
    }
