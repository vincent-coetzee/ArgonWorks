//
//  PaddedTextLayer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/3/22.
//

import Cocoa

public class PaddedTextLabel: NSView,Dependent,Control
    {
    public var key: String = ""
    
    public enum TextAlignment
        {
        case left
        case center
        case right
        }
        
    public let dependentKey = DependentSet.nextDependentKey
    
    public var valueModel: ValueModel = ValueHolder(value: "")
        {
        willSet
            {
            self.valueModel.removeDependent(self)
            }
        didSet
            {
            self.valueModel.addDependent(self)
            self.stringValue = self.valueModel.stringValue
            }
        }
        
    public var stringValue: String? = ""
        {
        didSet
            {
            self.textLayer.string = self.stringValue
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
            }
        }
        
    public var backgroundColor: NSColor = NSColor.black
        {
        didSet
            {
            self.layer?.backgroundColor = self.backgroundColor.cgColor
            }
        }
        
    public var borderWidth: CGFloat = 0
        {
        didSet
            {
            self.layer?.borderWidth = self.borderWidth
            }
        }
        
    public var borderColor: NSColor = NSColor.clear
        {
        didSet
            {
            self.layer?.borderColor = self.borderColor.cgColor
            }
        }
        
    public var cornerRadius: CGFloat = 0
        {
        didSet
            {
            self.layer?.cornerRadius = self.cornerRadius
            }
        }
        
    public override var intrinsicContentSize: NSSize
        {
        var size = NSAttributedString(string: (self.textLayer.string as? String) ?? "",attributes: [.font: self.textFont,.foregroundColor: self.textLayer.foregroundColor]).size()
        size.width += self.padding.width * 2
        size.height += self.padding.height * 2
        return(size)
        }
        
    public var textFont: NSFont
        {
        didSet
            {
            self.textLayer.fontSize = self.textFont.pointSize
            self.textLayer.font = self.textFont
            }
        }
        
    public var textColor: NSColor = NSColor.white
        {
        didSet
            {
            self.textLayer.foregroundColor = self.textColor.cgColor
            }
        }
        
    internal let textLayer = CATextLayer()
    private let padding: NSSize
    public let alignment: TextAlignment
    
    init(text: String,textFont: NSFont,textColor: NSColor,padding: NSSize = .zero,alignment: TextAlignment = .left)
        {
        self.alignment = alignment
        self.padding = padding
        self.textFont = textFont
        super.init(frame: .zero)
        self.textLayer.string = text
        self.valueModel = ValueHolder(value: text)
        self.textLayer.font = textFont
        self.textLayer.fontSize = textFont.pointSize
        self.textLayer.foregroundColor = textColor.cgColor
        self.textLayer.masksToBounds = true
        self.wantsLayer = true
        self.layer?.addSublayer(self.textLayer)
        self.textLayer.contentsScale = NSScreen.main!.backingScaleFactor
        self.stringValue = self.valueModel.stringValue
        }
    
    init(model: ValueModel,textFont: NSFont,textColor: NSColor,padding: NSSize = .zero,alignment: TextAlignment = .left)
        {
        self.alignment = alignment
        self.padding = padding
        self.textFont = textFont
        super.init(frame: .zero)
        self.textLayer.string = model.value as? String
        self.valueModel = model
        self.textLayer.font = textFont
        self.textLayer.fontSize = textFont.pointSize
        self.textLayer.foregroundColor = textColor.cgColor
        self.textLayer.masksToBounds = true
        self.wantsLayer = true
        self.layer?.addSublayer(self.textLayer)
        self.textLayer.contentsScale = NSScreen.main!.backingScaleFactor
        self.stringValue = self.valueModel.stringValue
        }
        
    public override func layout()
        {
        super.layout()
        let size = NSAttributedString(string: (self.textLayer.string as? String) ?? "",attributes: [.font: self.textFont,.foregroundColor: self.textLayer.foregroundColor]).size()
        var xDelta:CGFloat = 0
        switch(self.alignment)
            {
            case .left:
                xDelta = 6
            case .center:
                xDelta = (self.bounds.size.width - size.width) / 2
            case .right:
                xDelta = self.bounds.size.width - size.width - 6
            }
        let yDelta = (self.bounds.size.height - size.height) / 2 + 1
        self.textLayer.frame = NSRect(x: xDelta,y: yDelta,width: size.width,height: size.height)
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(aspect:String,with: Any?,from: Model)
        {
        self.stringValue = with as? String
        }
}
