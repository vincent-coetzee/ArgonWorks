//
//  ProjectCommentItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/4/22.
//

import Cocoa

public class ProjectCommentItemView: NSTableCellView,NSTextViewDelegate
    {
    public var item: ProjectCommentItem!
        {
        didSet
            {
            self.commentView.string = self.item.text
            self.commentView.delegate = self
            self.iconView.image = self.item.icon
            self.iconView.image!.isTemplate = true
            self.iconView.contentTintColor = Palette.shared.color(for: self.item.iconTintIdentifier)
            }
        }
        
    private let iconView: NSImageView
    private let commentView: NSTextView
    
    public init(frame: NSRect,font: NSFont)
        {
        self.iconView = NSImageView(frame: .zero)
        self.commentView = NSTextView(frame: .zero)
        super.init(frame: frame)
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.commentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.iconView)
        self.addSubview(self.commentView)
        self.commentView.font = font
        self.commentView.backgroundColor = Palette.shared.color(for: .recordBackgroundColor)
        self.commentView.textColor = Palette.shared.color(for: .commentColor)
        self.layoutViews(font: font)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    private func layoutViews(font: NSFont)
        {
        self.iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.iconView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.iconView.widthAnchor.constraint(equalTo: self.iconView.heightAnchor).isActive = true
        self.iconView.heightAnchor.constraint(equalToConstant: Palette.shared.float(for: .recordIconHeight)).isActive = true
        self.commentView.leadingAnchor.constraint(equalTo: self.iconView.trailingAnchor, constant: 4).isActive = true
        self.commentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.commentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.commentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        }
        
    public func textDidChange(_ notification: Notification)
        {
        self.item.sourceDidChange(self,textView: self.commentView)
        }
        
    public override func draw(_ rect: NSRect)
        {
        super.draw(rect)
        Palette.shared.color(for: .lineColor).set()
        NSBezierPath.defaultLineWidth = 1
        NSBezierPath.strokeLine(from: NSPoint(x: 0,y: 0), to: NSPoint(x: self.bounds.size.width,y:0))
        NSBezierPath.strokeLine(from: NSPoint(x: 0,y: self.bounds.size.height), to: NSPoint(x: self.bounds.size.width,y:self.bounds.size.height))
        }
    }
