//
//  T3ALabel.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3ALabel: NSObject,NSCoding
    {
    public var displayString: String
        {
        String(format: "L%05d",self.index)
        }
        
    private static var nextIndex = 1
    
    internal let index: Int
    
    override init()
        {
        let index = Self.nextIndex
        Self.nextIndex += 1
        self.index = index
        }
        
    public required init(coder: NSCoder)
        {
        self.index = coder.decodeInteger(forKey: "index")
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.index,forKey: "index")
        }
    }
