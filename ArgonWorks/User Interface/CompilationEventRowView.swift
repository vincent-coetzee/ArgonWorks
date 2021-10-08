//
//  CompilationEventRowView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/10/21.
//

import Cocoa

class CompilationEventRowView: NSTableRowView
    {
    public override var isSelected: Bool
        {
        didSet
            {
            if !self.isSelected,self.numberOfColumns > 0,let view = self.view(atColumn: 0),let cell = view as? CompilationEventCell
                {
                cell.revertColors(selectionColor: self.selectionColor)
                }
            }
        }
        
    public let selectionColor: NSColor
    public var indent:CGFloat = 0
    public var drawsLines = false
    public var lineColor = NSColor.white
    
    init(selectionColor: NSColor)
        {
        self.selectionColor = selectionColor
        super.init(frame: .zero)
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawBackground(in dirtyRect: NSRect)
        {
        if !isSelected
            {
            ((self.view(atColumn: 0)) as! CompilationEventCell).revertColors(selectionColor: self.selectionColor)
            }
        }
        
    public override func drawSelection(in dirtyRect: NSRect)
        {
        if self.selectionHighlightStyle != .none
            {
            ((self.view(atColumn: 0)) as! CompilationEventCell).invertColors(selectionColor: self.selectionColor)
            let selectionRect = self.bounds
            Palette.shared.hierarchySelectionColor.setFill()
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
            self.lineColor.set()
            let start = CGPoint(x:self.indent,y:0)
            let end = CGPoint(x:self.indent,y:size.height)
            NSBezierPath.defaultLineWidth = 3
            NSBezierPath.strokeLine(from: start, to: end)
            }
        }
    }
