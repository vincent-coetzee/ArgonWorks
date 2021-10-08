//
//  MainSemanticCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/10/21.
//

import Cocoa

class MainSemanticCellView: NSTableCellView
    {
    public var symbol: Symbol?

    public func revertColors(selectionColor: NSColor)
        {
        if let symbol = self.symbol
            {
            self.imageView?.contentTintColor = symbol.defaultColor
            self.textField?.textColor = .white
//        if let event = self.event
//            {
//            self.iconView.contentTintColor = event.tintColor
//            self.diagnosticView.textColor = event.tintColor
//            self.lineNumberView.textColor = NSColor.controlTextColor
//            }
            }
        }
        
    public func invertColors(selectionColor: NSColor)
        {
        self.imageView?.contentTintColor = .black
        self.textField?.textColor = .black
//        self.iconView.contentTintColor = NSColor.black
//        self.diagnosticView.textColor = NSColor.black
//        self.lineNumberView.textColor = NSColor.black
        }
        
    public override func draw(_ dirty: NSRect)
        {
            
//        super.draw(dirty)
        }
    }
