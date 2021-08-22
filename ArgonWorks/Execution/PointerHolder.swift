//
//  CachedPropertyWrapper.swift
//  CachedPropertyWrapper
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public protocol Addressable:Equatable
    {
    var isNil: Bool { get }
    var address: Word { get }
    init(address: Word)
    }
    
public class PointerHolder<P,S> where P:Addressable,S:InnerPointer
    {
    public var isNil: Bool
        {
        return(substrate.slotValue(atKey: self.name) == 0)
        }
        
    public var isNotNil: Bool
        {
        return(substrate.slotValue(atKey: self.name) != 0)
        }
        
    public var pointer: P
        {
        get
            {
            if self.cachedValue.isNil
                {
                let address = substrate.slotValue(atKey: self.name)
                self.cachedValue = P(address: address)
                }
            return(self.cachedValue!)
            }
        set
            {
            if self.cachedValue != newValue
                {
                self.cachedValue = newValue
                self.substrate.setSlotValue(newValue.address,atKey: self.name)
                }
            }
        }
        
    private var substrate: S!
    private let name: String
    private var cachedValue: P?
    
    init(name:String)
        {
        self.name = name
        }
        
    public func setSubstrate(_ substrate:S)
        {
        self.substrate = substrate
        }
    }
