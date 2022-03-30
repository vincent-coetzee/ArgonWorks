//
//  OutlineItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa

public protocol OutlineItem: AnyObject
    {
    var parentItem: OutlineItem? { get }
    var identityKey: Int { get }
    var isSystemItem: Bool { get }
    var iconTint: NSColor { get }
    var childCount: Int { get }
    var label: String { get }
    var icon: NSImage { get }
    var isExpandable: Bool { get }
    func insertionIndex(forSymbol: Symbol) -> Int
    func child(atIndex: Int) -> OutlineItem
    func makeView(for: Outliner) -> OutlineItemNSView
    }

public typealias OutlineItems = Array<OutlineItem>
