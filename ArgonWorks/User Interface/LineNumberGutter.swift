
//
// LineNumberGutter.swift
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

/// Defines the width of the gutter view.
private let GUTTER_WIDTH: CGFloat = 40.0 + 10
private let LINE_NUMBER_OFFSET: CGFloat  = 16.0

/// Adds line numbers to a NSTextField.
class LineNumberGutter: NSRulerView {

    private var lineNumberRects:Array<NSRect> = []
    
    internal var sourceEditorDelegate: SourceEditorDelegate?
    
    /// Holds the height of a line
    internal var lineHeight: CGFloat = 0
    /// Holds the number of lines
    internal var totalLineCount = 0
    /// Holds the background color.
    internal var backgroundColor: NSColor {
        didSet {
            self.needsDisplay = true
        }
    }

    /// Holds the text color.
    internal var foregroundColor: NSColor {
        didSet {
            self.needsDisplay = true
        }
        
    }
    
    internal var annotations:[Int:LineAnnotation] = [:]


    public func addAnnotation(_ annotation:LineAnnotation)
        {
        self.annotations[annotation.line] = annotation
        }
        
    public func removeAnnotation(at line:Int)
        {
        self.annotations[line] = nil
        self.needsDisplay = true
        }
        
    public func removeAllAnnotations()
        {
        self.annotations = [:]
        self.needsDisplay = true
        }
        
    ///  Initializes a LineNumberGutter with the given attributes.
    ///
    ///  - parameter textView:        NSTextView to attach the LineNumberGutter to.
    ///  - parameter foregroundColor: Defines the foreground color.
    ///  - parameter backgroundColor: Defines the background color.
    ///
    ///  - returns: An initialized LineNumberGutter object.
    init(withTextView textView: NSTextView, foregroundColor: NSColor, backgroundColor: NSColor) {
        // Set the color preferences.
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor

        // Make sure everything's set up properly before initializing properties.
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)

        // Set the rulers clientView to the supplied textview.
        self.clientView = textView
        // Define the ruler's width.
        self.ruleThickness = GUTTER_WIDTH
    }

    ///  Initializes a default LineNumberGutter, attached to the given textView.
    ///  Default foreground color: hsla(0, 0, 0, 0.55);
    ///  Default background color: hsla(0, 0, 0.95, 1);
    ///
    ///  - parameter textView: NSTextView to attach the LineNumberGutter to.
    ///
    ///  - returns: An initialized LineNumberGutter object.
    convenience init(withTextView textView: NSTextView) {
        let fg = NSColor(calibratedHue: 0, saturation: 0, brightness: 0, alpha: 1)
        let bg = NSColor(calibratedHue: 0, saturation: 0, brightness: 0, alpha: 1)
        // Call the designated initializer.
        self.init(withTextView: textView, foregroundColor: fg, backgroundColor: bg)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///  Draws the line numbers.
    ///
    ///  - parameter rect: NSRect to draw the gutter view in.
    override func drawHashMarksAndLabels(in rect: NSRect)
        {
        self.lineNumberRects = []
        // Set the current background color...
        self.backgroundColor.set()
        // ...and fill the given rect.
        rect.fill()

        // Unwrap the clientView, the layoutManager and the textContainer, since we'll
        // them sooner or later.
        guard let textView      = self.clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer
        else {
            return
        }

        let content = textView.string

        // Get the range of the currently visible glyphs.
        let visibleGlyphsRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)

        // Check how many lines are out of the current bounding rect.
        var lineNumber: Int = 1
        do {
            // Define a regular expression to find line breaks.
            let newlineRegex = try NSRegularExpression(pattern: "\n", options: [])
            // Check how many lines are out of view; From the glyph at index 0
            // to the first glyph in the visible rect.
            lineNumber += newlineRegex.numberOfMatches(in: content, options: [], range: NSMakeRange(0, visibleGlyphsRange.location))
        } catch {
            return
        }

        // Get the index of the first glyph in the visible rect, as starting point...
        var firstGlyphOfLineIndex = visibleGlyphsRange.location

        // ...then loop through all visible glyphs, line by line.
        while firstGlyphOfLineIndex < NSMaxRange(visibleGlyphsRange) {
            // Get the character range of the line we're currently in.
            let charRangeOfLine  = (content as NSString).lineRange(for: NSRange(location: layoutManager.characterIndexForGlyph(at: firstGlyphOfLineIndex), length: 0))
            // Get the glyph range of the line we're currently in.
            let glyphRangeOfLine = layoutManager.glyphRange(forCharacterRange: charRangeOfLine, actualCharacterRange: nil)

            var firstGlyphOfRowIndex = firstGlyphOfLineIndex
            var lineWrapCount        = 0

            // Loop through all rows (soft wraps) of the current line.
            while firstGlyphOfRowIndex < NSMaxRange(glyphRangeOfLine) {
                // The effective range of glyphs within the current line.
                var effectiveRange = NSRange(location: 0, length: 0)
                // Get the rect for the current line fragment.
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: firstGlyphOfRowIndex, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                self.lineHeight = lineRect.height
                // Draw the current line number;
                // When lineWrapCount > 0 the current line spans multiple rows.
                if lineWrapCount == 0 {
                    if let cartouche = self.annotations[lineNumber]
                        {
                        self.drawAnnotation(cartouche,atYPosition: lineRect.minY)
                        }
                    self.drawLineNumber(num: lineNumber, atYPosition: lineRect.minY)
//                    self.lineNumberRects[lineNumber] = NSRect(x:0,y: lineRect.minY,width: 100,height: lineHeight)
                } else {
                    break
                }

                // Move to the next row.
                firstGlyphOfRowIndex = NSMaxRange(effectiveRange)
                lineWrapCount+=1
            }

            // Move to the next line.
            firstGlyphOfLineIndex = NSMaxRange(glyphRangeOfLine)
            lineNumber+=1
        }

        // Draw another line number for the extra line fragment.
        if let _ = layoutManager.extraLineFragmentTextContainer {
            self.drawLineNumber(num: lineNumber, atYPosition: layoutManager.extraLineFragmentRect.minY)
        self.totalLineCount = lineNumber
        }
    }
    
    internal func annotation(atPoint: NSPoint) -> LineAnnotation?
        {
        for annotation in self.annotations.values
            {
            if annotation.area.contains(atPoint)
                {
                return(annotation)
                }
            }
        return(nil)
        }
    
    ///
    ///  - parameter rect: NSRect to draw the gutter view in.
    internal func find(lineNumber line:inout Int,andRectangle rectangle:inout NSRect,forPoint point: NSPoint)
        {
        guard let textView      = self.clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer
        else
            {
            return
            }
        let content = textView.string
        // Get the range of the currently visible glyphs.
        let visibleGlyphsRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)

        // Check how many lines are out of the current bounding rect.
        var lineNumber: Int = 1
        do
            {
            // Define a regular expression to find line breaks.
            let newlineRegex = try NSRegularExpression(pattern: "\n", options: [])
            // Check how many lines are out of view; From the glyph at index 0
            // to the first glyph in the visible rect.
            lineNumber += newlineRegex.numberOfMatches(in: content, options: [], range: NSMakeRange(0, visibleGlyphsRange.location))
            }
        catch
            {
            lineNumber += 1
            return
            }

        // Get the index of the first glyph in the visible rect, as starting point...
        var firstGlyphOfLineIndex = visibleGlyphsRange.location

        // ...then loop through all visible glyphs, line by line.
        while firstGlyphOfLineIndex < NSMaxRange(visibleGlyphsRange)
            {
            // Get the character range of the line we're currently in.
            let charRangeOfLine  = (content as NSString).lineRange(for: NSRange(location: layoutManager.characterIndexForGlyph(at: firstGlyphOfLineIndex), length: 0))
            // Get the glyph range of the line we're currently in.
            let glyphRangeOfLine = layoutManager.glyphRange(forCharacterRange: charRangeOfLine, actualCharacterRange: nil)

            var firstGlyphOfRowIndex = firstGlyphOfLineIndex
            var lineWrapCount        = 0

            // Loop through all rows (soft wraps) of the current line.
            while firstGlyphOfRowIndex < NSMaxRange(glyphRangeOfLine)
                {
                // The effective range of glyphs within the current line.
                var effectiveRange = NSRange(location: 0, length: 0)
                // Get the rect for the current line fragment.
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: firstGlyphOfRowIndex, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                // Draw the current line number;
                // When lineWrapCount > 0 the current line spans multiple rows.
                if lineWrapCount != 0
                    {
                    break
                    }
                if lineRect.minY >= point.y
                    {
                    rectangle = lineRect
                    line = lineNumber
                    return
                    }
                // Move to the next row.
                firstGlyphOfRowIndex = NSMaxRange(effectiveRange)
                lineWrapCount+=1
                }
            // Move to the next line.
            firstGlyphOfLineIndex = NSMaxRange(glyphRangeOfLine)
            lineNumber+=1
            }
        }
    
    func drawAnnotation(_ cartouche:LineAnnotation,atYPosition y:CGFloat)
        {
        guard let textView = self.clientView as? NSTextView else {
            return
        }
        let rect:NSRect = NSRect(x:4,y:y,width:15,height:15)
        let relativePoint    = self.convert(NSZeroPoint, from: textView)
        let newRect = NSRect(x:rect.minX + 31,y:relativePoint.y + y - 1,width:rect.width,height:rect.height)
        cartouche.image.draw(in: newRect)
        cartouche.area = newRect
        let lineView = textView as! LineNumberTextView
        lineView.cartouche(cartouche, drawnIn: newRect)
        }

    func drawLineNumber(num: Int, atYPosition yPos: CGFloat) {
        // Unwrap the text view.
        guard let textView = self.clientView as? NSTextView,
              let font     = textView.font else {
            return
        }
        // Define attributes for the attributed string.
        let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: self.foregroundColor]
        // Define the attributed string.
        let attributedString = NSAttributedString(string: "\(num)", attributes: attrs)
        // Get the NSZeroPoint from the text view.
        let relativePoint    = self.convert(NSZeroPoint, from: textView)
        // Calculate the x position, within the gutter.
        let xPosition        = GUTTER_WIDTH - (attributedString.size().width)
        // Draw the attributed string to the calculated point.
        attributedString.draw(at: NSPoint(x: xPosition - LINE_NUMBER_OFFSET, y: relativePoint.y + yPos))
    }
    
    public override func mouseDown(with event: NSEvent)
        {
        let point = self.convert(event.locationInWindow, from: nil)
        for annotation in self.annotations.values
            {
            if annotation.area.contains(point)
                {
                self.sourceEditorDelegate?.sourceEditorGutter(self, selectedAnnotation: annotation,atLine: annotation.line)
                }
            }
        super.mouseDown(with: event)
        }

}
