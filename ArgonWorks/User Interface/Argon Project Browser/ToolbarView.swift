//
//  ToolbarView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/3/22.
//

import Cocoa

public class ToolbarView: BarView
    {
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.needsLayout = true
        self.textFont = NSFont(name: "SunSans-Demi",size: 11)!
        self.addTextLabel(atEdge: .left, key: "name", valueModel: ValueHolder(value: "Project"), textColor: NSColor.argonLightGray, borderColor: NSColor.argonDarkerGray, borderWidth: 1, cornerRadius: 3, backgroundColor: .argonDarkerGray)
        self.addTextLabel(atEdge: .left, key: "warnings", valueModel: ValueHolder(value: "0 warnings"), textColor: NSColor.argonLightGray, borderColor: NSColor.argonDarkerGray, borderWidth: 1, cornerRadius: 3, backgroundColor: .argonDarkerGray)
        self.addTextLabel(atEdge: .left, key: "errors", valueModel: ValueHolder(value: "0 errors"), textColor: NSColor.argonLightGray, borderColor: NSColor.argonDarkerGray, borderWidth: 1, cornerRadius: 3, backgroundColor: .argonDarkerGray)
        self.addTextLabel(atEdge: .left, key: "records", valueModel: ValueHolder(value: "1 record"), textColor: NSColor.argonLightGray, borderColor: NSColor.argonDarkerGray, borderWidth: 1, cornerRadius: 3, backgroundColor: .argonDarkerGray)
        self.addSpacer(atEdge: .right,key: "edge",ofWidth: 10)
        self.addActionButton(atEdge: .right,key: "settings",image: NSImage(named: "IconSettings")!,toolTip: "Configure...",target: self,action: #selector(self.someAction))
        self.addSpacer(atEdge: .right,key: "edge+1",ofWidth: 20)
        self.addActionButton(atEdge: .right,key: "add",image: NSImage(named: "IconAdd")!,toolTip: "Add Record",target: self,action: #selector(self.someAction))
        self.addActionButton(atEdge: .right,key: "delete",image: NSImage(named: "IconDelete")!,toolTip: "Delete Record",target: self,action: #selector(self.someAction))
        self.addSpacer(atEdge: .right,key: "firstSpace",ofWidth: 20)
        self.addActionButton(atEdge: .right,key: "module",image: NSImage(named: "IconModule")!,toolTip: "New Module",target: self,action: #selector(self.someAction))
        self.addActionButton(atEdge: .right,key: "comment",image: NSImage(named: "IconFile")!,toolTip: "New Comment",target: self,action: #selector(self.someAction))
        self.addActionButton(atEdge: .right,key: "slot",image: NSImage(named: "IconSlot")!,toolTip: "New Module Slot",target: self,action: #selector(self.someAction))
        self.addActionButton(atEdge: .right,key: "group",image: NSImage(named: "IconGroup")!,toolTip: "New Group",target: self,action: #selector(self.someAction))
        self.addSpacer(atEdge: .right,key: "secondSpace",ofWidth: 20)
        self.addActionButton(atEdge: .right,key: "load",image: NSImage(named: "IconLoad")!,toolTip: "Open Project...",target: self,action: #selector(self.someAction))
        self.addActionButton(atEdge: .right,key: "save",image: NSImage(named: "IconSave")!,toolTip: "Save Project...",target: self,action: #selector(self.someAction))
        self.addSpacer(atEdge: .right,key: "thirdSpace",ofWidth: 20)
        self.addActionButton(atEdge: .right,key: "build",image: NSImage(named: "IconBuild")!,toolTip: "Build Project",target: self,action: #selector(self.someAction))
        self.drawsHorizontalBorder = true
        self.horizontalBorderColor = .argonDarkGray
        }
        
    @IBAction func someAction(_ sender: Any?)
        {
        }
    }

public class ToolbarButton: NSButton,Control
    {
    public var valueModel: ValueModel = ValueHolder(value: "")
    
    public var key: String = ""
        
    public var textFont: NSFont = NSFont.systemFont(ofSize: 10)
        {
        didSet
            {
            self.font = self.textFont
            }
        }
        
    public var insets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public override func draw(_ rect: NSRect)
        {
        let oldBounds = self.bounds
        var newBounds = self.bounds
        newBounds.origin.x += self.insets.left
        newBounds.origin.y += self.insets.top
        newBounds.size.width -= self.insets.left + self.insets.right
        newBounds.size.height -= self.insets.top + self.insets.bottom
        self.bounds = newBounds
        super.draw(rect)
        self.bounds = oldBounds
        }
    }
