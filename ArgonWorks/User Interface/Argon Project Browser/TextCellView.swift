//
//  TextCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/3/22.
//

import Cocoa

public class TextCellView: NSView
    {
    public override var intrinsicContentSize: NSSize
        {
        let textSize = NSAttributedString(string: self.text,attributes: [.font: self.font,.foregroundColor: self.textColor]).size()
        var size = NSSize(width: 24,height: textSize.height + 8)
        size.width += self.image.isNil ? 0 : textSize.height + 4
        return(size)
        }
        
    public var indentColor: NSColor = NSColor.black
        {
        didSet
            {
            self.indentLayer.backgroundColor = self.indentColor.cgColor
            }
        }
        
    public var indentCornerRadius: CGFloat = 5
        {
        didSet
            {
            self.indentLayer.cornerRadius = self.indentCornerRadius
            }
        }
        
    public var font = NSFont(name: "SunSans-SemiBold",size: 10)!
        {
        didSet
            {
            self.textLayer.font = self.font
            self.textLayer.fontSize = self.font.pointSize
            }
        }
        
    public var textColor: NSColor = NSColor.white
        {
        didSet
            {
            self.textLayer.foregroundColor = self.textColor.cgColor
            }
        }
        
    private let image: NSImage?
    private let text: String
    private let indentLayer = CALayer()
    private let imageLayer = CALayer()
    private let textLayer = CATextLayer()
    
    init(image: NSImage? = nil,text: String)
        {
        self.image = image
        self.text = text
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.addSublayer(self.indentLayer)
        if self.image.isNotNil
            {
            self.layer?.addSublayer(self.imageLayer)
            self.imageLayer.contents = self.image!
            }
        self.layer?.addSublayer(self.textLayer)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout()
        {
        super.layout()
        let theBounds = self.bounds
        var offset = CGFloat(6)
        if self.image.isNotNil
            {
            self.imageLayer.frame = NSRect(x: offset,y: 4,width: theBounds.size.height - 8,height: theBounds.size.height - 8)
            offset += 4 + theBounds.size.height - 8
            }
        let size = NSAttributedString(string: self.text,attributes: [.font: self.font,.foregroundColor: self.textColor]).size()
        let delta = (theBounds.size.height - size.height) / 2
        self.textLayer.frame = NSRect(x: offset,y: delta,width: size.width,height: size.height)
        self.indentLayer.frame = NSRect(x: 3,y: 3,width: theBounds.size.width - 6,height: theBounds.size.height - 6)
        }
}
