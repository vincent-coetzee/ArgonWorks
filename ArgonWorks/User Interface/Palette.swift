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
    public let headerColor = NSColor.argonHeaderGray
    public let headerTextColor = NSColor.argonStoneTerrace
    public let headerHeight:CGFloat = 24
    public let headerFont = NSFont(name: "SF Pro Bold",size: 14)
    public let objectBrowserTextColor = NSColor.argonSalmonPink
    public let classBrowserTextColor = NSColor.argonCoral
    public let methodBrowserTextColor = NSColor.argonStoneTerrace
    public let hierarchyBrowserSystemClassColor = NSColor.argonSalmonPink
    }
