//
//  Palette.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/9/21.
//

import AppKit

public struct Palette
    {
    public static let shared = Palette()
    
    private init()
        {
        }
        
    public let primaryHighlightColor = NSColor.controlAccentColor
    public let textInset = CGSize(width: 10,height: 10)
    public var headerColor:NSColor
        {
        self.primaryHighlightColor
        }
    public let headerTextColor = NSColor.argonXGray
    public let headerHeight:CGFloat = 30
    public let headerFont = NSFont(name: "SF Pro Bold",size: 14)
    }
