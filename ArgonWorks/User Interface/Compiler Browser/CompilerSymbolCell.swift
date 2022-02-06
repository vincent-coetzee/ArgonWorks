//
//  CompilerSymbolCell.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/2/22.
//

import Cocoa

class CompilerSymbolCell: NSTableCellView
    {
    public var outlineItem: OutlineItem?
        {
        didSet
            {
            self.update()
            }
        }
        
    @IBOutlet weak var classField: NSTextField!
    @IBOutlet weak var indexField: NSTextField!
    @IBOutlet weak var memoryAddressField: NSTextField!
    @IBOutlet weak var typeNameField: NSTextField!
    @IBOutlet weak var containerField: NSTextField!
    
    private func update()
        {
        if let fields = self.outlineItem?.outlineItemFields
            {
            self.classField.stringValue = fields["class"]!.displayString
            self.indexField.stringValue = fields["index"]!.displayString
            self.memoryAddressField.stringValue = fields["memoryAddress"]!.displayString
            self.typeNameField.stringValue = fields["typeName"]!.displayString
            self.containerField.stringValue = fields["container"]!.displayString
            }
        }
    }
