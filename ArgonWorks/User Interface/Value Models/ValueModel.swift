//
//  ValueModel.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Cocoa

public protocol ValueModel: Model
    {
    var value: Any? { get set }
    }
    
extension ValueModel
    {
    public var stringValue: String?
        {
        self.value as? String
        }
        
    public var imageValue: NSImage?
        {
        self.value as? NSImage
        }
        
    public var colorValue: NSColor?
        {
        self.value as? NSColor
        }
    }
