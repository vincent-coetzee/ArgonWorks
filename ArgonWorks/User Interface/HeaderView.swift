//
//  HeaderView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Cocoa

@IBDesignable
public class HeaderView: NSView,Pane
    {
    @IBInspectable
    public var text: String?
        {
        get
            {
            return(self.label.stringValue)
            }
        set
            {
            self.label.stringValue = newValue ?? ""
            }
        }
        
    public var layoutFrame: LayoutFrame = .zero
    
    private let label: NSTextField
    private let shapeLayer = CAShapeLayer()
    
    @IBInspectable
    public var headerColor: NSColor = Palette.shared.headerColor
        {
        didSet
            {
            self.wantsLayer = true
            self.layer?.backgroundColor = self.headerColor.cgColor
            }
        }
        
    @IBInspectable
    public var textColor: NSColor = Palette.shared.headerTextColor
        {
        didSet
            {
            self.label.textColor = self.textColor
            }
        }
        
    @IBInspectable
    private var textFont: NSFont = Palette.shared.headerFont!
        {
        didSet
            {
            self.label.font = self.textFont
            }
        }
        
    public override init(frame: NSRect)
        {
        self.label = NSTextField(frame: .zero)
        super.init(frame: frame)
        self.initSubviews()
        self.label.stringValue = "Header Label"
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.initSubviews()
        }
        
    public override func prepareForInterfaceBuilder()
        {
        super.prepareForInterfaceBuilder()
        }

    required init?(coder: NSCoder)
        {
        self.label = NSTextField(frame: .zero)
        super.init(coder: coder)
        self.initSubviews()
        self.label.stringValue = "Header Label"
        }
    
    public override func layout()
        {
        let frame = self.bounds
        let size = (NSAttributedString(string: self.label.stringValue,attributes: [.font: self.label.font!])).size()
        let y = (frame.size.height - size.height) / 2.0
        self.label.frame = NSRect(x: 5,y: y,width: frame.size.width, height: size.height)
        self.label.font = Palette.shared.argonHeaderFont
        shapeLayer.backgroundColor = Palette.shared.argonSecondaryColor.cgColor
        shapeLayer.path = NSBezierPath.init(roundedRect: self.bounds.insetBy(dx: 2, dy: 2), xRadius: 0, yRadius: 0).cgPath
        shapeLayer.frame = self.bounds
        }
        
    private func initSubviews()
        {
        let palette = Palette.shared
        self.wantsLayer = true
//        self.layer?.backgroundColor = palette.headerColor.cgColor
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.label.textColor = Palette.shared.argonContrastingTextColor
        self.label.font = palette.headerFont
        self.label.isEditable = false
        self.label.drawsBackground = false
        self.label.isSelectable = false
        self.label.isBezeled = false
        self.wantsLayer = true
        self.layer?.backgroundColor = Palette.shared.argonSecondaryColor.cgColor
        self.layer?.cornerRadius = 2
        self.layer?.addSublayer(shapeLayer)
        shapeLayer.backgroundColor = Palette.shared.argonSecondaryColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = NSColor.black.cgColor
        shapeLayer.fillColor = Palette.shared.argonSecondaryColor.cgColor
        shapeLayer.path = NSBezierPath.init(roundedRect: self.bounds.insetBy(dx: 2, dy: 2), xRadius: 0, yRadius: 40).cgPath
        shapeLayer.frame = self.bounds
        }
    }
