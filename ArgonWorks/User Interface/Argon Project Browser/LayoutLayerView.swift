//
//  LayoutLayerView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/3/22.
//

import Cocoa

public protocol Framed
    {
    var frame: NSRect { get set }
    var layoutFrame: LayoutFrame { get }
    var view: NSView? { get set }
    }
    
public class LayoutLayerView: NSView
    {
    private var frames = Array<Framed>()
    
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        self.wantsLayer = true
        }
        
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        self.wantsLayer = true
        }
        
    public func addLayer(_ layer: CALayer & Framed)
        {
        self.layer?.addSublayer(layer)
        var aLayer = layer
        aLayer.view = self
        self.frames.append(layer)
        self.needsLayout = true
        }
        
    public func addView(_ view: NSView & Framed)
        {
        self.addSubview(view)
        self.frames.append(view)
        self.needsLayout = true
        }
        
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.wantsLayer = true
        }
        
    public override func layout()
        {
        super.layout()
        let theFrame = self.bounds
        for layer in self.frames
            {
            var actualLayer = layer
            actualLayer.frame = layer.layoutFrame.frameInFrame(theFrame)
            }
        }
    }
