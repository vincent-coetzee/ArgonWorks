//
//  LayoutFrame.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/9/21.
//

import AppKit

public protocol Pane
    {
    var layoutFrame: LayoutFrame { get }
    var frame: NSRect { get set }
    }
    
public enum Edge
    {
    case none
    case left
    case right
    case top
    case bottom
    }
    
public struct LayoutDimension
    {
    public let fraction: CGFloat
    public let offset: CGFloat
    
    init(fraction: CGFloat,offset: CGFloat)
        {
        self.fraction = fraction
        self.offset = offset
        }
    }

public struct LayoutFrame
    {
    public static let zero = LayoutFrame(leftFraction:0,topFraction: 0,rightFraction: 0,bottomFraction: 0)
    
    public let left: LayoutDimension
    public let top: LayoutDimension
    public let bottom: LayoutDimension
    public let right: LayoutDimension
    
    init(left: LayoutDimension,top: LayoutDimension,bottom: LayoutDimension,right: LayoutDimension)
        {
        self.left = left
        self.top = top
        self.bottom = bottom
        self.right = right
        }
        
    init(leftFraction: CGFloat,topFraction: CGFloat,rightFraction: CGFloat,bottomFraction: CGFloat)
        {
        self.left = LayoutDimension(fraction: leftFraction,offset: 0)
        self.top = LayoutDimension(fraction: topFraction,offset: 0)
        self.bottom = LayoutDimension(fraction: bottomFraction,offset: 0)
        self.right = LayoutDimension(fraction: rightFraction,offset: 0)
        }
        
    init(leftFraction: CGFloat = 0,leftOffset: CGFloat = 0,topFraction: CGFloat = 0,topOffset: CGFloat = 0,rightFraction: CGFloat = 0,rightOffset:CGFloat = 0,bottomFraction: CGFloat = 0,bottomOffset: CGFloat = 0)
        {
        self.left = LayoutDimension(fraction: leftFraction,offset: leftOffset)
        self.top = LayoutDimension(fraction: topFraction,offset: topOffset)
        self.bottom = LayoutDimension(fraction: bottomFraction,offset: bottomOffset)
        self.right = LayoutDimension(fraction: rightFraction,offset: rightOffset)
        }
        
    public func rectangle(inRect rect: NSRect) -> NSRect
        {
        let left = self.left.fraction * rect.width + self.left.offset
        let right = self.right.fraction * rect.width + self.right.offset
        let top = self.top.fraction * rect.height + self.top.offset
        let bottom = self.bottom.fraction * rect.height + self.bottom.offset
        return(NSRect(x: left,y: top,width: right - left,height: bottom - top))
        }
    }

public class LayoutHostingView: NSView
    {
    public override func layout()
        {
        super.layout()
        let frame = self.bounds
        for pane in self.subviews.filter({$0 is LayoutView}).map({$0 as! LayoutView})
            {
            pane.frame = pane.layoutFrame.rectangle(inRect: frame)
            print("VIEW = \(pane) LAYOUTFRAME = \(pane.layoutFrame) RECT=\(pane.frame)")
            }
        }
    }
