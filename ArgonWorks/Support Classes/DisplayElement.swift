//
//  DisplayElement.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/2/22.
//

import Foundation
import Cocoa

public protocol StringConvertible
    {
    var stringValue: String { get }
    }
    
public class FieldBox
    {
    public var label: String
    public var displayString: String
        {
        self.value()
        }
        
    private let value: () -> String
    
    public init<R,T>(label: String,root: R,keyPath: KeyPath<R,T>) where T: StringConvertible
        {
        self.label = label
        self.value =
            {
            let tValue = root[keyPath: keyPath]
            return(tValue.stringValue)
            }
        }
    
    }

public protocol OutlineItemCell
    {
    var outlineItem: OutlineItem { get set }
    }
    
public protocol OutlineItem
    {
    var outlineItemFields: Dictionary<String,FieldBox> { get }
    var childOutlineItemCount: Int { get }
    var isOutlineItemExpandable: Bool { get }
    var hasChildOutlineItems: Bool { get }
    func childOutlineItem(atIndex: Int) -> OutlineItem
    }

extension OutlineItem
    {
    public var outlineIsExpandable: Bool
        {
        self.hasChildOutlineItems && self.childOutlineItemCount > 0
        }
    }
