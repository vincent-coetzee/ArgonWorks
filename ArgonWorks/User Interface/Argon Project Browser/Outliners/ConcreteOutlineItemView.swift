//
//  ConcreteOutlineItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa

public class ConcreteOutlineItemView: NSTableCellView,OutlineItemView
    {
    public var textFont: NSFont = Palette.shared.font(for: .outlineTextFont)
        {
        didSet
            {
            self.textView.font = self.textFont
            self.needsLayout = true
            }
        }
        
    public var outlineItem: OutlineItem?
        {
        didSet
            {
            if self.outlineItem.isNotNil
                {
                self.update()
                }
            }
        }
        
    private let iconView: NSImageView
    private let textView: NSTextField
    private let systemView: NSImageView
    
    override init(frame: NSRect)
        {
        self.textView = NSTextField(frame: .zero)
        self.iconView = NSImageView(frame: .zero)
        self.systemView = NSImageView(frame: .zero)
        super.init(frame: frame)
        self.addSubview(self.textView)
        self.addSubview(self.iconView)
        self.addSubview(self.systemView)
        self.textView.isBezeled = false
        self.textView.isBordered = false
        self.textView.isEditable = false
        self.textView.drawsBackground = false
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update()
        {
        self.textView.stringValue = self.outlineItem!.label
        self.textView.font = Palette.shared.font(for: .textFont)
        self.iconView.image = self.outlineItem!.icon
        self.iconView.image!.isTemplate = true
        self.iconView.contentTintColor = Palette.shared.color(for: self.outlineItem!.iconTintIdentifier)
        self.systemView.isHidden = !self.outlineItem!.isSystemItem
        if self.outlineItem!.isSystemItem
            {
            self.systemView.image = NSImage(named: "IconSystem")!
            self.systemView.image!.isTemplate = true
            self.systemView.contentTintColor = Palette.shared.color(for: .systemTypeColor)
            }
        }
        
    public override func layout()
        {
        super.layout()
        let height = self.bounds.size.height
        self.iconView.frame = NSRect(x: height,y: 0,width: height,height: height).insetBy(dx: 1, dy: 0)
        self.systemView.frame = NSRect(x: 0,y:0,width: height,height: height).insetBy(dx: 1,dy: 0)
        let font = self.textFont.fontToFit(height: height)
        let string = self.textView.stringValue
        let size = NSAttributedString(string: string,attributes: [.font: font]).size()
        let delta = (height - size.height) / 2
        self.textView.frame = NSRect(x: height + height,y: delta,width: self.bounds.size.width - height,height: size.height)
        self.textView.font = font
        }
    }
