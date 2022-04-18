//
//  PathControl.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/4/22.
//

import Cocoa

class PathControl: NSPathControl
    {
    public override func draw(_ rect: NSRect)
        {
        super.draw(rect)
        Palette.shared.color(for: .lineColor).set()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0,y: 1))
        path.line(to: NSPoint(x: self.bounds.size.width,y: 1))
        path.move(to: NSPoint(x: 0,y:self.bounds.size.height - 1))
        path.line(to:  NSPoint(x: self.bounds.size.width,y: self.bounds.size.height - 1))
        path.lineWidth = 1
        path.stroke()
        }
    }
