//
//  HierarchyRowView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Cocoa

class HierarchyRowView: NSTableRowView
    {
    public var selectionColor: NSColor?
    public var indent:CGFloat = 0
    public var drawsLines = false
    public var lineColor = NSColor.white
    private let symbol: HierarchySymbolWrapper?
    
    init(symbol: HierarchySymbolWrapper)
        {
        self.symbol = symbol
        selectionColor = nil
        super.init(frame: .zero)
        }
    
    init(selectionColor: NSColor)
        {
        self.selectionColor = selectionColor
        self.symbol = nil
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
            if symbol.isNil
                {
                self.selectionColor!.setFill()
                }
            else
                {
//                self.symbol!.selectionColor.setFill()
                Palette.shared.hierarchySelectionColor.setFill()
                }
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
