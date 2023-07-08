//
//  EnumerationCase.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class EnumerationCase:Symbol
    {
    public override var argonHash: Int
        {
        var hashValue = super.argonHash
        for slot in self.associatedTypes
            {
            hashValue = hashValue << 13 ^ slot.argonHash
            }
        hashValue = hashValue << 13 ^ self.symbol.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.caseIndex
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        LiteralExpression(.enumerationCase(self))
        }
        
    public override var isEnumerationCase: Bool
        {
        return(true)
        }
        
    public var hasAssociatedValues: Bool
        {
        return(!self.associatedTypes.isEmpty)
        }
        
    public override var type: Type!
        {
        get
            {
            return(self.enumeration)
            }
        set
            {
            }
        }
        
    public var instanceSizeInBytes: Int
        {
        ///
        /// 1 word for the instance + 1 word for every associated value
        ///
        Argon.kWordSizeInBytesInt + self.associatedTypes.count * Argon.kWordSizeInBytesInt
        }
        
    public override var iconName: String
        {
        return("IconSlot")
        }
        
    public override var sizeInBytes: Int
        {
        let type = ArgonModule.shared.enumerationCase
        return(type.instanceSizeInBytes)
        }
        
    public override var typeCode:TypeCode
        {
        .enumerationCase
        }
        
    public var associatedTypes: Types
    public var symbol: Argon.Symbol
    public var rawValue: LiteralExpression?
    public var caseSizeInBytes:Int = 0
    public weak var enumeration: TypeEnumeration!
    public var caseIndex = -1
    public var symbolMemoryAddress: Address = 0
    
    init(symbol: Argon.Symbol,types: Types,enumeration: TypeEnumeration)
        {
        self.enumeration = enumeration
        self.symbol = symbol
        self.associatedTypes = types
        super.init(label: symbol)
        self.calculateSizeInBytes()
        }
    
    public required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as? TypeEnumeration
        self.symbol = coder.decodeObject(forKey: "symbol") as! Argon.Symbol
        self.rawValue = coder.decodeObject(forKey: "rawValue") as? LiteralExpression
        self.caseIndex = coder.decodeInteger(forKey: "caseIndex")
        self.associatedTypes = coder.decodeObject(forKey: "associatedTypes") as! Types
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        self.associatedTypes = Types()
        self.symbol = ""
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.enumeration,forKey: "enumeration")
        coder.encode(self.symbol,forKey: "symbol")
        coder.encode(self.rawValue,forKey: "rawValue")
        coder.encode(self.associatedTypes,forKey: "associatedTypes")
        coder.encode(self.caseIndex,forKey: "caseIndex")
        super.encode(with: coder)
        }
        
   public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        self.symbolMemoryAddress = allocator.registerSymbol(self.symbol)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let enumCaseType = ArgonModule.shared.enumerationCase
        let enumCasePointer = ClassBasedPointer(address: self.memoryAddress,type: enumCaseType)
        enumCasePointer.setClass(enumCaseType)
        let symbolAddress = allocator.payload.symbolRegistry.registerSymbol(self.symbol)
        enumCasePointer.setAddress(symbolAddress,atSlot: "symbol")
        enumCasePointer.setInteger(self.caseIndex,atSlot: "index")
        if self.associatedTypes.isEmpty
            {
            enumCasePointer.setAddress(0,atSlot: "associatedTypes")
            }
        else
            {
            if let arrayPointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.associatedTypes.count))
                {
                for type in self.associatedTypes
                    {
                    type.layoutInMemory(using: allocator)
                    arrayPointer.append(type.memoryAddress)
                    }
                enumCasePointer.setAddress(arrayPointer.cleanAddress,atSlot: "associatedTypes")
                }
            }
        enumCasePointer.setAddress(self.enumeration.memoryAddress,atSlot: "enumeration")
        }
    
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = super.substitute(from: substitution)
        copy.associatedTypes = self.associatedTypes.map{substitution.substitute($0)}
        copy.symbol = self.symbol
        copy.rawValue = self.rawValue.isNil ? nil : (substitution.substitute(self.rawValue!) as! LiteralExpression)
        return(copy)
        }
        
    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        super.configure(cell: cell)
        if associatedTypes.count > 0
            {
            let names = associatedTypes.map{$0.label}.joined(separator: ",")
            cell.trailer.stringValue = "(\(names))"
            }
        }
        
    private func calculateSizeInBytes()
        {
//        let size = TopModule.shared.argonModule.enumerationCase.localAndInheritedSlots.count * MemoryLayout<Word>.size
//        let typesSize = self.associatedTypes.count * MemoryLayout<Word>.size
//        self.caseSizeInBytes = size + typesSize + MemoryLayout<Word>.size * 4
        }
    }
    
public typealias EnumerationCases = Array<EnumerationCase>
