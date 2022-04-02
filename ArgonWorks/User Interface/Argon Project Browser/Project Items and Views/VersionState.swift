//
//  VersionState.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Cocoa

public enum VersionState: String
    {
    case none = ""
    case added = "a.square"
    case modified = "m.square"
    case deleted = "d.square"
    
    public var icon: NSImage?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .added:
                return(NSImage(systemSymbolName: self.rawValue, accessibilityDescription: self.rawValue))
            case .modified:
                return(NSImage(systemSymbolName: self.rawValue, accessibilityDescription: self.rawValue))
            case .deleted:
                return(NSImage(systemSymbolName: self.rawValue, accessibilityDescription: self.rawValue))
            }
        }
        
    public var isAddedState: Bool
        {
        switch(self)
            {
            case .added:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isModifiedState: Bool
        {
        switch(self)
            {
            case .modified:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isNoneState: Bool
        {
        switch(self)
            {
            case .none:
                return(true)
            default:
                return(false)
            }
        }
        
    public var iconTint: NSColor?
        {
        Palette.shared.color(for: .versionColor)
        }
    }
