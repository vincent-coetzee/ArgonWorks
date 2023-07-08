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
    private var icon: NSImage
    public var image:NSImage
        {
        get
            {
            return(icon)
            }
        set
            {
            self.icon.isTemplate = true
            self.icon = newValue.image(withTintColor: self.tintColor)
            }
        }
        
    public let line:Int
    public let tintColor: NSColor
    public var issueLayer: CompilerIssueMessageLayer?
    
    init(line:Int,symbolName:String,tintColor:NSColor = NSColor.controlAccentColor)
        {
        self.tintColor = tintColor
        self.line = line
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "")!
        self.icon = image.image(withTintColor: self.tintColor)
        self.icon.isTemplate = true
        }
    }
