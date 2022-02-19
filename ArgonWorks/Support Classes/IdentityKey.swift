//
//  IdentityKey.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

fileprivate var NextKey = IdentityKey(major: 0,minor: 0)

public class IdentityKey: NSObject,NSCoding,Comparable,StringConvertible
    {
    public override var hash: Int
        {
        self.majorKey << 13 ^ self.minorKey
        }
        
    public var stringValue: String
        {
        self.description
        }
        
    public static func nextKey() -> IdentityKey
        {
        let newKey = NextKey.keyByIncrementingMajor()
        NextKey = newKey
        return(newKey)
        }
        
    public static func <(lhs:IdentityKey,rhs:IdentityKey) -> Bool
        {
        lhs.majorKey < rhs.majorKey ||  (lhs.majorKey == rhs.majorKey && lhs.minorKey < rhs.minorKey)
        }
        
    public static func ==(lhs:IdentityKey,rhs:IdentityKey) -> Bool
        {
        lhs.isEqual(rhs)
        }
        
    public override var description: String
        {
        "Identity(\(self.majorKey),\(self.minorKey))"
        }
        
    private let majorKey: Int
    private let minorKey: Int
    
    init(major: Int,minor: Int)
        {
        self.majorKey = major
        self.minorKey = minor
        }
        
    public required init?(coder: NSCoder)
        {
        self.majorKey = coder.decodeInteger(forKey: "major")
        self.minorKey = coder.decodeInteger(forKey: "minor")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.majorKey,forKey: "major")
        coder.encode(self.minorKey,forKey: "minor")
        }
        
    public func keyByIncrementingMajor() -> IdentityKey
        {
        IdentityKey(major: self.majorKey + 1,minor: self.minorKey)
        }
        
    public func keyByIncrementingMinor() -> IdentityKey
        {
        IdentityKey(major: self.majorKey,minor: self.minorKey + 1)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let otherKey = object as? IdentityKey
            {
            return(self.majorKey == otherKey.majorKey && self.minorKey == otherKey.minorKey)
            }
        return(false)
        }
    }
