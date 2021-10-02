
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

/// A NSTextView with a line number gutter attached to it.
public class LineNumberTextView: NSTextView {

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

        self.addObservers()
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
        }
    }

