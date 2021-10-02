//
//  CompilationEvent.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/10/21.
//

import AppKit
    
internal enum CompilationEvent
    {
    case none
    case warning(Location,String)
    case error(Location,String)
    
    public var selectionColor: NSColor
        {
        switch(self)
            {
            case .none:
                return(NSColor.clear)
            case .warning:
                return(Palette.shared.compilationEventWarningSelectionColor)
            case .error:
                return(Palette.shared.compilationEventErrorSelectionColor)
            }
        }
        
    public var lineNumber: Int?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .warning(let location,_):
                return(location.line)
            case .error(let location,_):
                return(location.line)
            }
        }
        
    public var tintColor: NSColor
        {
        switch(self)
            {
            case .none:
                return(NSColor.white)
            case .warning:
                return(Palette.shared.compilationEventWarningColor)
            case .error:
                return(Palette.shared.compilationEventErrorColor)
            }
        }
        
    public var icon: NSImage
        {
        return(NSImage(named: self.iconName)!)
        }
        
    public var iconName: String
        {
        switch(self)
            {
            case .none:
                return("ImageEmpty")
            case .warning:
                return("IconWarning")
            case .error:
                return("IconError")
            }
        }
    }
