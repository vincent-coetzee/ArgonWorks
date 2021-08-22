//
//  ProcessorWindowController.swift
//  ProcessorWindowController
//
//  Created by Vincent Coetzee on 21/8/21.
//

import Cocoa

class ProcessorWindowController: NSWindowController
    {
    @IBOutlet var registersViewController: RegistersViewController!
    
    public let virtualMachine = VirtualMachine(small: true)
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
