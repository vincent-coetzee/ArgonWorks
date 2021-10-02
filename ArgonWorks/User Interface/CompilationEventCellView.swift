//
//  CompilationEventCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import Cocoa

class CompilationEventCellView: NSTableCellView
    {
    public var event: CompilationEvent = .none
        {
        didSet
            {
            switch(self.event)
                {
                case .none:
                    break
                case .warning(let location,let text):
                    let start = location.tokenStart - location.lineStart
                    let stop = location.tokenStop - location.lineStart
                    let line = String(format: "%d",location.line)
                    self.lineNumberView.stringValue = "Line \(line) from \(start) to \(stop)"
//                    self.lineNumberView.font = NSFont(name: "SFMono-Regular",size: 11)!
                    self.detailView.stringValue = "Warning: \(text)"
                case .error(let location,let text):
                    let start = location.tokenStart - location.lineStart
                    let stop = location.tokenStop - location.lineStart
                    let line = String(format: "%d",location.line)
                    self.lineNumberView.stringValue = "Line \(line) from \(start) to \(stop)"
//                    self.lineNumberView.font = NSFont(name: "SFMono-Regular",size: 11)!
                    self.detailView.stringValue = "Error: \(text)"
                }
            }
        }
        
    public var lineNumber: Int = 0
        {
        didSet
            {
            self.lineNumberView.stringValue = "\(self.lineNumber)"
            }
        }
        
    public var detail: String = ""
        {
        didSet
            {
            self.detailView.stringValue = detail
            }
        }
        
    @IBOutlet var iconView: NSImageView!
    @IBOutlet var lineNumberView: NSTextField!
    @IBOutlet var detailView: NSTextField!
    
    public func makeHighlighted()
        {
        self.lineNumberView.textColor = Palette.shared.compilationSelectedTextColor
        self.detailView.textColor = Palette.shared.compilationSelectedTextColor
        }
        
    public func makeUnhighlighted()
        {
        switch(self.event)
            {
            case .warning:
                self.detailView.textColor = Palette.shared.compilationEventTextColor
                self.lineNumberView.textColor = Palette.shared.compilationEventTextColor
            case .error:
                self.detailView.textColor = Palette.shared.compilationEventTextColor
                self.lineNumberView.textColor = Palette.shared.compilationEventTextColor
            default:
                break
            }
        }
    }
