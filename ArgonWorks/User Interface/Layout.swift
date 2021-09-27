////
////  Layout.swift
////  ArgonWorks
////
////  Created by Vincent Coetzee on 22/9/21.
////
//
//import Cocoa
//
//public typealias Units = CGFloat
//
//public enum Dimension
//    {
//    case leading
//    case trailing
//    case top
//    case bottom
//    case width
//    case height
//    }
//    
//public enum Basis
//    {
//    case none
//    case frame(Dimension)
//    case pane(Pane,Dimension)
//    
//    public func value(inPane pane: Pane) -> Units
//        {
//        switch(self)
//            {
//            case .none:
//                return(0)
//            case .frame(let dim):
//                
//            }
//        }
//    }
//    
//public protocol Pane
//    {
//    var topDimension: Units { get }
//    var bottomDimension: Units { get }
//    var leadingDimension: Units { get }
//    var trailingDimension: Units { get }
//    
//    func value(inDimension: Dimension) -> Units
//    }
//
//public struct LayoutExpression
//    {
//    var basis: Basis = .none
//    var fraction: Units = 0
//    var constant: Units = 0
//    
//    init(frame: Dimension,fraction: Units = 0,constant: Units = 0)
//        {
//        self.basis = .frame(frame)
//        self.fraction = fraction
//        self.constant = constant
//        }
//        
//    public func value(inPane pane: Pane) -> Units
//        {
//        let base = self.basis.value(inPane: pane)
//        }
//    }
//    
//public protocol Frame
//    {
//    var leading: LayoutExpression { get }
//    var trailing: LayoutExpression { get }
//    var top: LayoutExpression { get }
//    var bottom: LayoutExpression { get }
//    
//    func layoutFrame(inPane: Pane)
//    func layoutFrame()
//    }
//
//extension Frame
//    {
//    public func layoutFrame(inPane pane: Pane)
//        {
//        let left = self.leading.value(inPane:
//        }
//    }
//    
//extension NSView: Pane
//    {
//    public var topDimension: Units
//        {
//        self.frame.minY
//        }
//        
//    public var bottomDimension: Units
//        {
//        self.frame.maxY
//        }
//        
//    public var leadingDimension: Units
//        {
//        self.frame.minX
//        }
//        
//    public var trailingDimension: Units
//        {
//        self.frame.maxX
//        }
//        
//    public func value(inDimension dimension: Dimension) -> Units
//        {
//        switch(dimension)
//            {
//            case .leading:
//                return(self.leadingDimension)
//            case .trailing:
//                return(self.trailingDimension)
//            case .top:
//                return(self.topDimension)
//            case .bottom:
//                return(self.bottomDimension)
//            case .width:
//                return(self.trailingDimension - self.leadingDimension)
//            case .height:
//                return(self.bottomDimension - self.topDimension)
//            }
//        }
//    }
