//
//  OutlineItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa

public protocol OutlineItem: AnyObject
    {
    var isExpanded: Bool { get set }
    var parentItem: OutlineItem? { get }
    var identityKey: Int { get }
    var isSystemItem: Bool { get }
    var iconTintIdentifier: StyleColorIdentifier { get }
    var textColorIdentifier: StyleColorIdentifier { get }
    var childCount: Int { get }
    var label: String { get }
    var icon: NSImage { get }
    var isExpandable: Bool { get }
    func insertionIndex(forSymbol: Symbol) -> Int
    func child(atIndex: Int) -> OutlineItem
    func makeView(for: Outliner) -> OutlineItemNSView
    func expandIfNeeded(inOutliner: NSOutlineView)
    func invalidateChildren()
    func isEqual(to: Any?) -> Bool
    }

public typealias OutlineItems = Array<OutlineItem>
