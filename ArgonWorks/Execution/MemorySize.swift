//
//  MemorySize.swift
//  MemorySize
//
//  Created by Vincent Coetzee on 14/8/21.
//

import Foundation

public indirect enum MemorySize
    {
    public static func megabytes(_ value:Int) -> MemorySize
        {
        MemorySize.megabytes(value,.bytes(0))
        }
        
    public static func *(lhs:MemorySize,rhs:Int) -> MemorySize
        {
        return(.bytes(lhs.inBytes * rhs))
        }
        
    public static func /(lhs:MemorySize,rhs:Int) -> MemorySize
        {
        return(.bytes(lhs.inBytes / rhs))
        }
        
    public enum Units
        {
        internal static let kBytesPerKilobyte = 1024
        internal static let kBytesPerMegabyte = 1024 * 1024
        internal static let kBytesPerGigabyte = 1024 * 1024 * 1024
        
        case bytes
        case kilobytes
        case megabytes
        case gigabytes
        }
        
    case bytes(Int)
    case kilobytes(Int,MemorySize)
    case megabytes(Int,MemorySize)
    case gigabytes(Int,MemorySize)
    
    public init(megabytes: Int)
        {
        self = .megabytes(megabytes,.bytes(0))
        }
        
    public var displayString: String
        {
        switch(self)
            {
            case .bytes(let bytes):
                return("\(bytes) B")
            case .kilobytes(let kb,let rest):
                return("\(kb) KB \(rest.displayString)")
            case .megabytes(let meg,let rest):
                return("\(meg) MB \(rest.displayString)")
            case .gigabytes(let gig,let rest):
                return("\(gig) GB \(rest.displayString)")
            }
        }
        
    public var units: Units
        {
        switch(self)
            {
            case .bytes:
                return(.bytes)
            case .kilobytes:
                return(.kilobytes)
            case .megabytes:
                return(.megabytes)
            case .gigabytes:
                return(.gigabytes)
            }
        }
        
    public var inBytes: Int
        {
        switch(self)
            {
            case .bytes(let bytes):
                return(bytes)
            case .kilobytes(let kb,let bytes):
                return(kb * Units.kBytesPerKilobyte + bytes.inBytes)
            case .megabytes(let meg,let kb):
                return(meg * Units.kBytesPerMegabyte + kb.inBytes)
            case .gigabytes(let gig,let meg):
                return(gig * Units.kBytesPerGigabyte + meg.inBytes)
            }
        }
        
    public var primaryUnit:Int
        {
        switch(self)
            {
            case .bytes(let bytes):
                return(bytes)
            case .kilobytes(let kb,_):
                return(kb)
            case .megabytes(let meg,_):
                return(meg)
            case .gigabytes(let gig,_):
                return(gig)
            }
        }
        
    public func convertToHighestUnit() -> MemorySize
        {
        var top = self.convert(toUnits: .gigabytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        top = self.convert(toUnits: .megabytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        top = self.convert(toUnits: .kilobytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        return(self.convert(toUnits: .megabytes))
        }
        
    public func size(inUnits:Units) -> MemorySize
        {
        if self.units == inUnits
            {
            return(self)
            }
        return(self.convert(toUnits: inUnits))
        }
        
    private func convert(toUnits: Units) -> Self
        {
        switch(self)
            {
            case .bytes(let amount):
                if toUnits == .kilobytes
                    {
                    let unit = amount / Units.kBytesPerKilobyte
                    let remainder = amount - unit*Units.kBytesPerKilobyte
                    return(.kilobytes(unit,.bytes(remainder)))
                    }
                else if toUnits == .megabytes
                    {
                    let meg = amount / Units.kBytesPerMegabyte
                    let remainder = amount - meg * Units.kBytesPerMegabyte
                    let kb = remainder / Units.kBytesPerKilobyte
                    let bytes = remainder - kb * Units.kBytesPerKilobyte
                    return(.megabytes(meg,.kilobytes(kb,.bytes(bytes))))
                    }
                else if toUnits == .gigabytes
                    {
                    let gig = amount / Units.kBytesPerGigabyte
                    let remainder = amount - gig  * Units.kBytesPerGigabyte
                    let meg = remainder / Units.kBytesPerMegabyte
                    let remainder1 = remainder - meg * Units.kBytesPerMegabyte
                    let kb = remainder1 / Units.kBytesPerKilobyte
                    let bytes = remainder1 - kb * Units.kBytesPerKilobyte
                    return(.gigabytes(gig,.megabytes(meg,.kilobytes(kb,.bytes(bytes)))))
                    }
            case .kilobytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            case .megabytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            case .gigabytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            }
        return(self)
        }
    }
