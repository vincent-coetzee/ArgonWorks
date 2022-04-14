//
//  LineNumberRuler.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 10/4/22.
//

import Cocoa

/// Adds line numbers to a NSTextField.
public class LineNumberRulerView: NSRulerView
    {
    public var issues: CompilerIssues = []
        {
        willSet
            {
            self.removeAllIssues()
            self.needsDisplay = true
            }
        didSet
            {
            for issue in self.issues
                {
                self.addIssue(issue)
                }
            self.needsDisplay = true
            }
        }
        
    public var font: NSFont = Palette.shared.font(for: .lineNumberFont)
        {
        didSet
            {
            self.needsDisplay = true
            }
        }
        
    private var lineNumberOffsets = Array<CGFloat>()
    
    /// Holds the height of a line
    internal var lineHeight: CGFloat = 0
    /// Holds the number of lines
    internal var totalLineCount = 0
    /// Holds the background color.
    internal var backgroundColorIdentifier: StyleColorIdentifier
        {
        didSet
            {
            self.needsDisplay = true
            }
        }

    /// Holds the text color.
    internal var foregroundColorIdentifier: StyleColorIdentifier
        {
        didSet
            {
            self.needsDisplay = true
            }
        }

    ///  Initializes a LineNumberGutter with the given attributes.
    ///
    ///  - parameter textView:        NSTextView to attach the LineNumberGutter to.
    ///  - parameter foregroundColor: Defines the foreground color.
    ///  - parameter backgroundColor: Defines the background color.
    ///
    ///  - returns: An initialized LineNumberGutter object.
    init(withTextView textView: NSTextView, foregroundColorIdentifier: StyleColorIdentifier, backgroundColorIdentifier: StyleColorIdentifier)
        {
        // Set the color preferences.
        self.backgroundColorIdentifier = backgroundColorIdentifier
        self.foregroundColorIdentifier = foregroundColorIdentifier
        // Make sure everything's set up properly before initializing properties.
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        // Set the rulers clientView to the supplied textview.
        self.clientView = textView
        // Define the ruler's width.
        self.ruleThickness = Palette.shared.float(for: .lineNumberRulerWidth)
//        self.reservedThicknessForMarkers = 18
        }

    required init(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    ///  Draws the line numbers.
    ///
    ///  - parameter rect: NSRect to draw the gutter view in.
    public override func drawHashMarksAndLabels(in rect: NSRect)
        {
        self.lineNumberOffsets = []
        // Set the current background color...
        Palette.shared.color(for: self.backgroundColorIdentifier).set()
        // ...and fill the given rect.
        rect.fill()
        // Unwrap the clientView, the layoutManager and the textContainer, since we'll
        // them sooner or later.
        guard let textView      = self.clientView as? NSTextView,let layoutManager = textView.layoutManager,let textContainer = textView.textContainer else
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
            var lineWrapCount = 0
            // Loop through all rows (soft wraps) of the current line.
            while firstGlyphOfRowIndex < NSMaxRange(glyphRangeOfLine)
                {
                // The effective range of glyphs within the current line.
                var effectiveRange = NSRange(location: 0, length: 0)
                // Get the rect for the current line fragment.
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: firstGlyphOfRowIndex, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                self.lineHeight = lineRect.height
//                self.reservedThicknessForMarkers = self.lineHeight + 2 + 2
                // Draw the current line number;
                // When lineWrapCount > 0 the current line spans multiple rows.
                if lineWrapCount == 0
                    {
                    self.drawLineNumber(number: lineNumber, atYPosition: lineRect.minY)
                    self.lineNumberOffsets.append(lineRect.minY + lineRect.height / 2)
//                    self.lineNumberRects[lineNumber] = NSRect(x:0,y: lineRect.minY,width: 100,height: lineHeight)
                    }
                else
                    {
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
        if let _ = layoutManager.extraLineFragmentTextContainer
            {
            self.drawLineNumber(number: lineNumber, atYPosition: layoutManager.extraLineFragmentRect.minY)
            self.lineNumberOffsets.append(layoutManager.extraLineFragmentRect.minY + layoutManager.extraLineFragmentRect.height / 2)
            self.totalLineCount = lineNumber
            }
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
    
    func drawLineNumber(number: Int, atYPosition yPos: CGFloat)
        {
        // Unwrap the text view.
        guard let textView = self.clientView as? NSTextView,let font = textView.font else
            {
            return
            }
        // Define attributes for the attributed string.
        let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: Palette.shared.color(for: self.foregroundColorIdentifier)]
        // Define the attributed string.
        let attributedString = NSAttributedString(string: "\(number)", attributes: attrs)
        // Get the NSZeroPoint from the text view.
        let relativePoint    = self.convert(NSZeroPoint, from: textView)
        // Calculate the x position, within the gutter.
        let xPosition = Palette.shared.float(for: .lineNumberRulerWidth) - (attributedString.size().width)
        // Draw the attributed string to the calculated point.
        attributedString.draw(at: NSPoint(x: xPosition - Palette.shared.float(for: .lineNumberIndent), y: relativePoint.y + yPos))
        }
        
    public func offset(forLine line: Int) -> CGFloat?
        {
        if line - 1 >= self.lineNumberOffsets.count
            {
            return(nil)
            }
        return(self.lineNumberOffsets[line - 1])
        }

    public func addIssue(_ issue: CompilerIssue)
        {
        if let marker = self.rulerMarker(from: issue)
            {
            self.addMarker(marker)
            }
        }
        
    public func issueContainingPoint(_ point: NSPoint) -> CompilerIssue?
        {
        for marker in (self.markers ?? [])
            {
            if marker.imageRectInRuler.contains(point)
                {
                return(marker.representedObject as? CompilerIssue)
                }
            }
        return(nil)
        }
        
    public func rulerMarker(from issue: CompilerIssue) -> NSRulerMarker?
        {
        var image = NSImage(named: "IconMarker")!
        image.isTemplate = true
        image = image.image(withTintColor: Palette.shared.color(for: issue.isWarning ? .warningColor : .errorColor))
        image.size = NSSize(width: self.lineHeight,height: self.lineHeight)
        guard let offset = self.offset(forLine: issue.location.line) else
            {
            return(nil)
            }
        let marker = NSRulerMarker(rulerView: self, markerLocation: offset, image: image, imageOrigin: NSPoint(x: 0,y: self.lineHeight / 2))
        marker.representedObject = issue as NSCopying
        return(marker)
        }
        
    public func removeAllIssues()
        {
        self.markers = []
        }
    }
