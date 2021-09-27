//
//  Location.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public struct Location
    {
    public static let zero = Location(line:0,lineStart:0,lineStop:0,tokenStart:0,tokenStop:0)
    
    public var range: NSRange
        {
        NSRange(location: self.tokenStart, length: self.tokenStop - self.tokenStart)
        }
        
    public let line:Int
    public let tokenStart:Int
    public let tokenStop:Int
    public let lineStart:Int
    public let lineStop:Int
    
    init(coder:NSCoder)
        {
        self.line = coder.decodeInteger(forKey:"line")
        self.lineStart = coder.decodeInteger(forKey:"lineStart")
        self.lineStop = coder.decodeInteger(forKey:"lineStop")
        self.tokenStart = coder.decodeInteger(forKey:"tokenStart")
        self.tokenStop = coder.decodeInteger(forKey:"tokenStop")
        }
        
    public init(line:Int,lineStart:Int,lineStop:Int,tokenStart:Int,tokenStop:Int)
        {
        self.line = line
        self.lineStart = lineStart
        self.lineStop = lineStop
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.line,forKey: "line")
        coder.encode(self.lineStart,forKey: "lineStart")
        coder.encode(self.lineStop,forKey: "lineStop")
        coder.encode(self.tokenStart,forKey: "tokenStart")
        coder.encode(self.tokenStop,forKey: "tokenStop")
        }
    }

public typealias Locations = Array<Location>

public enum SourceLocation
    {
    case declaration(Location)
    case reference(Location)
    
    init(coder:NSCoder)
        {
        let kind = coder.decodeInteger(forKey: "kind")
        if kind == 1
            {
            let location = Location(coder: coder)
            self = .declaration(location)
            }
        else
            {
            let location = Location(coder: coder)
            self = .reference(location)
            }
        }
        
    public func encode(with coder:NSCoder)
        {
        switch(self)
            {
            case .declaration(let location):
                coder.encode(1,forKey:"kind")
                coder.encode(location)
            case .reference(let location):
                coder.encode(2,forKey:"kind")
                coder.encode(location)
            }
        }
        
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
    }
    
public typealias SourceLocations = Array<SourceLocation>

extension SourceLocations
    {
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.count,forKey: "count")
        for location in self
            {
            location.encode(with: coder)
            }
        }
        
    public var declaration: Location?
        {
        for location in self
            {
            switch(location)
                {
                case .declaration(let position):
                    return(position)
                default:
                    break;
                }
            }
        return(nil)
        }
    }
