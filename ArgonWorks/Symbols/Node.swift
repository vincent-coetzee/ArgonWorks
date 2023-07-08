//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI
    
public class Node:NSObject,NSCoding
    {
    public private(set) var index: UUID
    public private(set) var label: String
    
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
        
    public required init(label: String)
        {
        self.index = UUID()
        self.label = label
        }
        
    required public init?(coder: NSCoder)
        {
        self.index = coder.decodeObject(forKey: "index") as! UUID
        self.label = coder.decodeObject(forKey: "label") as! Label
        self.locations = coder.decodeNodeLocations(forKey: "locations")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.index,forKey: "index")
        coder.encode(self.label,forKey: "label")
        coder.encodeNodeLocations(self.locations,forKey: "locations")
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
        
    public func setIndex(_ index:UUID)
        {
        self.index = index
        }
        
//    public static func ==(lhs:Node,rhs:Node) -> Bool
//        {
//        return(lhs.index == rhs.index)
//        }
    }
