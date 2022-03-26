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
    public var source: SourceRecord!
        {
        didSet
            {
            self.textView.string = self.source.text
            self.annotationView.lineCount = self.source.lineCount
            self.textView.textStorage?.beginEditing()
            for attribute in self.source.attributes
                {
                let range = attribute.range
                if range.location + range.length < self.source.text.count
                    {
                    self.textView.textStorage?.setAttributes([.foregroundColor: attribute.color,.font: self.font], range: attribute.range)
                    }
                }
            self.textView.textStorage?.endEditing()
            for issue in self.source.issues
                {
                self.annotationView.appendAnnotation(issue)
                }
            self.lineCount = self.source.text.components(separatedBy: "\n").count
            self.textDidChange(Notification(name: Notification.Name(rawValue: "")))
            }
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
        
//    private let textScrollView: NSScrollView
    private let textView: SourceTextView
    private let annotationView: SyntaxAnnotationView
    public var incrementalParser: IncrementalParser!
    public var sourceDelegate: SourceDelegate?
    private let systemClassNames = ArgonModule.shared.systemClassNames!
    public var sourceItem: ProjectSourceItem!
    public var activeAnnotations = Dictionary<Int,CALayer>()
    
    init()
        {
//        let scrollView = SourceTextView.scrollableTextView()
//        self.textScrollView = scrollView
        self.textView = SourceTextView(frame: .zero)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.annotationView = SyntaxAnnotationView(gutterWidth: 50)
        self.annotationView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
//        self.textScrollView.hasVerticalScroller = false
//        self.textScrollView.hasHorizontalScroller = true
//        self.textScrollView.autohidesScrollers = true
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
//        let lineHeight = self.font.lineHeight
//        let offset = CGFloat(line - 1) * lineHeight
//        let lineText = self.textView.string.line(at: line - 1)
//        let width = NSAttributedString(string: lineText,attributes: [.font: self.font]).size().width
        let newLayer = CATextLayer()
        newLayer.string = annotation.issue.message
        newLayer.backgroundColor = NSColor.argonNeonPink.cgColor
        newLayer.foregroundColor = NSColor.black.cgColor
        newLayer.frame = self.textView.endOfLineRect(forLine: line)
        newLayer.font = self.font
        newLayer.fontSize = self.font.pointSize
        self.textView.layer?.addSublayer(newLayer)
        self.activeAnnotations[line] = newLayer
        }
        
    @IBAction func textViewLostFocus(_ any: Any)
        {
        self.annotationView.isHidden = true
        self.needsLayout = true
        self.sourceDelegate?.sourceEditingDidEnd(self)
        }
        
    @objc public func textViewGainedFocus(_ any: Any)
        {
        self.sourceDelegate?.sourceEditingDidBegin(self)
        }
        
    public func textDidChange(_ notification: Notification)
        {
        self.annotationView.resetAnnotations()
        self.source.issues = []
        let aProject = self.sourceItem.project
        aProject.changed(aspect: "issueCount",with: aProject.allIssues.count,from: aProject)
        self.source.text = self.textView.string
        let module = self.sourceItem.project.module
        do
            {
            let result = try self.incrementalParser.parse(source: self.textView.string, tokenHandler: self,inModule: module)
            self.sourceItem.symbolValue = result
            }
        catch let error as CompilerError
            {
            for issue in error.issues
                {
                self.annotationView.appendAnnotation(issue)
                }
            self.source.issues = error.issues
            aProject.changed(aspect: "issueCount",with: aProject.allIssues.count,from: aProject)
            }
        catch
            {
            }
        self.annotationView.lineCount = self.source.lineCount
        self.sourceDelegate?.sourceDidChange(self)
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.annotationView.appendAnnotation(issue)
        self.source.appendIssue(issue)
        }
        
    public override func layout()
        {
        super.layout()
        let width = self.bounds.width - self.annotationView.gutterWidth
        let height = self.bounds.size.height
        if !self.annotationView.isHidden
            {
            self.annotationView.frame = NSRect(x: 0,y:0, width: self.annotationView.gutterWidth,height: height)
            self.textView.frame = NSRect(x: self.annotationView.gutterWidth,y:0,width: width,height: height)
            }
        else
            {
            self.textView.frame = NSRect(x: 0,y:0,width: width,height: height)
            }
        }
        
    public func kindChanged(token: Token)
        {
        if !token.issues.isEmpty
            {
            for issue in token.issues
                {
                self.annotationView.appendAnnotation(issue)
                self.source.issues.append(issue)
                }
            }
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
            self.source.attributes.append(Attribute(color: localAttributes[.foregroundColor] as! NSColor,range: token.location.range))
            self.textView.textStorage?.setAttributes(localAttributes, range: token.location.range)
            print("TOKEN IS \(token) RANGE IS \(token.location.range)")
            self.textView.textStorage?.endEditing()
        }
    }
