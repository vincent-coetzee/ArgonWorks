//
//  SemanticBrowserWindowController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/10/21.
//

import Cocoa

class SemanticBrowserWindowController: NSWindowController, NSToolbarDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @objc func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
        {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = "Item"
        let image = NSImage(named: "IconClass")
        let button = NSButton(frame: NSRect(x:0,y:0,width: 40,height: 40))
        button.title = ""
        button.image = image
        button.setButtonType(.toggle)
        button.bezelStyle = .rounded
        button.action = #selector(ArgonBrowserWindowController.doButton(_:))
        item.view = button
        return(item)
        }
}
