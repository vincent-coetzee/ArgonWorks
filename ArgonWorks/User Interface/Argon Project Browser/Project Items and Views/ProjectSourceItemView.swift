//
//  ProjectSourceItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectSourceItemView: ProjectItemView
    {
    public var editorView: BrowserEditorView!
    
    public override init(frame: NSRect)
        {
        self.editorView = BrowserEditorView()
        super.init(frame: frame)
        self.addSubview(self.editorView)
        self.viewImage.removeFromSuperview()
        self.viewText.removeFromSuperview()
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.argonMidGray.cgColor
        self.layer?.cornerRadius = 5
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func becomeQuiet()
        {
        self.layer?.borderWidth = 0
        }
        
    public override func layout()
        {
        super.layout()
        let width = self.bounds.size.width
        let lineHeight = self.item.controller.sourceOutlinerFont.lineHeight
        let height = self.bounds.size.height - lineHeight
        self.editorView.frame = NSRect(x: 0,y: lineHeight,width: width,height: height)
        }
    }
    
