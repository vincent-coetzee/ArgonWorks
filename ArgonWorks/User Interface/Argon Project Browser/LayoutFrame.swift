//
//  LayoutFrame.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/3/22.
//

import Foundation

public protocol Pane
    {
    var intrinsicSize: NSSize { get }
    }
    
public class LayoutFrame
    {
    public var pane: Pane!
    
    public func frameInFrame(_ rectangle: NSRect) -> NSRect
        {
        fatalError("Not implemented.")
        }
    }
    
public class BasicLayoutFrame: LayoutFrame
    {
    private let leftFraction: CGFloat
    private let leftOffset: Int
    private let topFraction: CGFloat
    private let topOffset: Int
    private let rightFraction: CGFloat
    private let rightOffset: Int
    private let bottomFraction: CGFloat
    private let bottomOffset: Int
    
    init(leftFraction: CGFloat,offset leftOffset: Int,topFraction: CGFloat,offset topOffset: Int,rightFraction: CGFloat,offset rightOffset: Int,bottomFraction: CGFloat,offset bottomOffset: Int)
        {
        self.leftFraction = leftFraction
        self.leftOffset = leftOffset
        self.topFraction = topFraction
        self.topOffset = topOffset
        self.rightFraction = rightFraction
        self.rightOffset = rightOffset
        self.bottomFraction = bottomFraction
        self.bottomOffset = bottomOffset
        }
        
    public override func frameInFrame(_ rectangle: NSRect) -> NSRect
        {
        let left = rectangle.origin.x + rectangle.size.width * self.leftFraction + CGFloat(self.leftOffset)
        let top = rectangle.origin.y + rectangle.size.height * self.topFraction + CGFloat(self.topOffset)
        let right = rectangle.origin.x + rectangle.size.width * self.rightFraction + CGFloat(self.rightOffset)
        let bottom = rectangle.origin.y + rectangle.size.height * self.bottomFraction + CGFloat(self.bottomOffset)
        return(NSRect(x: left,y: top,width: right - left,height: bottom - top))
        }
    }
