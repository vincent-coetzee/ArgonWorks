//
//  CompilerIssueLayer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/11/21.
//

import Cocoa

public class CompilerIssueMessageLayer: CALayer
    {
    private let textLayer: CATextLayer
    private let issue: CompilerIssue
    
    init(issue: CompilerIssue)
        {
        self.issue = issue
        self.textLayer = CATextLayer()
        super.init()
        self.textLayer.string = issue.message
        self.backgroundColor = issue.isWarning ? Palette.shared.warningColor.cgColor : Palette.shared.errorColor.cgColor
        self.textLayer.foregroundColor = NSColor.black.cgColor
        self.textLayer.font = "Menlo" as CFTypeRef
        self.textLayer.fontSize = 10
        self.addSublayer(textLayer)
        self.align()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    private func align()
        {
        let size = NSAttributedString(string: self.issue.message,attributes: [.font: NSFont(name: "Menlo",size: 10)!]).size()
        let deltaY = (self.bounds.size.height - size.height) / 2
        let deltaX = CGFloat(10)
        self.textLayer.frame = NSRect(x: deltaX,y: deltaY,width: size.width,height: size.height)
        }
        
    public override func layoutSublayers()
        {
        super.layoutSublayers()
        self.align()
        }
    }
