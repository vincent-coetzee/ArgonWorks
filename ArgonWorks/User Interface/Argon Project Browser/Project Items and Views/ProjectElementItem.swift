//
//  ProjectElementItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectElementItem: ProjectItem
    {
    public var sourceRecord: SourceRecord
        {
        get
            {
            self.sourceItem.sourceRecord
            }
        set
            {
            self.sourceItem.sourceRecord = newValue
            }
        }
        
    public override var allItems: ProjectItems
        {
        [self,self.sourceItem]
        }
        
    public var filename: String
        {
        "Element\(self.itemKey).bin"
        }
        
    public override var isElement: Bool
        {
        true
        }
        
    public var symbolValue: SymbolValue!
        {
        didSet
            {
            switch(self.symbolValue)
                {
                case .methodInstance(let instance):
                    self.label = "Method Instance \(instance.label)"
                    self.icon = instance.icon
                    self.iconTint = instance.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: instance.label,inColor: self.iconTint))
                    self.sourceItem.sourceRecord.primarySymbol = instance
                    instance.interfaceKey = self.itemKey
                case .enumeration(let enumeration,_,_):
                    self.label = "Enumeration \(enumeration.label)"
                    self.icon = enumeration.icon
                    self.iconTint = enumeration.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: enumeration.label,inColor: self.iconTint))
                    self.sourceItem.sourceRecord.primarySymbol = enumeration
                    enumeration.interfaceKey = self.itemKey
                case .class(let aClass):
                    self.icon = aClass.icon
                    self.iconTint = aClass.iconTint
                    self.label = "Class \(aClass.label)"
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aClass.label,inColor: self.iconTint))
                    self.sourceItem.sourceRecord.primarySymbol = aClass
                    aClass.interfaceKey = self.itemKey
                case .typeAlias(let aType):
                    self.label = "Type \(aType.label)"
                    self.icon = aType.icon
                    self.iconTint = aType.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aType.label,inColor: self.iconTint))
                    self.sourceItem.sourceRecord.primarySymbol = aType
                    aType.interfaceKey = self.itemKey
                default:
                    break
                }
            self.controller.updateHierarchy(itemKey: self.itemKey,symbolValue: self.symbolValue)
            }
        }
        
    public override var isExpandable: Bool
        {
        true
        }
        
    public override var childCount: Int
        {
        1
        }
        
    internal let sourceItem: ProjectSourceItem
    private var previousSource: String = ""
    
    public override var itemKey: Int
        {
        didSet
            {
            self.sourceItem.sourceRecord.itemKey = self.itemKey
            }
        }
    
    public override init(label: Label)
        {
        self.sourceItem = ProjectSourceItem(label: label)
        super.init(label: label)
        self.sourceItem.sourceRecord.elementItem = self
        self.versionState = self.sourceItem.versionState
        self.sourceItem.parentItem = self
        self.sourceItem.elementItem = self
        self.icon = NSImage(named: "IconMarker")!
        self.icon.isTemplate = true
        self.iconTint = SyntaxColorPalette.warningColor
        }
        
    public required init?(coder:NSCoder)
        {
        self.sourceItem = coder.decodeObject(forKey: "sourceItem") as! ProjectSourceItem
        super.init(coder: coder)
        self.versionState = self.sourceItem.sourceRecord.versionState
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.sourceItem,forKey: "sourceItem")
        super.encode(with: coder)
        }
        
    public override func _makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "Primary")
            {
            let view = ProjectElementItemView(frame: .zero,elementItem: self)
            view.item = self
            view.font = self.controller.sourceOutlinerFont
            view.viewText.stringValue = self.label
            view.viewText.textColor = NSColor.white
            view.viewImage.image = self.icon
            view.viewImage.image!.isTemplate = true
            view.viewImage.contentTintColor = self.iconTint
            return(view)
            }
        else
            {
            return(super._makeCellView(inOutliner: outliner, forColumn: columnIdentifier))
            }
        }
        
    private func updateCellViews(string attributedString: NSAttributedString)
        {
        let cellView = self.cellViews[NSUserInterfaceItemIdentifier(rawValue: "Primary")] as? ProjectItemView
        cellView?.viewText.attributedStringValue = attributedString
//        cellView?.viewText.stringValue = attributedString.string
        self.icon.isTemplate = true
        cellView?.viewImage.image = self.icon
        cellView?.viewImage.contentTintColor = self.iconTint
        }
    
    public func attributedString(_ string: String,highlight: String,inColor: NSColor) -> NSAttributedString
        {
        let range = string.range(of: highlight)!
        let start = string.distance(from: string.startIndex, to: range.lowerBound)
        let end = string.distance(from: string.startIndex,to: range.upperBound)
        let localRange = NSRange(location: start, length: end - start)
        let attributedString = NSMutableAttributedString(string: string,attributes: [.font: self.controller.sourceOutlinerFont!,.foregroundColor: NSColor.white])
        let attributes:[NSAttributedString.Key:Any] = [.foregroundColor: inColor]
        attributedString.setAttributes(attributes,range: localRange)
        return(attributedString)
        }
        
    public override func child(atIndex:Int) -> ProjectItem
        {
        self.sourceItem.controller = self.controller
        return(self.sourceItem)
        }
        
    public func sourceEditingDidEnd(_ sourceItem: ProjectSourceItem)
        {
        if self.previousSource != sourceItem.sourceRecord.text
            {
            self.markVersionState(as: .modified)
            }
        }
        
    public func sourceEditingDidBegin(_ sourceItem: ProjectSourceItem)
        {
        self.previousSource = sourceItem.sourceRecord.text
        }
    }
