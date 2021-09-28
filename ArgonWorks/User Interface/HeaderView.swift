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
        let frame = self.bounds
        let size = (NSAttributedString(string: self.label.stringValue,attributes: [.font: self.label.font])).size()
        let y = (frame.size.height - frame.size.height) / 2.0 + 4.5
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
