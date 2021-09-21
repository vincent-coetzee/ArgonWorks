//
//  ArgonBrowserHierarchyViewController.swift
//  ArgonBrowserHierarchyViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserHierarchyViewController: NSViewController
    {
    @IBOutlet var outliner: NSOutlineView!
    
    private var controller: ArgonBrowserWindowController?
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        // Do view setup here.
        }
    
    public override func viewDidAppear()
        {
        self.controller = (self.view.window!.windowController as! ArgonBrowserWindowController)
        self.controller?.outliner = self.outliner
        }
        
    @IBAction func onOpenDocument(_ sender:Any?)
        {
        self.controller?.fugglyBuggly(nil)
        }
    }
