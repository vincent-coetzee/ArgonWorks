//
//  CompilationEvent.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/10/21.
//

import AppKit
    
internal class CompilationEvent
    {
    public let location: Location
    public let diagnostic: String
    
    public var isGroup: Bool
        {
        return(false)
        }
        
    public var tokenStartOffset: Int
        {
        return(self.location.tokenStart - self.location.lineStart)
        }
        
    public var tokenStopOffset: Int
        {
        return(self.location.tokenStop - self.location.lineStart)
        }

    public var line: Int
        {
        return(self.location.line)
        }
        
    public var selectionColor: NSColor
        {
        NSColor.white
        }
        
    public var tintColor: NSColor
        {
        return(NSColor.white)
        }
        
    public var icon: NSImage
        {
        return(NSImage(systemSymbolName: "triangle", accessibilityDescription: "warning triangle")!)
        }
        
    public var childCount: Int
        {
        return(0)
        }
        
    public func child(atIndex: Int) -> CompilationEvent
        {
        fatalError()
        }
        
    public var isExpandable: Bool
        {
        return(false)
        }
        
    internal init(location: Location,message: String)
        {
        self.location = location
        self.diagnostic = message
        }
    }

internal class CompilationWarningEvent: CompilationEvent
    {
    public override var tintColor: NSColor
        {
        return(Palette.shared.argonPrimaryColor)
        }
        
    public override var selectionColor: NSColor
        {
        return(Palette.shared.compilationEventWarningSelectionColor)
        }
        
    public override var icon: NSImage
        {
        return(NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "warning triangle")!)
        }
    }

internal class CompilationErrorEvent: CompilationEvent
    {
    public override var icon: NSImage
        {
        return(NSImage(systemSymbolName: "exclamationmark.octagon", accessibilityDescription: "error octogon")!)
        }
        
    public override var tintColor: NSColor
        {
        return(Palette.shared.argonPrimaryColor)
        }
        
    public override var selectionColor: NSColor
        {
        return(Palette.shared.compilationEventErrorSelectionColor)
        }
    }

internal class CompilationEventGroup: CompilationEvent
    {
    private var events: Array<CompilationEvent> = []
    internal var isWarning = false
    
    public override var selectionColor: NSColor
        {
        Palette.shared.hierarchySelectionColor
        }
        
    public override var icon: NSImage
        {
        return(NSImage(systemSymbolName: "exclamationmark.square", accessibilityDescription: "warning square")!)
        }
        
    public override var isGroup: Bool
        {
        return(true)
        }
        
    public override var tintColor: NSColor
        {
        Palette.shared.hierarchySelectionColor
        }
        
    public override var childCount: Int
        {
        return(self.events.count)
        }
        
    public override func child(atIndex: Int) -> CompilationEvent
        {
        let children = self.events.sorted{$0.line < $1.line}
        return(children[atIndex])
        }
        
    public override var isExpandable: Bool
        {
        return(self.events.count > 0)
        }
        
    public func addEvent(_ event:CompilationEvent)
        {
        self.events.append(event)
        }
    }
