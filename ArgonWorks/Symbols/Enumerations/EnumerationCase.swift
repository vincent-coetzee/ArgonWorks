//
//  EnumerationCase.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit

public class EnumerationCase:Symbol
    {
    public override var asLiteralExpression: LiteralExpression?
        {
        LiteralExpression(.enumerationCase(self))
        }
        
    public override var isEnumerationCase: Bool
        {
        return(true)
        }
        
    public var hasAssociatedTypes: Bool
        {
        return(!self.associatedTypes.isEmpty)
        }
        
    public override var type: Type?
        {
        get
            {
            return(self.enumeration.type)
            }
        set
            {
            }
        }
        
    public override var iconName: String
        {
        return("IconSlot")
        }
        
    public override var typeCode:TypeCode
        {
        .enumerationCase
        }
        
    public var associatedTypes: Types
    public var symbol: Argon.Symbol
    public var rawValue: LiteralExpression?
    public var caseSizeInBytes:Int = 0
    public weak var enumeration: Enumeration!
    
    init(symbol: Argon.Symbol,types: Types,enumeration: Enumeration)
        {
        self.enumeration = enumeration
        self.symbol = symbol
        self.associatedTypes = types
        super.init(label: symbol)
        self.calculateSizeInBytes()
        }
    
    public required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as? Enumeration
        self.symbol = coder.decodeObject(forKey: "symbol") as! Argon.Symbol
        self.rawValue = coder.decodeObject(forKey: "rawValue") as? LiteralExpression
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
        super.encode(with: coder)
        coder.encode(self.enumeration,forKey: "enumeration")
        coder.encode(self.symbol,forKey: "symbol")
        coder.encode(self.rawValue,forKey: "rawValue")
        coder.encode(self.associatedTypes,forKey: "associatedTypes")
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
