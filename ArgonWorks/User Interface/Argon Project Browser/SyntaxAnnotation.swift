//
//  SyntaxAnnotation.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/3/22.
//

import Cocoa

public class SyntaxAnnotation
    {
    public let issue: CompilerIssue
    public let icon: NSImage
    public var frame: NSRect
    private var _layer: CALayer?
    
    public var annotationLayer: CALayer
        {
        if self._layer.isNotNil
            {
            return(self._layer!)
            }
        let layer = CALayer()
        layer.contents = self.icon
        self._layer = layer
        return(layer)
        }
        
    init(issue: CompilerIssue,frame: NSRect)
        {
        self.issue = issue
        self.frame = frame
        let name = issue.isWarning ? "exclamationmark.triangle" : "exclamationmark.circle"
        let color = issue.isWarning ? NSColor.argonBrightYellowCrayola : NSColor.argonNeonPink
        self.icon = NSImage(systemSymbolName: name, accessibilityDescription: "")!.image(withTintColor: color)
        }
    }
