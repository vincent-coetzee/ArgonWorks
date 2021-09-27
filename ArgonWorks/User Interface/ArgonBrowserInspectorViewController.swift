//
//  ArgonBrowserInspectorViewController.swift
//  ArgonBrowserInspectorViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserInspectorViewController: NSViewController
    {
    @IBOutlet var listView: NSTableView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        }
    
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.inspectorController = self
        }
    }
