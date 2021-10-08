//
//  FirstSemanticCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/10/21.
//

import Cocoa

class LeaderSemanticCellView: NSTableCellView
    {
    @IBOutlet var addButton: NSButton!
    @IBOutlet var deleteButton: NSButton!
    @IBOutlet var editButton: NSButton!
    @IBOutlet var labelView: NSTextField!
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.addButton.isHidden = true
        self.deleteButton.isHidden = true
        self.editButton.isHidden = true
        }
        
    public func revertColors(selectionColor: NSColor)
        {
        self.addButton.isHidden = true
        self.deleteButton.isHidden = true
        self.editButton.isHidden = true
//        if let event = self.event
//            {
//            self.iconView.contentTintColor = event.tintColor
//            self.diagnosticView.textColor = event.tintColor
//            self.lineNumberView.textColor = NSColor.controlTextColor
//            }
        }
        
    public func invertColors(selectionColor: NSColor)
        {
        self.addButton.isHidden = false
        self.deleteButton.isHidden = false
        self.editButton.isHidden = false
//        self.iconView.contentTintColor = NSColor.black
//        self.diagnosticView.textColor = NSColor.black
//        self.lineNumberView.textColor = NSColor.black
        }
    
}
