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
    
public class BrowserEditorView: NSView,NSTextViewDelegate,TokenHandler,SyntaxAnnotationViewDelegate
    {
    public var sourceRecord: SourceRecord!
        {
        didSet
            {
            self.textView.string = self.sourceRecord.text
            self.annotationView.lineCount = self.sourceRecord.lineCount
            self.textView.textStorage?.beginEditing()
            for attribute in self.sourceRecord.attributes
                {
                let range = attribute.range
                if range.location + range.length < self.sourceRecord.text.count
                    {
                    self.textView.textStorage?.setAttributes([.foregroundColor: attribute.color,.font: self.font], range: attribute.range)
                    }
                }
            self.textView.textStorage?.endEditing()
            for issue in self.sourceRecord.issues
                {
                self.annotationView.appendAnnotation(issue)
                }
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
            self.annotationView.gutterColor = self.gutterColor
            }
        }
        
    public var gutterBorderColor: NSColor = NSColor.white
        {
        didSet
            {
            self.annotationView.gutterBorderColor = self.gutterBorderColor
            }
        }
        
    public var font: NSFont = NSFont(name: "Menlo",size: 10)!
        {
        didSet
            {
            self.textView.font = self.font
            self.annotationView.font = self.font
            }
        }
        
    public var lineCount:Int = 0
        {
        didSet
            {
            self.annotationView.lineCount = self.lineCount
            }
        }
        
    private let textView: SourceTextView
    private let annotationView: SyntaxAnnotationView
    public var incrementalParser: IncrementalParser!
    private let systemClassNames = ArgonModule.shared.systemClassNames!
    public var sourceItem: ProjectSourceItem!
    public var activeAnnotations = Dictionary<Int,CALayer>()
    
    init()
        {
        self.textView = SourceTextView(frame: .zero)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.annotationView = SyntaxAnnotationView(gutterWidth: 50)
        self.annotationView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        self.textView.isEditable = true
        self.textView.wantsLayer = true
        self.annotationView.delegate = self
        self.textView.delegate = self
        self.addSubview(self.textView)
        self.addSubview(self.annotationView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textViewLostFocus), name: NSText.didEndEditingNotification, object: self.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textViewGainedFocus), name: NSText.didBeginEditingNotification, object: self.textView)
        self.textView.isAutomaticTextCompletionEnabled = false
        self.textView.isAutomaticLinkDetectionEnabled = false
        self.textView.isGrammarCheckingEnabled = false
        self.textView.isContinuousSpellCheckingEnabled = false
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false
        self.textView.isAutomaticDataDetectionEnabled = false
        self.textView.isAutomaticTextReplacementEnabled = false
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    public func toggleAnnotation(_ annotation: SyntaxAnnotation)
        {
        let line = annotation.issue.location.line
        if let layer = self.activeAnnotations[line]
            {
            layer.removeFromSuperlayer()
            self.activeAnnotations[line] = nil
            return
            }
        let newLayer = CATextLayer()
        newLayer.string = annotation.issue.message
        newLayer.backgroundColor = annotation.issue.isWarning ? NSColor.argonBrightYellowCrayola.cgColor : NSColor.argonNeonPink.cgColor
        newLayer.foregroundColor = NSColor.black.cgColor
        newLayer.frame = self.textView.endOfLineRect(forLine: line)
        newLayer.font = self.font
        newLayer.fontSize = self.font.pointSize
        self.textView.layer?.addSublayer(newLayer)
        self.activeAnnotations[line] = newLayer
        }
        
    @IBAction func textViewLostFocus(_ any: Any)
        {
        self.sourceRecord.sourceEditingDidEnd(self)
        }
        
    @objc public func textViewGainedFocus(_ any: Any)
        {
        self.sourceRecord.sourceEditingDidBegin(self)
        }
        
    public func textDidChange(_ notification: Notification)
        {
        self.annotationView.resetAnnotations()
        self.sourceRecord.sourceDidChange(self)
        self.sourceRecord.compilationWillStart(self)
        let module = self.sourceItem.project.module
        do
            {
            let context = CompilationContext(module: module)
            let result = try self.incrementalParser.parse(itemKey: self.sourceItem.elementItem.itemKey,source: self.textView.string, tokenHandler: self,inContext: context)
            if result.hasIssues
                {
                self.sourceRecord.compilationDidFail(self,issues: result.issues)
                self.appendIssues(result.issues)
                }
            else
                {
                self.sourceRecord.compilationDidSucceed(self,symbolValue: result,affectedSymbols: context.allSymbols,inModule: self.sourceItem.module)
                }
            }
        catch
            {
            }
        self.annotationView.lineCount = self.sourceRecord.lineCount
        self.sourceItem.sourceDidChange(self)
        }
        
    private func appendIssues(_ issues: CompilerIssues)
        {
        for issue in issues
            {
            self.annotationView.appendAnnotation(issue)
            }
        }
    public override func layout()
        {
        super.layout()
        let width = self.bounds.width - self.annotationView.gutterWidth
        let height = self.bounds.size.height
        self.annotationView.frame = NSRect(x: 0,y:0, width: self.annotationView.gutterWidth,height: height)
        let lineHeight = self.sourceItem.controller.sourceOutlinerFont.lineHeight
        self.textView.frame = NSRect(x: self.annotationView.gutterWidth,y:lineHeight,width: width,height: height - lineHeight)
        }
        
    public func issueAdded(token: Token,issue: CompilerIssue)
        {
        self.annotationView.appendAnnotation(issue)
        self.sourceRecord.appendIssue(issue)
        }
        
    public func kindChanged(token: Token)
        {
        let kind = token.kind
        var localAttributes:[NSAttributedString.Key:Any] = [.foregroundColor: NSColor.white,.font: self.font]
        switch(kind)
            {
            case .none:
                break
            case .invisible:
                break
            case .keyword:
                localAttributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .identifier:
                if self.systemClassNames.contains(token.identifier)
                    {
                    localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
                    }
                else
                    {
                    localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
                    }
            case .operator:
                localAttributes[.foregroundColor] = SyntaxColorPalette.operatorColor
            case .name:
                localAttributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .enumeration:
                localAttributes[.foregroundColor] = SyntaxColorPalette.enumerationColor
            case .comment:
                localAttributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .path:
                localAttributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .symbol:
                localAttributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .string:
                localAttributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .class:
                localAttributes[.foregroundColor] = SyntaxColorPalette.classColor
            case .integer:
                localAttributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                localAttributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .directive:
                localAttributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .methodInvocation:
                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .method:
                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .functionInvocation:
                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .function:
                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .instanceSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .localSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .systemClass:
                localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
            case .classSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .moduleSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .type:
                localAttributes[.foregroundColor] = SyntaxColorPalette.typeColor
            case .constant:
                localAttributes[.foregroundColor] = SyntaxColorPalette.constantColor
            case .module:
                localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
            default:
                localAttributes[.foregroundColor] = NSColor.magenta
            }
            self.textView.textStorage?.beginEditing()
            self.sourceRecord.attributes.append(Attribute(color: localAttributes[.foregroundColor] as! NSColor,range: token.location.range))
            self.textView.textStorage?.setAttributes(localAttributes, range: token.location.range)
            self.textView.textStorage?.endEditing()
        }
    }
