//
//  ArgonBrowserSourceViewController.swift
//  ArgonBrowserSourceViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserSourceViewController: NSViewController
    {
    @IBOutlet var sourceScroller: NSScrollView!
    @IBOutlet var sourceEditor: LineNumberTextView!
    @IBOutlet var browser: NSBrowser!
    
    private var editor: LineNumberTextView!
    private var splitView: NSSplitView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        editor =  LineNumberTextView(frame: .zero)
        editor.isEditable = true
        editor.isSelectable = true
        let scroller = NSScrollView(frame: .zero)
        self.view.addSubview(scroller)
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(editor)
        scroller.documentView = editor
        editor.translatesAutoresizingMaskIntoConstraints = false
        self.editor.topAnchor.constraint(equalTo: scroller.topAnchor).isActive = true
        self.editor.leadingAnchor.constraint(equalTo: scroller.leadingAnchor).isActive = true
        self.editor.trailingAnchor.constraint(equalTo: scroller.trailingAnchor).isActive = true
        self.editor.bottomAnchor.constraint(equalTo: scroller.bottomAnchor).isActive = true
        self.editor.widthAnchor.constraint(equalTo: scroller.widthAnchor).isActive = true
        editor.initOutsideNib()
        self.sourceEditor = editor
        self.sourceEditor.isEditable = true
        self.sourceScroller.removeFromSuperview()
        self.splitView = NSSplitView(frame: .zero)
        self.splitView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(self.splitView)
//        self.editor.isVertical = false
        scroller.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scroller.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scroller.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scroller.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//        self.splitView.addArrangedSubview(self.browser)
//        self.splitView.addArrangedSubview(editor)
        }
    
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.sourceEditor = self.sourceEditor
//        let height = self.view.window!.frame.height / 3.0
//        self.splitView.setPosition(height, ofDividerAt: 0)
        }
}
