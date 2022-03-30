//
//  BarView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/3/22.
//

import Cocoa

public class BarView: CustomView
    {
    public enum ViewEdge
        {
        case left
        case right
        }
        
    public override var textFont: NSFont
        {
        didSet
            {
            for control in self.controlsByKey.values
                {
                let hack = control
                hack.textFont = self.textFont
                }
            }
        }
        
    private var controlsByKey: Dictionary<String,Control> = [:]
    private var nextRightAnchor: NSLayoutXAxisAnchor!
    private var nextLeftAnchor: NSLayoutXAxisAnchor!
    
    public init()
        {
        super.init(frame: .zero)
        self.nextRightAnchor = self.trailingAnchor
        self.nextLeftAnchor = self.leadingAnchor
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        self.nextRightAnchor = self.trailingAnchor
        self.nextLeftAnchor = self.leadingAnchor
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.nextRightAnchor = self.trailingAnchor
        self.nextLeftAnchor = self.leadingAnchor
        }
        
    public func control(atKey: String) -> Control?
        {
        self.controlsByKey[atKey]
        }
        
    public override func draw(_ rect: NSRect)
        {
        super.draw(rect)
        if self.drawsHorizontalBorder
            {
            self.horizontalBorderColor.set()
            let path = NSBezierPath()
            path.move(to: NSPoint(x: 0,y: 1))
            path.line(to: NSPoint(x: self.bounds.size.width,y: 1))
            path.move(to: NSPoint(x: 0,y:self.bounds.size.height - 1))
            path.line(to:  NSPoint(x: self.bounds.size.width,y: self.bounds.size.height - 1))
            path.lineWidth = 1
            path.stroke()
            }
        }
        
    public func addTextLabel(atEdge: ViewEdge,key: String,valueModel: ValueModel,textColor: NSColor,borderColor: NSColor = NSColor.argonDarkerGray,borderWidth: CGFloat = 1,cornerRadius: CGFloat = 3,backgroundColor: NSColor = NSColor.argonDarkerGray)
        {
        let newLabel = PaddedTextLabel(text: "Project: Name", textFont: self.textFont, textColor: NSColor.argonLightGray,padding: NSSize(width: 20,height: 5),alignment: .left)
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(newLabel)
        if atEdge == .left
            {
            newLabel.leadingAnchor.constraint(equalTo: self.nextLeftAnchor,constant: 4).isActive = true
            self.nextLeftAnchor = newLabel.trailingAnchor
            }
        else
            {
            newLabel.trailingAnchor.constraint(equalTo: self.nextRightAnchor,constant: -4).isActive = true
            self.nextRightAnchor = newLabel.leadingAnchor
            }
        newLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 3).isActive = true
        newLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -3).isActive = true
        newLabel.cornerRadius = cornerRadius
        newLabel.borderColor = borderColor
        newLabel.borderWidth = borderWidth
        newLabel.backgroundColor = backgroundColor
        self.controlsByKey[key] = newLabel
        }
        
    public func addSpacer(atEdge: ViewEdge,key: String,ofWidth: CGFloat)
        {
        let space = Spacer(frame: .zero)
        space.key = key
        self.addSubview(space)
        space.translatesAutoresizingMaskIntoConstraints = false
        if atEdge == .left
            {
            space.leadingAnchor.constraint(equalTo: self.nextLeftAnchor,constant: 4).isActive = true
            self.nextLeftAnchor = space.trailingAnchor
            }
        else
            {
            space.trailingAnchor.constraint(equalTo: self.nextRightAnchor,constant: -4).isActive = true
            self.nextRightAnchor = space.leadingAnchor
            }
        space.widthAnchor.constraint(equalToConstant: ofWidth).isActive = true
        space.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        space.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.controlsByKey[key] = space
        }
        
    public func addActionButton(atEdge: ViewEdge,key: String,image: NSImage,toolTip: String,target: Any,action: Selector)
        {
        image.isTemplate = true
        let button = ToolbarButton(image: image.image(withTintColor: NSColor.argonMidGray), target: target, action: action)
        button.toolTip = toolTip
        button.insets = NSEdgeInsets(top: 2, left: 1, bottom: 2, right: 1)
        button.cell?.isBezeled = false
        button.isBordered = false
        button.imageScaling = .scaleProportionallyDown
        let width = self.bounds.size.height * 0.65
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        if atEdge == .left
            {
            button.leadingAnchor.constraint(equalTo: self.nextLeftAnchor).isActive = true
            self.nextLeftAnchor = button.trailingAnchor
            }
        else
            {
            button.trailingAnchor.constraint(equalTo: self.nextRightAnchor).isActive = true
            self.nextRightAnchor = button.leadingAnchor
            }
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor,constant: 4).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -4).isActive = true
        self.controlsByKey[key] = button
        }
    }

fileprivate class Spacer: NSView,Control
    {
    public var key: String = ""
    public var textFont: NSFont = NSFont.systemFont(ofSize: 10)
    public var valueModel: ValueModel = ValueHolder(value: "")
    }
