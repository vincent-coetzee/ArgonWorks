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
    public static let newImportAction = BrowserActionSet(rawValue: 1 << 12)
    public static let colorsAction = BrowserActionSet(rawValue: 1 << 13)
    public static let fontsAction = BrowserActionSet(rawValue: 1 << 14)
    public static let printAction = BrowserActionSet(rawValue: 1 << 15)
    
    public let rawValue: Int
    
    public init(rawValue: Int)
        {
        self.rawValue = rawValue
        }
        
    public func adjustBrowserActionMenu(_ menu: NSMenu)
        {
        var toggleCount = 0
        if self.contains(.leftSidebarAction)
            {
            toggleCount += 1
            menu.addItem(withTitle: "Toggle left sidebar", action: #selector(ArgonBrowserViewController.onToggleLeftSidebar),keyEquivalent: "")
            }
        if self.contains(.rightSidebarAction)
            {
            toggleCount += 1
            menu.addItem(withTitle: "Toggle right sidebar", action: #selector(ArgonBrowserViewController.onToggleRightSidebar),keyEquivalent: "")
            }
        if toggleCount > 0
            {
            menu.addItem(NSMenuItem.separator())
            }
        var diskCount = 0
        if self.contains(.loadAction)
            {
            diskCount += 1
            menu.addItem(withTitle: "Open project...", action: #selector(ArgonBrowserViewController.onOpen),keyEquivalent: "")
            }
        if self.contains(.saveAction)
            {
            diskCount += 1
            menu.addItem(withTitle: "Save project...", action: #selector(ArgonBrowserViewController.onSave),keyEquivalent: "")
            }
        if diskCount > 0
            {
            menu.addItem(NSMenuItem.separator())
            }
        if self.contains(.buildAction)
            {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Build project...", action: #selector(ArgonBrowserViewController.onBuild),keyEquivalent: "")
            }
        if self.contains(.newSymbolAction) || self.contains(.newGroupAction) || self.contains(.newModuleAction) || self.contains(.newCommentAction)
            {
            menu.addItem(NSMenuItem.separator())
            }
        if self.contains(.newSymbolAction)
            {
            menu.addItem(withTitle: "New Symbol", action: #selector(ArgonBrowserViewController.onNewSymbol),keyEquivalent: "")
            }
        if self.contains(.newModuleAction)
            {
            menu.addItem(withTitle: "New Module", action: #selector(ArgonBrowserViewController.onNewModule),keyEquivalent: "")
            }
        if self.contains(.newCommentAction)
            {
            menu.addItem(withTitle: "New Comment", action: #selector(ArgonBrowserViewController.onNewComment),keyEquivalent: "")
            }
        if self.contains(.newImportAction)
            {
            menu.addItem(withTitle: "New Import", action: #selector(ArgonBrowserViewController.onNewImport),keyEquivalent: "")
            }
        if self.contains(.newGroupAction)
            {
            menu.addItem(withTitle: "New Group", action: #selector(ArgonBrowserViewController.onNewGroup),keyEquivalent: "")
            }
        if self.contains(.deleteItemAction)
            {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Delete", action: #selector(ArgonBrowserViewController.onDeleteItem),keyEquivalent: "")
            }
        if self.contains(.searchAction) || self.contains(.settingsAction)
            {
            menu.addItem(NSMenuItem.separator())
            }
        if self.contains(.searchAction)
            {
            menu.addItem(withTitle: "Search...", action: #selector(ArgonBrowserViewController.onSearch),keyEquivalent: "")
            }
        if self.contains(.settingsAction)
            {
            menu.addItem(withTitle: "Settings...", action: #selector(ArgonBrowserViewController.onSettings),keyEquivalent: "")
            }
        }
    }
