//
//  ButtonBar.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/3/22.
//

import Cocoa

public class ButtonBar: BarView
    {
    private static let kButtonWidth:CGFloat = 16
    private static let kButtonSpacing:CGFloat = 2
    
    private var oldButton: NSButton?
    private var oldImage: NSImage?
    private var buttons = Array<NSButton>()
    private var rawImages = Array<NSImage>()
    private var buttonsByTag = Dictionary<String,NSButton>()
    
    public init(frame: NSRect)
        {
        super.init()
        self.drawsHorizontalBorder = true
        self.horizontalBorderColor = .argonDarkGray
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        }
        
    public func appendButton(tag: String,image: NSImage,toolTip: String,target: Any,action: Selector)
        {
        self.rawImages.append(image)
        image.isTemplate = true
        let newImage = image.image(withTintColor: NSColor.argonMidGray)
        let button = ToolbarButton(image: newImage, target: target, action:  action)
        button.toolTip = toolTip
        button.insets = NSEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.setButtonType(.onOff)
        button.isBordered = false
        button.bezelStyle = .roundRect
        button.imageScaling = .scaleProportionallyDown
        self.buttons.append(button)
        self.addSubview(button)
        self.buttonsByTag[tag] = button
        }
        
    public override func layout()
        {
        super.layout()
        let width = CGFloat(self.buttons.count) * Self.kButtonWidth + Self.kButtonSpacing * CGFloat(self.buttons.count - 1)
        let xDelta = (self.bounds.size.width - width) / 2
        var x = xDelta
        let y = (self.bounds.size.height - Self.kButtonWidth) / 2
        for button in self.buttons
            {
            button.frame = NSRect(x:x,y:y,width: Self.kButtonWidth,height: Self.kButtonWidth)
            x += Self.kButtonWidth + Self.kButtonSpacing
            }
        }
        
    public func highlightButton(_ button: NSButton)
        {
        if self.oldButton.isNotNil
            {
            let index = self.buttons.firstIndex(of: self.oldButton!)!
            self.oldButton?.image = self.rawImages[index]
            }
        self.oldButton = button
        let index = self.buttons.firstIndex(of: button)!
        let theImage = self.rawImages[index]
        theImage.isTemplate = true
        let newImage = theImage.image(withTintColor: NSColor.controlAccentColor)
        button.image = newImage
        }
        
    public func highlightButton(atTag: String)
        {
        self.highlightButton(self.buttonsByTag[atTag]!)
        }
        
    public func highlightButton(atIndex index: Int)
        {
        self.highlightButton(self.buttons[index])
        }
    }
