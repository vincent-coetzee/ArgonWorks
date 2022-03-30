//
//  Location.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class LineAndLineNumber: LineNumber
    {
    public override var displayString: String
        {
        let string = self.lineNumber.displayString
        return("\(self.line).\(string)")
        }
        
    public let lineNumber: LineNumber
    
    public required init(coder: NSCoder)
        {
        self.lineNumber = coder.decodeObject(forKey: "lineNumber") as! LineNumber
        super.init(coder: coder)
        }
        
    init(line: Int,lineNumber: LineNumber)
        {
        self.lineNumber = lineNumber
        super.init(line: line)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.lineNumber,forKey: "lineNumber")
        super.encode(with: coder)
        }
        
    public override func suffixed(by: LineNumber) -> LineNumber
        {
        fatalError()
        }
    }

public class LineNumber: NSObject,NSCoding,Comparable
    {
    public static func <(lhs: LineNumber,rhs: LineNumber) -> Bool
        {
        if lhs.line < rhs.line
            {
            return(true)
            }
        else if lhs.line > rhs.line
            {
            return(false)
            }
        else
            {
            return(false)
            }
        }
        
    public var primaryLine: Int
        {
        return(self.line)
        }
        
    public override var hash:Int
        {
        return(self.displayString.polynomialRollingHash)
        }
        
    public var displayString: String
        {
        return("\(self.line)")
        }
        
    public let line: Int
    
    public required init(coder: NSCoder)
        {
        self.line = coder.decodeInteger(forKey: "line")
        }
        
    override init()
        {
        self.line = -1
        }
        
    init(line: Int)
        {
        self.line = line
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.line,forKey: "line")
        }
        
    public func suffixed(by: LineNumber) -> LineNumber
        {
        return(LineAndLineNumber(line: self.line, lineNumber: by))
        }
    }
    
public class EmptyLineNumber: LineNumber
    {
    public override var primaryLine: Int
        {
        return(0)
        }
        
    public override var hash: Int
        {
        return(0)
        }
        
    public override var displayString: String
        {
        return("")
        }
        
    public override func suffixed(by: LineNumber) -> LineNumber
        {
        return(by)
        }
    }
    
    
public struct Location:Equatable,CustomStringConvertible,Hashable
    {
    public var description: String
        {
        "Location(\(self.line),\(self.tokenStart),\(self.tokenStop),\(self.lineStart),\(self.lineStop))"
        }
        
    public static let zero = Location(line:0,lineStart:0,lineStop:0,tokenStart:0,tokenStop:0)
    
    public static let one = Location(line: 1,lineStart: 0,lineStop: 0,tokenStart: 0,tokenStop: 0)
    
    public var range: NSRange
        {
        let length = max(0,self.tokenStop - self.tokenStart)
        return(NSRange(location: self.tokenStart, length: length))
        }
        
    public var line: Int
    public let tokenStart: Int
    public let tokenStop: Int
    public let lineStart: Int
    public let lineStop: Int

    public init(line:Int,lineStart:Int,lineStop:Int,tokenStart:Int,tokenStop:Int)
        {
        self.line = line
        self.lineStart = lineStart
        self.lineStop = lineStop
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        }
    }

public typealias Locations = Array<Location>

public enum SourceLocation
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
    }
    
public typealias SourceLocations = Array<SourceLocation>

extension SourceLocations
    {        
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
