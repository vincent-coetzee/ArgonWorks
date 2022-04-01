//
//  BrowserAction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/4/22.
//

import Cocoa

public struct BrowserActionSet: OptionSet
    {
    public static let browserActionMenu =
        {
        () -> NSMenu in
        let menu = NSMenu()
        menu.addItem(withTitle: "New symbol", action: #selector(ArgonBrowserViewController.onNewSymbol), keyEquivalent: "")
        menu.addItem(withTitle: "New comment", action: #selector(ArgonBrowserViewController.onNewComment), keyEquivalent: "")
        menu.addItem(withTitle: "New group", action: #selector(ArgonBrowserViewController.onNewGroup), keyEquivalent: "")
        menu.addItem(withTitle: "New module", action: #selector(ArgonBrowserViewController.onNewModule), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Delete", action: #selector(ArgonBrowserViewController.onDeleteItem), keyEquivalent: "")
        return(menu)
        }()
        
    public static let leftSidebarAction = BrowserActionSet(rawValue: 1 )
    public static let rightSidebarAction  = BrowserActionSet(rawValue: 1 << 2)
    public static let loadAction = BrowserActionSet(rawValue: 1 << 3)
    public static let saveAction  = BrowserActionSet(rawValue: 1 << 4)
    public static let buildAction = BrowserActionSet(rawValue: 1 << 5)
    public static let newSymbolAction = BrowserActionSet(rawValue: 1 << 6)
    public static let newGroupAction  = BrowserActionSet(rawValue: 1 << 7)
    public static let newModuleAction = BrowserActionSet(rawValue: 1 << 8)
    public static let deleteItemAction = BrowserActionSet(rawValue: 1 << 9)
    public static let searchAction = BrowserActionSet(rawValue: 1 << 10)
    public static let settingsAction = BrowserActionSet(rawValue: 1 << 11)
    public static let newCommentAction = BrowserActionSet(rawValue: 1 << 11)
    
    public let rawValue: Int
    
    public init(rawValue: Int)
        {
        self.rawValue = rawValue
        }
    }
