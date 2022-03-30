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
            textSize.width += 6 + textSize.height
            }
        return(textSize)
        }
        
    public override var textFont: NSFont
        {
        didSet
            {
            self.textLayer.font = self.textFont
            self.textLayer.fontSize = self.textFont.pointSize
            }
        }
        
    public var iconTintColor: NSColor = NSColor.white
        {
        didSet
            {
            var image = self.imageValueModel.value as? NSImage
            image?.isTemplate = true
            image = image?.image(withTintColor: self.iconTintColor)
            self.imageLayer.contents = image
            }
        }
        
    public var textColor: NSColor = NSColor.white
        {
        didSet
            {
            self.textLayer.foregroundColor = self.textColor.cgColor
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
        self.textLayer.font = self.textFont
        self.textLayer.fontSize = self.textFont.pointSize
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout()
        {
        super.layout()
        let theBounds = self.bounds
        let textSize = NSAttributedString(string: self.text,attributes: [.font: self.textFont,.foregroundColor: self.textColor]).size()
        var offset = self.imageEdge == .left ? self.padding.width : theBounds.size.width - self.padding.width - theBounds.height
        self.imageLayer.frame = NSRect(x: offset,y: self.padding.height,width: self.bounds.size.height,height: self.bounds.size.height)
        offset += self.imageEdge == .left ? 6 + theBounds.size.height : -( 6 + textSize.width )
        self.textLayer.frame = NSRect(x: offset,y: self.padding.height,width: textSize.width,height: textSize.height)
        }
        
    public func update(aspect: String,with argument: Any?,from sender: Model)
        {
        if aspect == "value" && sender.dependentKey == self.imageValueModel.dependentKey
            {
            self.imageLayer.contents = self.image
            self.needsLayout =  true
            self.needsDisplay = true
            }
        else if aspect == "value" && sender.dependentKey == self.valueModel.dependentKey
            {
            self.textLayer.string = self.text
            self.needsLayout =  true
            self.needsDisplay = true
            }
        }
    }
