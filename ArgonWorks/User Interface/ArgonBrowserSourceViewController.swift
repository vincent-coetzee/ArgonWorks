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
    @IBOutlet var browser: NSBrowser!
    
    private var splitView: NSSplitView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.splitView = NSSplitView(frame: .zero)
        self.splitView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.splitView)
        self.splitView.isVertical = false
        self.splitView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.splitView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.splitView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.splitView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.splitView.addArrangedSubview(self.browser)
        self.splitView.addArrangedSubview(self.sourceEditor)
        }
    
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.sourceEditor = self.sourceEditor
        let height = self.view.window!.frame.height / 3.0
        self.splitView.setPosition(height, ofDividerAt: 0)
        }
}
