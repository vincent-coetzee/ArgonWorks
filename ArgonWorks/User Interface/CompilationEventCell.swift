//
//  CompilationEventCell.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/10/21.
//

import Cocoa

class CompilationEventCell: NSTableCellView
    {
    public var event: CompilationEvent?
        {
        didSet
            {
            if let event = self.event
                {
                self.update(from: event)
                }
            }
        }
        
    @IBOutlet var iconView: NSImageView!
    @IBOutlet var lineNumberView: NSTextField!
    @IBOutlet var diagnosticView: NSTextField!
    
    private func update(from event: CompilationEvent)
        {
        let configuration = NSImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let image = event.icon.withSymbolConfiguration(configuration)
        self.iconView.image = image
        self.iconView.image?.isTemplate = true
        self.iconView.contentTintColor = event.tintColor
        self.lineNumberView.stringValue = "Line \(event.line.displayString) Column \(event.tokenStartOffset) :: \(event.tokenStopOffset)"
        self.diagnosticView.stringValue = event.diagnostic
        self.diagnosticView.textColor = event.tintColor
        }
        
    public func revertColors(selectionColor: NSColor)
        {
        if let event = self.event
            {
            self.iconView.contentTintColor = event.tintColor
            self.diagnosticView.textColor = event.tintColor
            self.lineNumberView.textColor = NSColor.controlTextColor
            }
        }
        
    public func invertColors(selectionColor: NSColor)
        {
        self.iconView.contentTintColor = NSColor.black
        self.diagnosticView.textColor = NSColor.black
        self.lineNumberView.textColor = NSColor.black
        }
    }
