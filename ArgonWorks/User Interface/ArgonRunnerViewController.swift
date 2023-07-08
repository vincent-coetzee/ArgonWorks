//
//  ArgonRunnerViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Cocoa

class ArgonRunnerViewController: NSViewController
    {
    @IBOutlet var middleSplitView: NSSplitView!
    @IBOutlet var leftSplitView: NSSplitView!
    @IBOutlet var rightSplitView: NSSplitView!
    @IBOutlet var objectFileOutliner: NSOutlineView!
    @IBOutlet var errorTable: NSTableView!
    @IBOutlet var instructionTable: NSTableView!
    @IBOutlet var consoleView: NSTextView!
    
    @IBOutlet var topLeftHeaderView: HeaderView!
    @IBOutlet var bottomLeftHeaderView: HeaderView!
    @IBOutlet var topRightHeaderView: HeaderView!
    @IBOutlet var bottomRightHeaderView: HeaderView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.topLeftHeaderView.text = "Object File"
        self.bottomLeftHeaderView.text = "Runtime Errors"
        self.topRightHeaderView.text = "Instructions"
        self.bottomRightHeaderView.text = "Console"
        }
        
    public override func viewDidAppear()
        {
        super.viewDidAppear()
        self.view.window?.title = "Argon Runner"
        }
        
    @IBAction func onLoadObjectFileClicked(_ sender: Any?)
        {
        }
    }
