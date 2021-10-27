
//
// LineNumberTextView.swift
// LineNumberTextView
// https://github.com/raphaelhanneken/line-number-text-view
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import Cocoa

internal protocol SourceEditorDelegate
    {
    func sourceEditorGutter(_ view: LineNumberGutter,selectedAnnotationAtLine: Int)
    func sourceEditorKeyPressed(_ editor: LineNumberTextView)
    func sourceEditor(_ editor: LineNumberTextView,changedLine: Int,offset: Int)
    }
    
/// A NSTextView with a line number gutter attached to it.
public class LineNumberTextView: NSTextView
    {
    private let highlightAttributes =
        {
        () -> [NSAttributedString.Key:Any] in
        var attributes:[NSAttributedString.Key:Any] = [:]
        attributes[.foregroundColor] = NSColor.black
        attributes[.backgroundColor] = NSColor.yellow
        attributes[.font] = NSFont(name:"Menlo-Bold",size:20)!
        return(attributes)
        }()
        
    internal var sourceEditorDelegate: SourceEditorDelegate?
        {
        didSet
            {
            self.lineNumberGutter?.sourceEditorDelegate = self.sourceEditorDelegate
            }
        }
    
    /// Holds a layer which has been used to highlight the currently selected line / or not
    private var selectedLineLayer = CALayer()
    /// Holds the color to be used when highlighting a selected line
    public var selectionHighlightColor = NSColor.argonSizzlingRed
        {
        didSet
            {
            let newColor = selectionHighlightColor.withAlpha(0.4)
            self.selectedLineLayer.backgroundColor = newColor.cgColor
            }
        }
    /// Holds the click count for highlighting the line, odd click count
    /// shows the line, even click counts hide the line.
    private var downClickCount = 0
    /// Holds the selected line number
    private var selectedLineNumber = 0
    /// Holds the attached line number gutter.
    private var lineNumberGutter: LineNumberGutter?

    /// Holds the text color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var gutterForegroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
               let color  = self.gutterForegroundColor {
                gutter.foregroundColor = color
            }
        }
    }

    /// Holds the background color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var gutterBackgroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
               let color  = self.gutterBackgroundColor {
                gutter.backgroundColor = color
            }
        }
    }


    public func addAnnotation(_ annotation:LineAnnotation)
        {
        self.lineNumberGutter?.addAnnotation(annotation)
        }
        
    public func removeAnnotation(at line:Int)
        {
        self.lineNumberGutter?.removeAnnotation(at:line)
        }
        
    public func removeAllAnnotations()
        {
        self.lineNumberGutter?.removeAllAnnotations()
        }
        
    public func cartouche(_ cartouche:LineAnnotation,drawnIn rect:NSRect)
        {
        }
        
    public func initOutsideNib()
        {
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }

        self.wantsLayer = true
        self.selectedLineLayer.isHidden = true
        self.layer?.addSublayer(self.selectedLineLayer)
        if let gutterBG = self.gutterBackgroundColor,
           let gutterFG = self.gutterForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }

        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        self.initTabs()
        self.addObservers()
        }
        
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }

        self.wantsLayer = true
        self.selectedLineLayer.isHidden = true
        self.layer?.addSublayer(self.selectedLineLayer)
        if let gutterBG = self.gutterBackgroundColor,
           let gutterFG = self.gutterForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }

        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true

        self.initTabs()
        self.addObservers()
    }

    internal func initTabs()
        {
        let style = NSMutableParagraphStyle()
        style.headIndent = 0
        style.firstLineHeadIndent = 0
        var attributes:Dictionary<NSAttributedString.Key,Any> = [:]
        attributes[.paragraphStyle] = style
        style.addTabStop(NSTextTab(textAlignment: .left, location: 0, options: [:]))
        style.addTabStop(NSTextTab(textAlignment: .left, location: 60, options: [:]))
        style.addTabStop(NSTextTab(textAlignment: .left, location: 120, options: [:]))
        style.addTabStop(NSTextTab(textAlignment: .left, location: 180, options: [:]))
        style.addTabStop(NSTextTab(textAlignment: .left, location: 240, options: [:]))
        style.addTabStop(NSTextTab(textAlignment: .left, location: 300, options: [:]))
//            let count = self.string.count
//            let storage = self.textStorage
//            storage?.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: count))
        self.typingAttributes = attributes
        }
        
    /// Add observers to redraw the line number gutter, when necessary.
    internal func addObservers() {
        self.postsFrameChangedNotifications = true

        NotificationCenter.default.addObserver(self, selector: #selector(self.drawGutter), name: NSView.frameDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.drawGutter), name: NSText.didChangeNotification, object: self)
    }

    /// Set needsDisplay of lineNumberGutter to true.
    @objc internal func drawGutter() {
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
    }

    public func scrollToLine(_ line:Int)
        {
        let lineCount = self.string.components(separatedBy: "\n").count
        let lineHeight = self.lineNumberGutter!.lineHeight
        var bottom = max(0,line - 1)
        if line > 3
            {
            bottom = line - 3
            }
        var top = min(line,lineCount)
        if line < lineCount - 3
            {
            top = line + 3
            }
        let delta = CGFloat(top - bottom)
        let offset = self.lineNumberGutter!.lineHeight * CGFloat(bottom)
        let rect = CGRect(x:0,y:offset,width: self.bounds.width,height: delta * lineHeight)
        self.scrollToVisible(rect)
        self.highlight(line: line)
        }
        
    public func highlight(line: Int)
        {
        let lineHeight = self.lineNumberGutter!.lineHeight
        let offset = lineHeight * CGFloat(line)
        self.selectedLineLayer.isHidden = false
        var frame = NSRect(x:0,y:offset,width: self.bounds.width,height: lineHeight)
        frame.origin.y = frame.minY - lineHeight
        self.selectedLineLayer.frame = frame
        }
        
    public override func mouseDown(with event: NSEvent)
        {
        var line: Int = 0
        var rect: NSRect = .zero
        let point = self.convert(event.locationInWindow,from: nil)
        self.lineNumberGutter!.find(lineNumber: &line, andRectangle: &rect, forPoint: point)
        var actualLineNumber = 0
        let lineHeight = self.lineNumberGutter!.lineHeight
        var frame = rect
        if line == 0 ///  actually the last line
            {
            actualLineNumber = self.lineNumberGutter!.totalLineCount
            let offset = lineHeight * CGFloat(actualLineNumber)
            frame = NSRect(x:0,y:offset,width: self.bounds.width,height: lineHeight)
            }
        else
            {
            actualLineNumber = line - 1
            }
        frame.origin.y = frame.minY - lineHeight
        self.selectedLineNumber = actualLineNumber
        self.downClickCount += 1
        self.selectedLineLayer.frame = frame
        self.selectedLineLayer.isHidden = self.downClickCount % 2 == 1
        super.mouseDown(with: event)
        var location = self.selectedRanges.first!.rangeValue.location
        line = 0
        var offset = 0
        let lines = self.string.components(separatedBy: "\n")
        while offset + lines[line].count < location
            {
            offset += lines[line].count + 1
            line += 1
            }
        location = self.selectedRanges.first!.rangeValue.location
        self.sourceEditorDelegate?.sourceEditor(self,changedLine: line + 1,offset: location - offset)
        location = self.selectedRanges.first!.rangeValue.location
        let string = self.string
        var index = string.index(string.startIndex,offsetBy: location)
        var character = string[index]
        if character == "}"
            {
            while index > string.startIndex && character != "{"
                {
                index = string.index(before: index)
                character = string[index]
                location -= 1
                }
            if character == "{"
                {
                let range = NSRange(location: location, length: 1)
                let old = self.textStorage?.attributes(at: location, effectiveRange: nil)
                self.textStorage?.setAttributes(self.highlightAttributes, range: range)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                    self.textStorage?.setAttributes(old, range: range)
                    }
                }
            }
        }
        
    public override func keyDown(with event: NSEvent)
        {
        if event.isARepeat,let someCharacters = event.characters
            {
            let newCharacters = someCharacters + someCharacters + someCharacters + someCharacters
            let newEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: newCharacters, charactersIgnoringModifiers: event.charactersIgnoringModifiers!, isARepeat: event.isARepeat, keyCode: event.keyCode)
            self.interpretKeyEvents([newEvent!])
            }
        else
            {
            self.interpretKeyEvents([event])
            }
        var location = self.selectedRanges.first!.rangeValue.location
        var line = 0
        var offset = 0
        let lines = self.string.components(separatedBy: "\n")
        while offset + lines[line].count < location
            {
            offset += lines[line].count + 1
            line += 1
            }
        location = self.selectedRanges.first!.rangeValue.location
        print("LOCATION \(location)")
        print("OFFSET \(offset)")
        print("POSITION \(location - offset)")
        self.sourceEditorDelegate?.sourceEditor(self,changedLine: line + 1,offset: location - offset)
        }
        
    public override func insertNewline(_ sender:Any?)
        {
        let location = self.selectedRanges[0].rangeValue.location
        let string = self.string
        let startIndex = string.startIndex
        var currentIndex = string.index(startIndex,offsetBy: location)
        var tabString = ""
        if currentIndex < string.endIndex
            {
            currentIndex = string.index(currentIndex,offsetBy: 1)
            while currentIndex < string.endIndex && string[currentIndex].isWhitespace && string[currentIndex] != "\n"
                {
                if string[currentIndex] == "\t"
                    {
                    tabString += "\t"
                    }
                currentIndex = string.index(after: currentIndex)
                }
            }
        let range = NSRange(location: location,length: 0)
        self.textStorage?.replaceCharacters(in: range, with: "\n\(tabString)")
        }
    }

