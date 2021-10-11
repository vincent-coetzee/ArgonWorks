//
//  VisualTokenizer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 11/10/21.
//

import AppKit

public class VisualTokenizer
    {
    public var source: String = ""
        {
        didSet
            {
            self.update()
            }
        }
        
    private let lineNumberView: LineNumberTextView
    private var tokenColors = Dictionary<TokenColor,NSColor>()
    private let reportingContext: ReportingContext
    
    init(lineNumberView: LineNumberTextView,reportingContext: ReportingContext)
        {
        self.lineNumberView = lineNumberView
        self.reportingContext = reportingContext
        self.initColors()
        NotificationCenter.default.addObserver(self, selector: #selector(VisualTokenizer.sourceChangedNotification(_:)), name: NSText.didChangeNotification, object: self.lineNumberView)
        }
        
    private func initColors()
        {
        self.tokenColors[TokenColor.text] = SyntaxColorPalette.textColor
        self.tokenColors[TokenColor.keyword] = SyntaxColorPalette.keywordColor
        self.tokenColors[TokenColor.identifier] = SyntaxColorPalette.identifierColor
        self.tokenColors[TokenColor.comment] = SyntaxColorPalette.commentColor
        self.tokenColors[TokenColor.integer] = SyntaxColorPalette.integerColor
        self.tokenColors[TokenColor.float] = SyntaxColorPalette.floatColor
        self.tokenColors[TokenColor.string] = SyntaxColorPalette.stringColor
        self.tokenColors[TokenColor.symbol] = SyntaxColorPalette.symbolColor
        }
        
    @IBAction func sourceChangedNotification(_ notification: NSNotification)
        {
        self.reportingContext.resetReporting()
        self.source = self.lineNumberView.string
        }
        
    private func update()
        {
        let stream = TokenStream(source: self.source,context: NullReportingContext())
        let tokens = stream.allTokens(withComments: true, context: NullReportingContext())
        self.processTokens(tokens)
        let compiler = Compiler()
        compiler.reportingContext = self.reportingContext
        compiler.compileChunk(self.source)
        }
        
    public func processTokens(_ tokens: Tokens)
        {
        let font = NSFont(name: "Menlo",size: 12)!
        let string = self.lineNumberView.textStorage!
        let textAttributes:[NSAttributedString.Key:Any] = [.foregroundColor:SyntaxColorPalette.textColor,.font: font]
        string.beginEditing()
        string.setAttributes(textAttributes, range: NSRange(location: 0,length: string.length))
        for token in tokens
            {
            let tokenColor = token.tokenColor
            let color = self.tokenColors[tokenColor]!
            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: font]
            string.setAttributes(attributes, range: token.location.range)
            }
        string.endEditing()
        }
    }
