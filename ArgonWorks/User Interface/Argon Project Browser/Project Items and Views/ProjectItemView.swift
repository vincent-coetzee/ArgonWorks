//
//  ProjectItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectItemView: NSTableCellView,NSTextFieldDelegate
    {
    public var item: ProjectItem!
    public let viewImage: NSImageView
    public let viewText: NSTextField
    public var font:NSFont!
        {
        didSet
            {
            self.viewText.font = self.font
            }
        }
        
    internal var viewTextTrailingConstraint: NSLayoutConstraint!
    
    override init(frame: NSRect)
        {
        self.viewImage = NSImageView(frame: .zero)
        self.viewText = NSTextField(frame: .zero)
        super.init(frame: frame)
        self.addSubview(self.viewImage)
        self.addSubview(self.viewText)
        self.viewText.isEditable = true
        self.viewText.isBezeled = false
        self.viewText.drawsBackground = false
        self.viewText.delegate = self
        self.viewImage.imageScaling = .scaleProportionallyDown
        self.initConstraints()
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    internal func initConstraints()
        {
        self.viewImage.translatesAutoresizingMaskIntoConstraints = false
        self.viewText.translatesAutoresizingMaskIntoConstraints = false
        self.viewImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewImage.widthAnchor.constraint(equalTo: self.heightAnchor,constant: 3).isActive = true
        self.viewText.leadingAnchor.constraint(equalTo: self.viewImage.trailingAnchor,constant: 4).isActive = true
        self.viewTextTrailingConstraint = self.viewText.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        self.viewTextTrailingConstraint.isActive = true
        self.viewText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewText.backgroundColor = .red
        }
        
//    public override func layout()
//        {
//        super.layout()
//        let width = self.bounds.size.width - ProjectItem.kIconHeight - 4
//        let height = self.bounds.size.height
//        self.viewImage.frame = NSRect(x: 0,y: 0,width: ProjectItem.kIconHeight,height: ProjectItem.kIconHeight)
//        let stringSize = self.item.measureString(self.viewText.stringValue, withFont: self.font, inWidth: width)
//        let delta = (height - stringSize.height) / 2
//        self.viewText.frame = NSRect(x: ProjectItem.kIconHeight + 4,y:delta,width: width,height: height)
//        }
        
    public func controlTextDidChange(_ notification: Notification)
        {
        self.item.label = self.viewText.stringValue
        }
    }
