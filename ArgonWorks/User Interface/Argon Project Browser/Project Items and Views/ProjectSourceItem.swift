//
//  ProjectSourceItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectSourceItem: ProjectItem
    {
    public override var isExpanded: Bool
        {
        didSet
            {
            self.elementItem.isExpanded = self.isExpanded
            }
        }
        
    public var symbolValue: SymbolValue!
        {
        didSet
            {
            self.elementItem.symbolValue = self.symbolValue
            }
        }
        
    public unowned var elementItem: ProjectElementItem!
    public var sourceRecord: SourceRecord
    
    public override init(label: Label)
        {
        self.sourceRecord = SourceRecord()
        super.init(label: label)
        self.versionState = self.sourceRecord.versionState
        }
        
    public required init?(coder:NSCoder)
        {
        self.sourceRecord = coder.decodeObject(forKey: "sourceRecord") as! SourceRecord
        self.elementItem = coder.decodeObject(forKey: "elementItem") as? ProjectElementItem
        super.init(coder: coder)
        self.versionState = self.sourceRecord.versionState
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.sourceRecord,forKey: "sourceRecord")
        coder.encode(self.elementItem,forKey: "elementItem")
        super.encode(with: coder)
        }
        
    public override func height(inWidth: CGFloat) -> CGFloat
        {
        let stringSize = self.measureString(self.sourceRecord.text,withFont: Palette.shared.font(for: .editorFont),inWidth: inWidth)
        let theHeight = stringSize.height + (Palette.shared.font(for: .editorFont)).lineHeight
        return(theHeight)
        }
        
    public override func _makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "Primary")
            {
            let view = ProjectSourceItemCellView(frame: .zero)
            view.item = self
//            view.font = self.controller.sourceOutlinerFont
//            view.editorView.font = self.controller.sourceOutlinerFont
            view.editorView.incrementalParser = self.controller.incrementalParser
            view.editorView.sourceItem = self
            view.editorView.sourceRecord = self.sourceRecord
            return(view)
            }
        else
            {
            return(nil)
            }
        }
        
    public func hideBorder()
        {
        (self.cellViews[NSUserInterfaceItemIdentifier(rawValue: "Primary")]?.tableCellView as? ProjectSourceItemCellView)?.hideBorder()
        }
        
    public func showBorder()
        {
        (self.cellViews[NSUserInterfaceItemIdentifier(rawValue: "Primary")]?.tableCellView as? ProjectSourceItemCellView)?.showBorder()
        }
        
    public override func markVersionState(as state: VersionState)
        {
        self.versionState = state
        self.elementItem.markVersionState(as: state)
        }
        
    public func sourceDidChange(_ view: BrowserEditorView)
        {
        let width = view.bounds.size.width
        let font = Palette.shared.font(for: .editorFont)
        var stringSize = self.measureString(self.sourceRecord.text, withFont: font, inWidth: width)
        stringSize.height += font.lineHeight
        if stringSize.height != self.height
            {
            self.height = stringSize.height
            let row = self.controller.outliner.row(forItem: self)
            let indexSet = IndexSet(integer: row)
            self.controller.outliner.noteHeightOfRows(withIndexesChanged: indexSet)
            }
        }
    }
