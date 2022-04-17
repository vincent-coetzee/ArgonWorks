//
//  NSFont+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/3/22.
//

import Cocoa

extension NSFont
    {
//    public var lineHeight: CGFloat
//        {
//        self.ascender + abs(self.descender) + self.leading
//        }

    public var lineHeight: CGFloat
        {
        let string = "The quick brown fox jumped over the lazy dog. THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG."
        let attributedString = NSAttributedString(string: string,attributes: [.font: self])
        let size = attributedString.size()
        return(size.height)
        }
        
    public func withPointSize(_ size: CGFloat) -> NSFont
        {
        return(NSFont(name: self.fontName,size: size)!)
        }
        
    public func boldFont() -> NSFont
        {
        NSFontManager.shared.convert(self,toHaveTrait: .boldFontMask)
        }
        
    public func fontToFit(height: CGFloat) -> NSFont
        {
        return(NSFont(name: self.fontName,size: height - 2)!)
        }
    }
