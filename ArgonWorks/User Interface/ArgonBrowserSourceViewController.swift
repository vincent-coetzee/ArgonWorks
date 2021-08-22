//
//  ArgonBrowserSourceViewController.swift
//  ArgonBrowserSourceViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserSourceViewController: NSViewController
    {
    @IBOutlet var sourceEditor: LineNumberTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.sourceEditor = self.sourceEditor
        }
}
