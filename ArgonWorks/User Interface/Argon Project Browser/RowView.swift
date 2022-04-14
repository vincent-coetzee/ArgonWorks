//
//  RowView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/2/22.
//

import Cocoa

public class RowView:NSTableRowView
    {
    private let selectionColorIdentifier: StyleColorIdentifier
    public var indent:CGFloat = 0
    public var drawsLines = false
    public var lineColorIdentifier: StyleColorIdentifier = .lineColor
    
    init(selectionColorIdentifier: StyleColorIdentifier)
        {
        self.selectionColorIdentifier = selectionColorIdentifier
        super.init(frame: .zero)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawSelection(in dirtyRect: NSRect)
        {
        if self.selectionHighlightStyle != .none
            {
            let selectionRect = self.bounds
            Palette.shared.color(for: self.selectionColorIdentifier).setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
            selectionPath.fill()
            }
        }
        
    public override func draw(_ rect:NSRect)
        {
        super.draw(rect)
        if self.drawsLines
            {
            let size = self.bounds.size
            Palette.shared.color(for: self.lineColorIdentifier).set()
            let start = CGPoint(x:self.indent,y:0)
            let end = CGPoint(x:self.indent,y:size.height)
            NSBezierPath.defaultLineWidth = 3
            NSBezierPath.strokeLine(from: start, to: end)
            }
        }
    }
