//
//  Attribute.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class TextAttribute: NSObject,NSCoding
    {
    let color: NSColor
    let range: NSRange
    
    init(color:NSColor,range:NSRange)
        {
        self.color = color
        self.range = range
        }
        
    public required init?(coder: NSCoder)
        {
        self.color = coder.decodeObject(forKey: "color") as! NSColor
        self.range = NSRange(location: coder.decodeInteger(forKey: "location"),length: coder.decodeInteger(forKey: "length"))
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.color,forKey: "color")
        coder.encode(self.range.location,forKey: "location")
        coder.encode(self.range.length,forKey: "length")
        }
    }
    
public typealias Attributes = Array<TextAttribute>
