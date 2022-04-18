//
//  BrowserEditorView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/3/22.
//

import Cocoa


    
public protocol SourceDelegate
    {
    func sourceDidChange(_ editor: BrowserEditorView)
    func sourceEditingDidBegin(_ editor: BrowserEditorView)
    func sourceEditingDidEnd(_ editor: BrowserEditorView)
    }
    
public protocol TextFocusDelegate
    {
    func textDidGainFocus(_ textView: NSTextView)
    func textDidLoseFocus(_ textView: NSTextView)
    }
    
public class BrowserEditorView: NSView,NSTextViewDelegate,TokenHandler,TextFocusDelegate
    {
    public var lineNumberRuler: LineNumberRulerView
        {
        self.textView.lineNumberRuler
        }
        
    public weak var sourceRecord: SourceRecord!
        {
        didSet
            {
            self.textView.string = self.sourceRecord.text
//            self.annotationView.lineCount = self.sourceRecord.lineCount
            self.textView.textStorage?.beginEditing()
            let font = Palette.shared.font(for: .editorFont)
            for attribute in self.sourceRecord.attributes
                {
                let range = attribute.range
                if range.location + range.length < self.sourceRecord.text.count
                    {
                    self.textView.textStorage?.setAttributes([.foregroundColor: attribute.color,.font: font], range: attribute.range)
                    }
                }
            self.textView.textStorage?.endEditing()
            self.rulerView.issues = self.sourceRecord.issues
//            for issue in self.sourceRecord.issues
//                {
//                self.annotationView.appendAnnotation(issue)
//                }
            self.lineCount = self.sourceRecord.text.components(separatedBy: "\n").count
            self.textDidChange(Notification(name: Notification.Name(rawValue: "")))
            }
        }

    public var sourceString: String
        {
        self.textView.string
        }
        
    public var gutterColor: NSColor = NSColor.white
        {
        didSet
            {
//            self.annotationView.gutterColor = self.gutterColor
            }
        }
        
    public var rulerBorderColor: NSColor = NSColor.white
        {
        didSet
            {
//            self.annotationView.gutterBorderColor = self.gutterBorderColor
            }
        }
        
//    public var font: NSFont = Palette.shared.font(for: .editorFont)
//        {
//        didSet
//            {
//            self.textView.font = self.font
//            self.rulerView.font = self.font
//            }
//        }
        
    public var lineCount:Int = 0
        {
        didSet
            {
//            self.annotationView.lineCount = self.lineCount
            }
        }
        
    private let textView: SourceTextView
//    private let annotationView: SyntaxAnnotationView
    public var incrementalParser: IncrementalParser!
    private let systemClassNames = Array<String>()
    public weak var sourceItem: ProjectSourceItem!
    public var activeAnnotations = Dictionary<Int,CALayer>()
    private let rulerView: LineNumberRulerView
    private let scrollView: NSScrollView
    init()
        {
        let aView = SourceTextView(frame: .zero)
        self.textView = aView
        self.rulerView = LineNumberRulerView(withTextView: aView, foregroundColorIdentifier: .lineNumberColor, backgroundColorIdentifier: .editorBackgroundColor)
//        self.annotationView = SyntaxAnnotationView(gutterWidth: 50)
//        self.annotationView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView = NSScrollView(frame: .zero)
        super.init(frame: .zero)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.borderType = .noBorder
        self.scrollView.hasVerticalRuler = true
        self.scrollView.hasVerticalScroller = true
        self.scrollView.hasHorizontalScroller = false
        self.scrollView.autohidesScrollers = true
        self.scrollView.verticalRulerView = self.rulerView
        self.scrollView.rulersVisible = true
        self.addSubview(scrollView)
        self.rulerView.clientView = self.textView
        self.textView.font = Palette.shared.font(for: .editorFont)
//        self.annotationView.font = Palette.shared.font(for: .editorFont)
        self.textView.backgroundColor = Palette.shared.color(for: .editorBackgroundColor)
        self.textView.isEditable = true
        self.textView.wantsLayer = true
        self.textView.isVerticallyResizable = true
        self.textView.isHorizontallyResizable = false
        self.textView.maxSize = NSSize(width: CGFloat.infinity,height: CGFloat.infinity)
        self.textView.textContainer?.containerSize = NSSize(width: 1000,height: CGFloat.infinity)
        self.textView.textContainer?.widthTracksTextView = true
//        self.annotationView.delegate = self
        self.textView.delegate = self
        self.textView.focusDelegate = self
        self.textView.autoresizingMask = [.width]
//        self.addSubview(self.textView)
//        self.addSubview(self.annotationView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidEndEditing), name: NSText.didEndEditingNotification, object: self.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditing), name: NSText.didBeginEditingNotification, object: self.textView)
        self.textView.isAutomaticTextCompletionEnabled = false
        self.textView.isAutomaticLinkDetectionEnabled = false
        self.textView.isGrammarCheckingEnabled = false
        self.textView.isContinuousSpellCheckingEnabled = false
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false
        self.textView.isAutomaticDataDetectionEnabled = false
        self.textView.isAutomaticTextReplacementEnabled = false
        self.scrollView.documentView = self.textView
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    public func hideAnnotationView()
        {
//        self.annotationView.isHidden = true
        }
        
    public func showAnnotationView()
        {
//        self.annotationView.isHidden = false
        }
        

        
    public func toggleIssueDisplay(_ issue: CompilerIssue)
        {
         let line = issue.location.line
        if let layer = self.activeAnnotations[line]
            {
            layer.removeFromSuperlayer()
            self.activeAnnotations[line] = nil
            return
            }
        let newLayer = CATextLayer()
        newLayer.string = issue.message
        newLayer.backgroundColor = issue.isWarning ? NSColor.argonBrightYellowCrayola.cgColor : NSColor.argonNeonPink.cgColor
        newLayer.foregroundColor = NSColor.black.cgColor
        newLayer.frame = self.textView.endOfLineRect(forLine: line)
        let font = Palette.shared.font(for: .editorFont)
        newLayer.font = font
        newLayer.fontSize = font.pointSize
        self.textView.layer?.addSublayer(newLayer)
        self.activeAnnotations[line] = newLayer
        }
    
    @IBAction public func textDidGainFocus(_ textView: NSTextView)
        {
        self.sourceItem.showBorder()
        }
        
    @IBAction public func textDidLoseFocus(_ textView: NSTextView)
        {
        self.sourceItem.hideBorder()
        }
        
    @IBAction public func textDidEndEditing(_ notification: Notification)
        {
        self.sourceRecord.sourceEditingDidEnd(self)
        }
        
    @IBAction public func textDidBeginEditing(_ notification: Notification)
        {
        self.sourceRecord.sourceEditingDidBegin(self)
        }
        
    private func resetMarkerToggles()
        {
        for layer in self.activeAnnotations.values
            {
            layer.removeFromSuperlayer()
            }
        self.activeAnnotations = [:]
        }
        
    public func textDidChange(_ notification: Notification)
        {
        self.rulerView.removeAllIssues()
        self.resetMarkerToggles()
        self.sourceRecord.sourceDidChange(self)
        self.sourceRecord.compilationWillStart(self)
        do
            {
            let context = CompilationContext(module: self.sourceItem.module,argonModule: self.sourceItem.controller.argonModule)
            let result = try self.incrementalParser.parse(itemKey: self.sourceItem.elementItem.itemKey,source: self.textView.string, tokenHandler: self,inContext: context)
            if result.hasIssues
                {
                self.sourceRecord.compilationDidFail(self,issues: result.issues)
                self.rulerView.issues = result.issues
                }
            else
                {
                let symbols = context.allSymbols
                for symbol in symbols
                    {
                    symbol.setModule(self.sourceItem.module)
                    }
                self.sourceRecord.compilationDidSucceed(self,symbolValue: result,affectedSymbols: context.allSymbols,inModule: self.sourceItem.module)
                }
            }
        catch
            {
            }
        self.sourceItem.sourceDidChange(self)
        }
                
//    public func issueAdded(token: Token,issue: CompilerIssue)
//        {
//        self.rulerView.addIssue(issue)
//        self.sourceRecord.appendIssue(issue)
//        }
        
    public func kindChanged(token: Token)
        {
        let kind = token.kind
        var localAttributes:[NSAttributedString.Key:Any] = [.foregroundColor: Palette.shared.color(for: .editorTextColor),.font: Palette.shared.font(for: .editorFont)]
        var color: StyleColorIdentifier = .editorTextColor
        switch(kind)
            {
            case .none:
                break
            case .invisible:
                break
            case .keyword:
                color = .keywordColor
            case .identifier:
                if self.systemClassNames.contains(token.identifier)
                    {
                    color = .systemClassColor
                    }
                else
                    {
                    color = .identifierColor
                    }
            case .operator:
                color = .operatorColor
            case .name:
                color = .nameColor
            case .enumeration:
                color = .enumerationColor
            case .comment:
                color = .commentColor
            case .path:
                color = .pathColor
            case .symbol:
                color = .symbolColor
            case .string:
                color = .stringColor
            case .class:
                color = .classColor
            case .integer:
                color = .integerColor
            case .float:
                color = .floatColor
            case .methodInvocation:
                color = .methodColor
            case .method:
                color = .methodColor
            case .functionInvocation:
                color = .functionColor
            case .function:
                color = .functionColor
            case .instanceSlot:
                color = .slotColor
            case .localSlot:
                color = .slotColor
            case .systemClass:
                color = .systemClassColor
            case .classSlot:
                color = .slotColor
            case .moduleSlot:
                color = .slotColor
            case .type:
                color = .typeColor
            case .constant:
                color = .constantColor
            case .module:
                color = .identifierColor
            default:
                break
            }
            self.textView.textStorage?.beginEditing()
            localAttributes[.foregroundColor] = Palette.shared.color(for: color)
            self.sourceRecord.attributes.append(TextAttribute(color: localAttributes[.foregroundColor] as! NSColor,range: token.location.range))
            self.textView.textStorage?.setAttributes(localAttributes, range: token.location.range)
            self.textView.textStorage?.endEditing()
        }
    }
