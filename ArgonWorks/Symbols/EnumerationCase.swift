//
//  EnumerationCase.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class EnumerationCase:Symbol
    {
    public static func ==(lhs: EnumerationCase,rhs: EnumerationCase) -> Bool
        {
        lhs.caseIndex == rhs.caseIndex && lhs.enumeration.index == rhs.enumeration.index && lhs.associatedTypes == rhs.associatedTypes
        }
        
    public override var displayString: String
        {
        "Case(\(self.symbol))"
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var argonHash: Int
        {
        var hashValue = super.argonHash
        for slot in self.associatedTypes
            {
            hashValue = hashValue << 13 ^ slot.argonHash
            }
        hashValue = hashValue << 13 ^ self.symbol.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.caseIndex
        return(hashValue)
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
        
    public override var instanceSizeInBytes: Int
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
        let type = self.container.argonModule.enumerationCase
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
    public var symbolIndex: Int = 0
    
    public func clone() -> Self
        {
        let copy = Self(label: self.label)
        copy.setIndex(self.index)
        copy.associatedTypes = self.associatedTypes
        copy.symbol = self.symbol
        copy.rawValue = self.rawValue
        copy.enumeration = self.enumeration
        copy.caseIndex = self.caseIndex
        copy.symbolIndex = self.symbolIndex
        return(copy)
        }
        
    public func isEquivalent(_ rightCase: EnumerationCase) -> Bool
        {
        if self.caseIndex != rightCase.caseIndex
            {
            return(false)
            }
        if self.symbol != rightCase.symbol
            {
            return(false)
            }
        if self.associatedTypes.count != rightCase.associatedTypes.count
                {
                return(false)
                }
        for (left,right) in zip(self.associatedTypes,rightCase.associatedTypes)
            {
            if !left.isEquivalent(right)
                {
                return(false)
                }
            }
        return(true)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? EnumerationCase
            {
            return(self.symbol == second.symbol && self.caseIndex == second.caseIndex && self.associatedTypes == second.associatedTypes && self.enumeration.index == second.enumeration.index)
            }
        return(super.isEqual(object))
        }
        
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
        
   public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let enumCaseType = self.container.argonModule.enumerationCase
        let enumCasePointer = ClassBasedPointer(address: self.memoryAddress,type: enumCaseType,argonModule: self.container.argonModule)
        enumCasePointer.setClass(enumCaseType)
        self.symbolIndex = allocator.payload.symbolRegistry.registerSymbol(self.symbol)
        enumCasePointer.setInteger(self.symbolIndex,atSlot: "symbol")
        enumCasePointer.setInteger(self.caseIndex,atSlot: "index")
        if self.associatedTypes.isEmpty
            {
            enumCasePointer.setAddress(nil,atSlot: "associatedTypes")
            }
        else
            {
            if let arrayPointer = ArrayPointer(dirtyAddress: segment.allocateArray(size: self.associatedTypes.count),argonModule: segment.argonModule)
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
        
//    public override func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
//        {
//        super.configure(cell: cell)
//        if associatedTypes.count > 0
//            {
//            let names = associatedTypes.map{$0.label}.joined(separator: ",")
//            cell.trailer.stringValue = "(\(names))"
//            }
//        }
        
    private func calculateSizeInBytes()
        {
//        let size = TopModule.shared.argonModule.enumerationCase.localAndInheritedSlots.count * MemoryLayout<Word>.size
//        let typesSize = self.associatedTypes.count * MemoryLayout<Word>.size
//        self.caseSizeInBytes = size + typesSize + MemoryLayout<Word>.size * 4
        }
    }
    
public typealias EnumerationCases = Array<EnumerationCase>
