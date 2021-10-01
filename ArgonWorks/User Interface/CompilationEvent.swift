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
        return(Palette.shared.compilationEventSelectionColor)
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
