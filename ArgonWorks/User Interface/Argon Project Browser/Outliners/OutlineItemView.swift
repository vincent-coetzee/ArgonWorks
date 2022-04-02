//
//  OutlineItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa

public protocol OutlineItemView: AnyObject
    {
    var outlineItem: OutlineItem? { get set }
    }
    
public typealias OutlineItemNSView = OutlineItemView & NSView
