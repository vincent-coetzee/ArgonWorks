//
//  ProjectCommentItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/4/22.
//

import Cocoa

public class ProjectCommentItem: ProjectItem,NSTextViewDelegate
    {
    internal var text: String = ""

    public override init(label: Label)
        {
        self.text = label
        super.init(label: label)
        self.icon = NSImage(named:"IconComment")!
        self.iconTintIdentifier = .commentColor
        }
        
    public required init?(coder: NSCoder)
        {
        self.text = coder.decodeString(forKey: "text")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.text,forKey: "text")
        super.encode(with: coder)
        }
        
    public override func _makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "Primary")
            {
            let view = ProjectCommentItemCellView(frame: .zero,font: Palette.shared.font(for: self.fontIdentifier))
            view.item = self
            return(view)
            }
        else
            {
            return(super._makeCellView(inOutliner: outliner, forColumn: columnIdentifier))
            }
        }
        
    public func sourceDidChange(_ view: NSView,textView: NSTextView)
        {
        self.text = textView.string
        let font = Palette.shared.font(for: self.fontIdentifier)
        var width = view.bounds.size.width
        width -= font.lineHeight
        width -= 4
        let theHeight = self.height(inWidth: width)
        if theHeight != self.height
            {
            self.height = theHeight
            let row = self.controller.outliner.row(forItem: self)
            let indexSet = IndexSet(integer: row)
            self.controller.outliner.noteHeightOfRows(withIndexesChanged: indexSet)
            }
        }
    }
