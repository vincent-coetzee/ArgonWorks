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
                    let lineStart = location.lineStart
                    let start = location.tokenStart - lineStart
                    let stop = location.tokenStart - lineStart
                    self.lineNumberView.stringValue = "\(location.line):\(start)-\(stop)"
                    self.detailView.stringValue = "Warning: \(text)"
                case .error(let location,let text):
                    let lineStart = location.lineStart
                    let start = location.tokenStart - lineStart
                    let stop = location.tokenStart - lineStart
                    self.lineNumberView.stringValue = "\(location.line):\(start)-\(stop)"
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
        
    @IBOutlet var lineNumberView: NSTextField!
    @IBOutlet var detailView: NSTextField!
    }
