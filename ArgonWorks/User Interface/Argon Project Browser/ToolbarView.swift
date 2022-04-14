//
//  ToolbarView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/3/22.
//

import Cocoa

public class ToolbarView: BarView
    {
    public var target: AnyObject?
        {
        didSet
            {
            if let aTarget = self.target
                {
                for button in self.allButtons
                    {
                    button.target = aTarget
                    }
                }
            }
        }
        
    public var enabledValueModel: ValueModel = ValueHolder(value: nil)
        {
        didSet
            {
            for button in self.allButtons
                {
                button.enabledValueModel = self.enabledValueModel
                }
            }
        }
        
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.needsLayout = true
        self.textFontIdentifier = .toolbarLabelFont
        self.addTextLabel(atEdge: .left, key: "name", valueModel: ValueHolder(value: "Project"), textColorIdentifier: .toolbarLabelTextColor, borderColorIdentifier: .defaultBorderColor, borderWidth: 1, cornerRadius: 3, backgroundColorIdentifier: .labelBackgroundColor)
        self.addTextLabel(atEdge: .left, key: "warnings", valueModel: ValueHolder(value: "0 warnings"), textColorIdentifier: .toolbarLabelTextColor, borderColorIdentifier: .defaultBorderColor, borderWidth: 1, cornerRadius: 3, backgroundColorIdentifier: .labelBackgroundColor)
        self.addTextLabel(atEdge: .left, key: "errors", valueModel: ValueHolder(value: "0 errors"), textColorIdentifier: .toolbarLabelTextColor, borderColorIdentifier: .defaultBorderColor, borderWidth: 1, cornerRadius: 3, backgroundColorIdentifier: .labelBackgroundColor)
        self.addTextLabel(atEdge: .left, key: "records", valueModel: ValueHolder(value: "1 record"), textColorIdentifier: .toolbarLabelTextColor, borderColorIdentifier: .defaultBorderColor, borderWidth: 1, cornerRadius: 3, backgroundColorIdentifier: .labelBackgroundColor)
        self.addSpacer(atEdge: .right,key: "edge",ofWidth: 10)
        self.addActionButton(browserAction: .settingsAction,atEdge: .right,key: "settings",image: NSImage(named: "IconSettings")!,toolTip: "Configure...",target: self,action: #selector(ArgonBrowserViewController.onSettings))
        self.addSpacer(atEdge: .right,key: "edge+1",ofWidth: 20)
        self.addActionButton(browserAction: .newSymbolAction,atEdge: .right,key: "add",image: NSImage(named: "IconAdd")!,toolTip: "Add Record",target: self,action: #selector(ArgonBrowserViewController.onNewSymbol))
        self.addActionButton(browserAction: .deleteItemAction,atEdge: .right,key: "delete",image: NSImage(named: "IconDelete")!,toolTip: "Delete Record",target: self,action: #selector(ArgonBrowserViewController.onDeleteItem))
        self.addSpacer(atEdge: .right,key: "firstSpace",ofWidth: 20)
        self.addActionButton(browserAction: .newModuleAction,atEdge: .right,key: "module",image: NSImage(named: "IconModule")!,toolTip: "New Module",target: self,action: #selector(ArgonBrowserViewController.onNewModule))
        self.addActionButton(browserAction: .newCommentAction,atEdge: .right,key: "comment",image: NSImage(named: "IconFile")!,toolTip: "New Comment",target: self,action: #selector(ArgonBrowserViewController.onNewComment))
        self.addActionButton(browserAction: .newImportAction,atEdge: .right,key: "import",image: NSImage(named: "IconImport")!,toolTip: "New Import",target: self,action: #selector(ArgonBrowserViewController.onNewImport))
        self.addActionButton(browserAction: .newGroupAction,atEdge: .right,key: "group",image: NSImage(named: "IconGroup")!,toolTip: "New Group",target: self,action: #selector(ArgonBrowserViewController.onNewGroup))
        self.addSpacer(atEdge: .right,key: "secondSpace",ofWidth: 20)
        self.addActionButton(browserAction: .loadAction,atEdge: .right,key: "load",image: NSImage(named: "IconLoad")!,toolTip: "Open Project...",target: self,action: #selector(ArgonBrowserViewController.onLoad))
        self.addActionButton(browserAction: .saveAction,atEdge: .right,key: "save",image: NSImage(named: "IconSave")!,toolTip: "Save Project...",target: self,action: #selector(ArgonBrowserViewController.onSave))
        self.addSpacer(atEdge: .right,key: "thirdSpace",ofWidth: 20)
        self.addActionButton(browserAction: .buildAction,atEdge: .right,key: "build",image: NSImage(named: "IconBuild")!,toolTip: "Build Project",target: self,action: #selector(ArgonBrowserViewController.onBuild))
        self.drawsHorizontalBorder = true
        self.horizontalBorderColorIdentifier = .lineColor
        }
        
    @IBAction func someAction(_ sender: Any?)
        {
        }
    }

public class ToolbarButton: NSButton,Control,Dependent
    {
    public let dependentKey = DependentSet.nextDependentKey
    
    public var enabledValueModel: ValueModel = ValueHolder(value: true)
        {
        willSet
            {
            self.enabledValueModel.removeDependent(self)
            }
        didSet
            {
            self.enabledValueModel.addDependent(self)
            if let value = self.enabledValueModel.value as? BrowserActionSet
                {
                self.isEnabled = value.contains(self.browserAction)
                }
            }
        }
        
    public var browserAction = BrowserActionSet(rawValue: 0)
    
    public var valueModel: ValueModel = ValueHolder(value: "")
    
    public var key: String = ""
        
    public var textFontIdentifier: StyleFontIdentifier = .defaultFont
        {
        didSet
            {
            self.font = Palette.shared.font(for: self.textFontIdentifier)
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
        
    public func update(aspect: String,with argument: Any?,from sender: Model)
        {
        if aspect == "value" && sender.dependentKey == self.enabledValueModel.dependentKey
            {
            self.isEnabled = (argument as? BrowserActionSet)?.contains(self.browserAction) ?? false
            }
        }
    }
