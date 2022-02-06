//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI
    
fileprivate var StandardUUIDIndex = 1
fileprivate var SystemUUIDIndex = 1

public class Node:NSObject,NSCoding
    {
    public private(set) var index = IdentityKey.nextKey()
    public private(set) var label: String
    public private(set) var cloneIndex: Int = 0
    
    private var locations = NodeLocations()
    
    public var declarationLocation: Location
        {
        get
            {
            locations.declarationLocation
            }
        set
            {
            locations.append(.declaration(newValue))
            }
        }

    public static func resetUUIDs()
        {
        SystemUUIDIndex = 1
        StandardUUIDIndex = 1
        }
        
    public static func systemUUID() -> UUID
        {
        let uuid = UUID(system:SystemUUIDIndex)
        SystemUUIDIndex += 1
        return(uuid)
        }
        
    public required init(label: String)
        {
        self.label = label
        }
        
    required public init?(coder: NSCoder)
        {
        self.index = coder.decodeObject(forKey: "index") as! IdentityKey
        self.label = coder.decodeObject(forKey: "label") as! Label
        self.locations = coder.decodeNodeLocations(forKey: "locations")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.index,forKey: "index")
        coder.encode(self.label,forKey: "label")
        coder.encodeNodeLocations(self.locations,forKey: "locations")
        }

    public func setCloneIndex(_ number:Int)
        {
        self.cloneIndex = number + 1
        }
        
    public func copy() -> Self
        {
        let copy = Self(label: self.label)
        copy.index = index
        return(copy)
        }
        
    public func setLabel(_ label: Label)
        {
        self.label = label
        }
        
    public func setIndex(_ index: IdentityKey)
        {
        self.index = index
        }
        
//    public static func ==(lhs:Node,rhs:Node) -> Bool
//        {
//        return(lhs.index == rhs.index)
//        }
    }
