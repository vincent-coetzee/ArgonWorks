//
//  EnumerationCase.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class EnumerationCase:Symbol
    {
    public override var type: Type
        {
        return(self.enumeration.type)
        }
        
    public override var typeCode:TypeCode
        {
        .enumerationCase
        }
        
    public let associatedTypes: Types
    public let symbol: Argon.Symbol
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
        
    private func calculateSizeInBytes()
        {
        let size = self.enumeration.topModule.argonModule.enumerationCase.localAndInheritedSlots.count * MemoryLayout<Word>.size
        let typesSize = self.associatedTypes.count * MemoryLayout<Word>.size
        self.caseSizeInBytes = size + typesSize + MemoryLayout<Word>.size * 4
        }
    }
    
public typealias EnumerationCases = Array<EnumerationCase>
