//
//  SemanticRowView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/10/21.
//

import Foundation
import Cocoa

class SemanticRowView: NSTableRowView
    {
    override var isOpaque: Bool
        {
        get
            {
            return false
            }
        set
            {
            }
    }
    public override var isSelected: Bool
        {
        didSet
            {
//            if !self.isSelected,self.numberOfColumns > 0,let view = self.view(atColumn: 0),let cell = view as? LeaderSemanticCellView
//                {
//                cell.revertColors(selectionColor: self.selectionColor)
//                }
            if !self.isSelected,self.numberOfColumns > 0,let view = self.view(atColumn: 0),let cell = view as? MainSemanticCellView
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
        self.selectionHighlightStyle = .sourceList
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func drawBackground(in dirtyRect: NSRect)
        {
        if !self.isSelected
            {
            NSColor.clear.set()
            }
        else
            {
            self.selectionColor.set()
            }
        dirtyRect.fill()
        }
        
    public override func drawSelection(in dirtyRect: NSRect)
        {
        if self.selectionHighlightStyle != .none
            {
//            ((self.view(atColumn: 0)) as! LeaderSemanticCellView).invertColors(selectionColor: self.selectionColor)
            ((self.view(atColumn: 0)) as! MainSemanticCellView).invertColors(selectionColor: self.selectionColor)
            let selectionRect = self.bounds
            Palette.shared.hierarchySelectionColor.setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
            selectionPath.fill()
            }
        }
        
    public override func draw(_ rect:NSRect)
        {
//        super.draw(rect)
        if self.drawsLines
            {
            let size = self.bounds.size
            self.lineColor.set()
            let start = CGPoint(x:self.indent,y:0)
            let end = CGPoint(x:self.indent,y:size.height)
            NSBezierPath.defaultLineWidth = 3
            NSBezierPath.strokeLine(from: start, to: end)
            }
        if self.isSelected
            {
            self.drawSelection(in: rect)
            }
        }
    }
