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
                    self.iconTintIdentifier = .methodColor
                    self.updateCellViews(string: self.attributedString(self.label,highlight: instance.label,inColor: self.iconTintIdentifier))
                    self.sourceItem.sourceRecord.primarySymbol = instance
                    instance.itemKey = self.itemKey
                case .enumeration(let enumeration):
                    self.label = "Enumeration \(enumeration.label)"
                    self.icon = enumeration.icon
                    self.iconTintIdentifier = .enumerationColor
                    self.updateCellViews(string: self.attributedString(self.label,highlight: enumeration.label,inColor: self.iconTintIdentifier))
                    self.sourceItem.sourceRecord.primarySymbol = enumeration
                    enumeration.itemKey = self.itemKey
                case .class(let aClass):
                    self.icon = aClass.icon
                    self.iconTintIdentifier = .classColor
                    self.label = "Class \(aClass.label)"
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aClass.label,inColor: self.iconTintIdentifier))
                    self.sourceItem.sourceRecord.primarySymbol = aClass
                    aClass.itemKey = self.itemKey
                case .typeAlias(let aType):
                    self.label = "Type \(aType.label)"
                    self.icon = aType.icon
                    self.iconTintIdentifier = .typeColor
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aType.label,inColor: self.iconTintIdentifier))
                    self.sourceItem.sourceRecord.primarySymbol = aType
                    aType.itemKey = self.itemKey
                default:
                    break
                }
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
        self.iconTintIdentifier = .warningColor
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
            view.font = Palette.shared.font(for: self.fontIdentifier)
            view.viewText.stringValue = self.label
            view.viewText.textColor = Palette.shared.color(for: self.textColorIdentifier)
            view.viewImage.image = self.icon
            view.viewImage.image!.isTemplate = true
            view.viewImage.contentTintColor = Palette.shared.color(for: self.iconTintIdentifier)
            return(view)
            }
        else
            {
            return(super._makeCellView(inOutliner: outliner, forColumn: columnIdentifier))
            }
        }
        
    private func updateCellViews(string attributedString: NSAttributedString)
        {
        let cellView = self.cellViews[NSUserInterfaceItemIdentifier(rawValue: "Primary")]?.tableCellView as? ProjectItemView
        cellView?.viewText.attributedStringValue = attributedString
//        cellView?.viewText.stringValue = attributedString.string
        self.icon.isTemplate = true
        cellView?.viewImage.image = self.icon
        cellView?.viewImage.contentTintColor = Palette.shared.color(for: self.iconTintIdentifier)
        }
    
    public func attributedString(_ string: String,highlight: String,inColor: StyleIdentifier) -> NSAttributedString
        {
        let range = string.range(of: highlight)!
        let start = string.distance(from: string.startIndex, to: range.lowerBound)
        let end = string.distance(from: string.startIndex,to: range.upperBound)
        let localRange = NSRange(location: start, length: end - start)
        let attributedString = NSMutableAttributedString(string: string,attributes: [.font: self.controller.sourceOutlinerFont!,.foregroundColor: Palette.shared.color(for: self.textColorIdentifier)])
        let attributes:[NSAttributedString.Key:Any] = [.foregroundColor: Palette.shared.color(for: inColor)]
        attributedString.setAttributes(attributes,range: localRange)
        return(attributedString)
        }
        
    public override func expandIfNeeded(inOutliner outliner: NSOutlineView)
        {
        if self.isExpanded
            {
            outliner.expandItem(self.sourceItem)
            }
        }
        
    public override func child(atIndex:Int) -> ProjectItem
        {
        self.sourceItem.controller = self.controller
        return(self.sourceItem)
        }
        
    public func sourceEditingDidEnd(_ sourceItem: ProjectSourceItem)
        {
        self.versionState = self.sourceItem.sourceRecord.versionState
        }
        
    public func sourceEditingDidBegin(_ sourceItem: ProjectSourceItem)
        {
        }
    }
