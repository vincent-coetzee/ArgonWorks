//
//  TextCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/3/22.
//

import Cocoa

public class IconLabelView: CustomView,Control,Dependent
    {
    public let dependentKey = DependentSet.nextDependentKey
    
    public var key: String = ""

    
    public override var intrinsicContentSize: NSSize
        {
        var textSize = NSAttributedString(string: self.text,attributes: [.font: self.textFont,.foregroundColor: self.textColor]).size()
        textSize.width += self.padding.width * 2
        textSize.height += self.padding.height * 2
        if self.image.isNotNil
            {
            textSize.width += self.padding.width + textSize.height
            }
        return(textSize)
        }
        
    private var textColor: NSColor
        {
        Palette.shared.color(for: self.textColorIdentifier)
        }
        
    public override var textFontIdentifier: StyleFontIdentifier
        {
        didSet
            {
            let font = Palette.shared.font(for: self.textFontIdentifier)
            self.textLayer.font = font
            self.textLayer.fontSize = font.pointSize
            self.invalidateIntrinsicContentSize()
            }
        }
        
    public var iconTintColorValueModel: ValueModel = ValueHolder(value: StyleColorIdentifier.defaultColor)
        {
        willSet
            {
            self.iconTintColorValueModel.removeDependent(self)
            }
        didSet
            {
            self.iconTintColorValueModel.addDependent(self)
            self.iconTintColorIdentifier = self.iconTintColorValueModel.value as? StyleColorIdentifier
            }
        }
        
    public var iconTintColorIdentifier: StyleColorIdentifier?
        {
        didSet
            {
            if let identifier = self.iconTintColorIdentifier
                {
                var image = self.imageValueModel.value as? NSImage
                image?.isTemplate = true
                image = image?.image(withTintColor: Palette.shared.color(for: identifier))
                self.imageLayer.contents = image
                }
            }
        }
        
    private var textFont: NSFont
        {
        Palette.shared.font(for: self.textFontIdentifier)
        }
        
    public var textColorIdentifier: StyleColorIdentifier = .textColor
        {
        didSet
            {
            self.textLayer.foregroundColor = Palette.shared.color(for: self.textColorIdentifier).cgColor
            }
        }
        
    private var image: NSImage?
        {
        self.imageValueModel.value as? NSImage
        }
        
    private var text: String
        {
        (self.valueModel.value as? String) ?? ""
        }
        
    public var valueModel: ValueModel
        {
        willSet
            {
            self.valueModel.removeDependent(self)
            }
        didSet
            {
            self.valueModel.addDependent(self)
            self.textLayer.string = self.text
            self.needsLayout = true
            self.needsDisplay = true
            }
        }
        
    public var imageValueModel: ValueModel
        {
        willSet
            {
            self.imageValueModel.removeDependent(self)
            }
        didSet
            {
            self.imageValueModel.addDependent(self)
            self.imageLayer.contents = self.image
            self.needsLayout = true
            self.needsDisplay = true
            }
        }
        
    private let imageLayer = CALayer()
    private let textLayer = CATextLayer()
    private let imageEdge: BarView.ViewEdge
    private let padding: NSSize
    
    init(image: NSImage,imageEdge: BarView.ViewEdge,text: String,padding: NSSize = .zero)
        {
        self.padding = padding
        self.imageEdge = imageEdge
        self.imageValueModel = ValueHolder(value: image)
        self.valueModel = ValueHolder(value: text)
        super.init(frame: .zero)
        self.imageValueModel.addDependent(self)
        self.valueModel.addDependent(self)
        self.wantsLayer = true
        self.layer?.addSublayer(self.imageLayer)
        self.layer?.addSublayer(self.textLayer)
        self.setValues()
        }
        
    init(imageValueModel: ValueModel,imageEdge: BarView.ViewEdge,valueModel: ValueModel,padding: NSSize = .zero)
        {
        self.padding = padding
        self.imageEdge = imageEdge
        self.imageValueModel = imageValueModel
        self.valueModel = valueModel
        super.init(frame: .zero)
        self.imageValueModel.addDependent(self)
        self.valueModel.addDependent(self)
        self.wantsLayer = true
        self.layer?.addSublayer(self.imageLayer)
        self.layer?.addSublayer(self.textLayer)
        self.setValues()
        }
        
    private func setValues()
        {
        self.imageLayer.contents = self.imageValueModel.value as! NSImage
        self.textLayer.string = self.valueModel.value as? String
        let font = self.textFont
        self.textLayer.font = font
        self.textLayer.fontSize = font.pointSize
        }
    
    private func imageRect() -> NSRect
        {
        let height = self.bounds.size.height
        var rect = NSRect(x: 0,y: 0,width: height,height: height).insetBy(dx: self.padding.width, dy: self.padding.height)
        if self.imageEdge == .left
            {
            return(rect)
            }
        rect.origin.x = self.bounds.size.width - rect.size.width
        return(rect)
        }
        
    private func textRect() -> NSRect
        {
        let textSize = NSAttributedString(string: self.text,attributes: [.font: self.textFont,.foregroundColor: self.textColor]).size()
        let imageRect = self.imageRect()
        let delta = (self.bounds.size.height - textSize.height) / 2
        if self.imageEdge == .left
            {
            let rect = NSRect(x: imageRect.maxX + self.padding.width,y: delta,width: textSize.width,height: textSize.height)
            return(rect)
            }
        let rect = NSRect(x: imageRect.minX - self.padding.width - textSize.width,y: delta,width: textSize.width,height: textSize.height)
        return(rect)
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout()
        {
        super.layout()
        self.imageLayer.frame = self.imageRect()
        self.textLayer.frame = self.textRect()
        }
        
    public func update(aspect: String,with argument: Any?,from sender: Model)
        {
        if aspect == "value" && sender.dependentKey == self.imageValueModel.dependentKey
            {
            self.imageLayer.contents = self.image
            self.invalidateIntrinsicContentSize()
            self.needsLayout =  true
            self.needsDisplay = true
            }
        else if aspect == "value" && sender.dependentKey == self.valueModel.dependentKey
            {
            self.textLayer.string = self.text
            self.invalidateIntrinsicContentSize()
            self.needsLayout =  true
            self.needsDisplay = true
            }
        else if aspect == "value" && sender.dependentKey == self.iconTintColorValueModel.dependentKey
            {
            self.iconTintColorIdentifier = self.iconTintColorValueModel.value as? StyleColorIdentifier
            self.needsLayout =  true
            self.needsDisplay = true
            }
        }
    }
