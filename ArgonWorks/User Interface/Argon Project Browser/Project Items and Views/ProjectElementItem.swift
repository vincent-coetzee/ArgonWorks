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
                    self.label = "METHOD INSTANCE \(instance.label)"
                    self.icon = instance.icon
                    self.iconTint = instance.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: instance.label,inColor: self.iconTint))
                case .enumeration(let enumeration,_,_):
                    self.label = "ENUMERATION \(enumeration.label)"
                    self.icon = enumeration.icon
                    self.iconTint = enumeration.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: enumeration.label,inColor: self.iconTint))
                case .class(let aClass):
                    self.icon = aClass.icon
                    self.iconTint = aClass.iconTint
                    self.label = "CLASS \(aClass.label)"
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aClass.label,inColor: self.iconTint))
                case .typeAlias(let aType):
                    self.label = "TYPE \(aType.label)"
                    self.icon = aType.icon
                    self.iconTint = aType.iconTint
                    self.updateCellViews(string: self.attributedString(self.label,highlight: aType.label,inColor: self.iconTint))
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
        
    private let sourceItem: ProjectSourceItem
    private var previousSource: String = ""
    
    public override init(label: Label)
        {
        self.sourceItem = ProjectSourceItem(label: label)
        super.init(label: label)
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
