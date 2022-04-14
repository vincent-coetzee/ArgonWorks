//
//  SourceTextView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/3/22.
//

import Cocoa

class SourceTextView: NSTextView
    {
    public var lineNumberRuler: LineNumberRulerView
        {
        self.enclosingScrollView?.verticalRulerView as! LineNumberRulerView
        }
        
    public var focusDelegate: TextFocusDelegate?
    public var sourceEditorDelegate: SourceEditorDelegate?
    
    public override init(frame: NSRect,textContainer: NSTextContainer?)
        {
        super.init(frame: frame,textContainer: textContainer)
        }
        
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        self.initStyles()
        }
        
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    private func initStyles()
        {
        if let style = self.defaultParagraphStyle?.mutableCopy() as? NSMutableParagraphStyle
            {
            if let width = self.font?.screenFont(with: .defaultRenderingMode).advancement(forGlyph: NSGlyph(" ")).width
                {
                style.defaultTabInterval = Palette.shared.float(for: .tabWidth) * width
                style.tabStops = []
                self.defaultParagraphStyle = style
                }
            }
            
        self.font = Palette.shared.font(for: .editorFont)
        }
        
    public func endOfLineRect(forLine: Int) -> CGRect
        {
        var line = 1
        let text = self.string
        var index = text.startIndex
        while index < text.endIndex && line < forLine
            {
            if text[index] == "\n"
                {
                line += 1
                }
            index = text.index(index, offsetBy: 1)
            }
        let characterIndex = text.distance(from: text.startIndex,to: index) - 1
        let glyphIndex = self.layoutManager!.glyphIndexForCharacter(at: characterIndex)
        let range = NSRange(location: glyphIndex,length: 1)
        var rect = self.layoutManager!.boundingRect(forGlyphRange: range, in: self.textContainer!)
        rect.size.width = max(rect.size.width,self.bounds.size.width - 4)
        rect.size.height = self.font!.lineHeight
        return(rect)
        }
        
    public override func selectionRange(forProposedRange proposedCharRange: NSRange,granularity: NSSelectionGranularity) -> NSRange
        {
        let newRange = super.selectionRange(forProposedRange: proposedCharRange, granularity: granularity)
        print("Insertion point is at \(newRange.location)")
        return(newRange)
        }
        
    public override func becomeFirstResponder() -> Bool
        {
        self.focusDelegate?.textDidGainFocus(self)
        return(true)
        }
        
    public override func resignFirstResponder() -> Bool
        {
        self.focusDelegate?.textDidLoseFocus(self)
        super.resignFirstResponder()
        return(true)
        }
        
    public override func keyDown(with event: NSEvent)
        {
        if event.characters == "="
            {
            let newCharacters = "⇦"
            let newEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: newCharacters, charactersIgnoringModifiers: event.charactersIgnoringModifiers!, isARepeat: event.isARepeat, keyCode: event.keyCode)
            self.interpretKeyEvents([newEvent!])
            }
        else
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
//        self.textStorage?.replaceCharacters(in: range, with: "\n\(tabString)")
        super.insertNewline(sender)
        }
        
    public override func rulerView(_ rulerView: NSRulerView,handleMouseDownWith event: NSEvent)
        {
        var location = self.convert(event.locationInWindow,from: nil)
        let lineNumberRuler = rulerView as! LineNumberRulerView
        location = rulerView.convert(location,from: self)
        if let issue = lineNumberRuler.issueContainingPoint(location)
            {
            (self.delegate as? BrowserEditorView)?.toggleIssueDisplay(issue)
            }
        }
    }
