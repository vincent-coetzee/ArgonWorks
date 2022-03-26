//
//  VisualTokenizer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 11/10/21.
//

import AppKit

//public class VisualTokenizer: SemanticTokenRenderer
//    {
//    public var kind: TokenRenderer.Kind
//        {
//        get
//            {
//            return(.none)
//            }
//        set
//            {
//            }
//        }
//        
//    private let lineNumberView: LineNumberTextView
//    private var tokenColors = Dictionary<TokenColor,NSColor>()
//    public var reportingContext: Reporter
//    public var systemClassNames: Array<String>
//    private let font: NSFont
//    
//    init(lineNumberView: LineNumberTextView,reporter: Reporter)
//        {
//        self.systemClassNames = ArgonModule.shared.systemClassNames
//        self.lineNumberView = lineNumberView
//        self.reportingContext = reporter
//        self.font = NSFont(name: "Menlo",size: 12)!
//        self.initColors()
//        NotificationCenter.default.addObserver(self, selector: #selector(VisualTokenizer.sourceChangedNotification(_:)), name: NSText.didChangeNotification, object: self.lineNumberView)
//        }
//        
//    private func initColors()
//        {
//        self.tokenColors[TokenColor.text] = SyntaxColorPalette.textColor
//        self.tokenColors[TokenColor.keyword] = SyntaxColorPalette.keywordColor
//        self.tokenColors[TokenColor.identifier] = SyntaxColorPalette.identifierColor
//        self.tokenColors[TokenColor.comment] = SyntaxColorPalette.commentColor
//        self.tokenColors[TokenColor.integer] = SyntaxColorPalette.integerColor
//        self.tokenColors[TokenColor.float] = SyntaxColorPalette.floatColor
//        self.tokenColors[TokenColor.string] = SyntaxColorPalette.stringColor
//        self.tokenColors[TokenColor.symbol] = SyntaxColorPalette.symbolColor
//        self.tokenColors[TokenColor.systemClass] = NSColor.argonBrightYellowCrayola
//        }
//        
//    @IBAction func sourceChangedNotification(_ notification: NSNotification)
//        {
//        self.reportingContext.resetReporting()
//        self.update(self.lineNumberView.string)
//        }
//        
//    public func update(_ string: String)
//        {
//        let time = Timer().time
//            {
//            let stream = TokenStream(source: string)
//            let tokens = stream.allTokens(withComments: true)
//            self.processTokens(tokens)
//            }
//        print("Time to generate and process tokens = \(time)")
//        let time2 = Timer().time
//            {
////            let compiler = Compiler(tokens: someTokens,reportingContext: self.reportingContext,tokenRenderer: self)
////            compiler.compile(parseOnly: true)
////            DispatchQueue.main.async
////                {
////                self.reportingContext.pushIssues(compiler.allIssues)
////                }
//            }
//        print("Time to create Compiler and parse = \(time2)")
//        }
//        
//    public func processTokens(_ tokens: Tokens)
//        {
//        let string = self.lineNumberView.textStorage!
//        let textAttributes:[NSAttributedString.Key:Any] = [.foregroundColor:SyntaxColorPalette.textColor,.font: self.font]
//        string.beginEditing()
//        string.setAttributes(textAttributes, range: NSRange(location: 0,length: string.length))
//        for token in tokens
//            {
////            var tokenColor = token.tokenColor
//            var tokenColor:TokenColor = .text
//            var color = self.tokenColors[tokenColor]!
//            if token.isIdentifier && self.systemClassNames.contains(token.identifier)
//                {
//                tokenColor = .systemClass
//                color = self.tokenColors[tokenColor]!
//                }
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            string.setAttributes(attributes, range: token.location.range)
//            }
//        string.endEditing()
//        }
//        
//    public func setKind(_ kind: TokenKind,ofToken token:ParseToken)
//        {
//        if kind == .systemClass
//            {
////            let color = TokenRenderer.mapKindToForegroundColor(kind: kind)
//            let color = self.tokenColors[.systemClass]!
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//            }
//        else if kind == .type
//            {
//            let color = NSColor.argonCoral
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//            }
//        else if kind == .class
//            {
//            let color = NSColor.argonStoneTerrace
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//            }
//        else if kind == .method
//            {
//            let color = NSColor.argonNeonOrange
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//            }
//        else if kind == .genericClassParameter
//            {
////            let color = NSColor.white
//            let color = NSColor.argonOpal
////            let color = NSColor.argonSkyBlueCrayola
//            let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//            self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//            }
//        }
//        
//    public func markToken(_ token: ParseToken,as kind: TokenRenderer.Kind)
//        {
//        let color = self.mapKindToForegroundColor(token: token,kind: kind)
//        let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:color,.font: self.font]
//        self.lineNumberView.textStorage?.setAttributes(attributes, range: token.location.range)
//        }
//        
//    private func mapKindToForegroundColor(token: ParseToken,kind:TokenRenderer.Kind) -> NSColor
//        {
//        var localAttributes:[NSAttributedString.Key:Any] = [:]
//        switch(kind)
//            {
//            case .none:
//                break
//            case .invisible:
//                break
//            case .keyword:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.keywordColor
//            case .identifier:
//                if token.isIdentifier
//                    {
//                    let identifier = token.identifier
//                    if self.systemClassNames.contains(identifier)
//                        {
//                        localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
//                        }
//                    else
//                        {
//                        localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
//                        }
//                    }
//                else
//                    {
//                    localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
//                    }
//            case .name:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.nameColor
//            case .enumeration:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.enumerationColor
//            case .comment:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.commentColor
//            case .path:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.pathColor
//            case .symbol:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.symbolColor
//            case .string:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.stringColor
//            case .class:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.classColor
//            case .integer:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.integerColor
//            case .float:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.floatColor
//            case .directive:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.directiveColor
//            case .methodInvocation:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
//            case .method:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
//            case .functionInvocation:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
//            case .function:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
//            case .localSlot:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
//            case .systemClass:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
//            case .classSlot:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
//            case .type:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.typeColor
//            case .constant:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.constantColor
//            case .module:
//                localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
//            default:
//                localAttributes[.foregroundColor] = NSColor.magenta
//            }
//        return(localAttributes[.foregroundColor]! as! NSColor)
//        }
//    }
