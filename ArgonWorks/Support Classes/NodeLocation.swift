//
//  NodeLocation.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public enum NodeLocation
    {
    case declaration(Location)
    case reference(Location)
    
    public var isDeclaration: Bool
        {
        switch(self)
            {
            case .declaration:
                return(true)
            default:
                return(false)
            }
        }
        
    public var location: Location
        {
        switch(self)
            {
            case .declaration(let location):
                return(location)
            case .reference(let location):
                return(location)
            }
        }
    }

public typealias NodeLocations = Array<NodeLocation>

extension NodeLocations
    {
    public var declarationLocation: Location
        {
        for location in self
            {
            if location.isDeclaration
                {
                return(location.location)
                }
            }
        fatalError("No declaration location")
        }
    }
