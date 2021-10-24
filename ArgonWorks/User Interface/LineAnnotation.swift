//
//  LineCartouche.swift
//  Argon
//
//  Created by Vincent Coetzee on 2021/02/25.
//

import Cocoa

public class LineAnnotation
    {
    public var area:NSRect = .zero
    public let icon:NSImage
    public let line:Int
    
    init(line:Int,icon:NSImage)
        {
        self.line = line
        icon.isTemplate = true
        self.icon = icon.image(withTintColor: NSColor.controlAccentColor)
        self.icon.isTemplate = true
        }
    }
