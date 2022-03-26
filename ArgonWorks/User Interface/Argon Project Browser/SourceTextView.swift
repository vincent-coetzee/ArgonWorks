//
//  SourceTextView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/3/22.
//

import Cocoa

class SourceTextView: NSTextView
    {
    public func endOfLineRect(forLine: Int) -> CGRect
        {
        var line = 0
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
        let rect = self.layoutManager!.boundingRect(forGlyphRange: range, in: self.textContainer!)
        return(rect)
        }
    }
