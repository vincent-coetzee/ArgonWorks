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
    var textFontIdentifier: StyleFontIdentifier { get set }
    var valueModel: ValueModel { get set }
    }
    
public class CustomView: NSView
    {
    public var textFontIdentifier: StyleFontIdentifier = .defaultFont
        
    public var backgroundColorIdentifier: StyleColorIdentifier = .defaultBackgroundColor
        {
        didSet
            {
            self.wantsLayer = true
            self.layer!.backgroundColor = Palette.shared.color(for: self.backgroundColorIdentifier).cgColor
            }
        }
        
    public var drawsHorizontalBorder: Bool = false
        {
        didSet
            {
            self.needsDisplay = true
            }
        }
        
    public var horizontalBorderColorIdentifier: StyleColorIdentifier = .lineColor
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

