//
//  CustomView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Cocoa

public protocol Control: AnyObject
    {
    var key: String { get }
    var textFont: NSFont { get set }
    var valueModel: ValueModel { get set }
    }
    
public class CustomView: NSView
    {
    public var textFont: NSFont = NSFont(name: "SunSans-Demi",size: 11)!
        
    public var backgroundColor: NSColor?
        {
        didSet
            {
            self.wantsLayer = true
            self.layer!.backgroundColor = self.backgroundColor?.cgColor
            }
        }
        
    public var drawsHorizontalBorder: Bool = false
        {
        didSet
            {
            self.needsDisplay = true
            }
        }
        
    public var horizontalBorderColor: NSColor = .white
        {
        didSet
            {
            self.needsDisplay = true
            }
        }
        
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        self.wantsLayer = true
        }
    
    required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.wantsLayer = true
        }
    }

