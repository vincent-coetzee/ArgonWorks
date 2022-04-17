//
//  ProjectSourceItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectSourceItemCellView: ProjectItemCellView
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
//        self.layer?.borderWidth = Palette.shared.float(for: .editorBorderWidth)
        self.editorView.translatesAutoresizingMaskIntoConstraints = false
        self.layer?.borderColor = Palette.shared.color(for: .editorBorderColor).cgColor
        self.layer?.cornerRadius = Palette.shared.float(for: .editorBorderCornerRadius)
        self.editorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.editorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.editorView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.editorView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hideBorder()
        {
        self.layer?.borderWidth = 0
        self.editorView.hideAnnotationView()
        }
        
    public func showBorder()
        {
        self.layer?.borderWidth = Palette.shared.float(for: .editorBorderWidth)
        self.editorView.showAnnotationView()
        }
        
//    public override func layout()
//        {
//        super.layout()
//        let width = self.bounds.size.width
//        let height = self.bounds.size.height
//        self.editorView.frame = NSRect(x: 0,y: 0,width: width,height: height)
//        }
    }
    
