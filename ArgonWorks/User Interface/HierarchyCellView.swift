//
//  HierarchyCellView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/9/21.
//

import Cocoa

public class HierarchyCellView: NSTableCellView
    {
    @IBOutlet var icon: NSImageView!
    @IBOutlet var text: NSTextField!
    @IBOutlet var trailer: NSTextField!
    @IBOutlet var ender: NSTextField!
    
    public var symbol: Symbol?
        {
        didSet
            {
            if self.symbol.isNotNil
                {
                self.update(from: self.symbol!)
                }
            }
        }
        
    public func invert()
        {
        self.symbol?.invert(cell: self)
        }
        
    public func revert()
        {
        self.symbol?.configure(cell: self)
        }
        
    private func update(from aSymbol: Symbol)
        {
        aSymbol.configure(cell: self)
        }
        
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.trailer.stringValue = ""
        }
    }
