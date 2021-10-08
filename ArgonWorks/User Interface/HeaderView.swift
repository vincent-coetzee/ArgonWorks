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
//        let font = Palette.shared.headerFont!
        let font = NSFont(name: "OpenSans-Bold",size: 24)!
        print("FONT IS SF Pro Bold 18 point")
        print("FONT DESCENDER \(font.descender)")
        print("FONT ASCENDER \(font.ascender)")
        print("FONT CAP HEIGHT \(font.capHeight)")
        print("FONT POINT SIZE \(font.pointSize)")
        print("FONT X HEIGHT \(font.xHeight)")
        print("BOUNDING RECT FOR FONT \(font.boundingRectForFont)")
        let adjustment = font.descender
        let frame = self.bounds
        let size = (NSAttributedString(string: self.label.stringValue,attributes: [.font: self.label.font!])).size()
        print("STRING SIZE \(size)")
        let y = (frame.size.height - size.height) / 2.0
        self.label.frame = NSRect(x: 5,y: y,width: frame.size.width, height: size.height)
        }
        
    private func initSubviews()
        {
        let palette = Palette.shared
        self.wantsLayer = true
        self.layer?.backgroundColor = palette.headerColor.cgColor
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.label.textColor = palette.headerTextColor
        self.label.font = palette.headerFont
        self.label.isEditable = false
        self.label.drawsBackground = false
        self.label.isSelectable = false
        self.label.isBezeled = false
        }
    }
