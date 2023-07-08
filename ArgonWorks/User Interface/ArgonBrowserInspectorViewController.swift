//
//  ArgonBrowserInspectorViewController.swift
//  ArgonBrowserInspectorViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserInspectorViewController: NSViewController
    {
    @IBOutlet var listView: NSOutlineView!
    @IBOutlet var listHeaderView: HeaderView!
    @IBOutlet var listScrollView: NSScrollView!
    @IBOutlet var editorHeaderView: HeaderView!
    @IBOutlet var editorView: NSView!
    @IBOutlet var splitView: NSSplitView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.editorHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.editorView.translatesAutoresizingMaskIntoConstraints = false
        self.listHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.listView.translatesAutoresizingMaskIntoConstraints = false
        self.listScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.editorHeaderView.textColor = Palette.shared.headerTextColor
        self.editorHeaderView.headerColor = Palette.shared.headerColor
        self.listHeaderView.textColor = Palette.shared.headerTextColor
        self.listHeaderView.headerColor = Palette.shared.headerColor
        self.editorHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.editorHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.editorHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.editorHeaderView.bottomAnchor.constraint(equalTo: self.view.topAnchor,constant: Palette.shared.headerHeight).isActive = true
        self.editorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.editorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.editorView.topAnchor.constraint(equalTo: self.editorHeaderView.bottomAnchor).isActive = true
        let constraint = NSLayoutConstraint(item: self.editorView!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.5, constant: -Palette.shared.headerHeight)
        constraint.isActive = true
        self.view.addConstraint(constraint)
        self.listHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.listHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.listHeaderView.topAnchor.constraint(equalTo: self.editorView.bottomAnchor).isActive = true
        self.listHeaderView.bottomAnchor.constraint(equalTo: self.listHeaderView.topAnchor,constant: Palette.shared.headerHeight).isActive = true
        self.listScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.listScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.listScrollView.topAnchor.constraint(equalTo: self.listHeaderView.bottomAnchor).isActive = true
        self.listScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.inspectorController = self
        controller.errorListView = listView
        }
    }
