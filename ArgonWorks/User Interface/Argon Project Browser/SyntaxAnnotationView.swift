//
//  SyntaxAnnotationView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/3/22.
//

import Cocoa

public protocol SyntaxAnnotationViewDelegate
    {
    func toggleAnnotation(_ annotation: SyntaxAnnotation)
    }
    
public class SyntaxAnnotationView: NSView
    {
    public var font: NSFont!
        {
        didSet
            {
            self.lineHeight = self.font.lineHeight
            }
        }
        
    public var lineCount: Int = 0
        {
        didSet
            {
            self.updateLineNumbers()
            }
        }
        
    public var delegate: SyntaxAnnotationViewDelegate?
    private var lineNumbers = Array<CATextLayer>()
    private var shapeLayer: CAShapeLayer!
    private var annotations: Array<SyntaxAnnotation> = []
    private var lineHeight: CGFloat
    public let gutterWidth: CGFloat
    public var gutterBorderColor: NSColor = NSColor.argonWhite50
    public var gutterColor: NSColor = NSColor.argonWhite20
        {
        didSet
            {
            self.layer?.backgroundColor = self.gutterColor.cgColor
            }
        }
    
    init(gutterWidth:CGFloat)
        {
        self.lineHeight =  0
        self.gutterWidth = gutterWidth
        super.init(frame: .zero)
        self.wantsLayer = true
        self.initShapeLayer()
        }
        
    private func updateLineNumbers()
        {
        self.lineNumbers.forEach{$0.removeFromSuperlayer()}
        self.lineNumbers = []
        var offset: CGFloat = self.bounds.size.height - self.lineHeight
        for line in 0...self.lineCount
            {
            let string = "\(line + 1)"
            let lineNumber = CATextLayer()
            lineNumber.fontSize = self.font.pointSize
            lineNumber.foregroundColor = NSColor.white.cgColor
            lineNumber.font = self.font
            lineNumber.string = string
            let attributedString = NSAttributedString(string: string,attributes: [.font: self.font!])
            let size = attributedString.size()
            let delta = self.gutterWidth - 5 - size.width
            lineNumber.frame = NSRect(x: delta,y: offset,width: self.gutterWidth,height: self.lineHeight)
            self.layer?.addSublayer(lineNumber)
            self.lineNumbers.append(lineNumber)
            offset -= self.lineHeight
            }
        }
        
    private func initShapeLayer()
        {
        let shape = CAShapeLayer()
        let path = NSBezierPath()
        path.move(to: NSPoint(x:self.gutterWidth,y:0))
        path.line(to: NSPoint(x:self.gutterWidth,y:1))
        shape.path = path.cgPath
        shape.lineDashPattern = [1,0,1,0,1,0]
        shape.lineWidth = 1
        shape.strokeColor = self.gutterBorderColor.cgColor
        self.layer?.addSublayer(shape)
        self.shapeLayer = shape
        }
        
    public func appendAnnotation(_ issue: CompilerIssue)
        {
        for anAnnotation in self.annotations
            {
            if anAnnotation.issue.location.line == issue.location.line
                {
                return
                }
            }
        let offset = self.lineHeight * CGFloat(issue.location.line)
        let rect = NSRect(x: 5,y:self.bounds.size.height - offset,width: lineHeight,height: lineHeight)
        let annotation = SyntaxAnnotation(issue: issue, frame: rect)
        self.annotations.append(annotation)
        let theLayer = annotation.annotationLayer
        self.layer?.addSublayer(theLayer)
        theLayer.frame = annotation.frame
        }
        
    public func resetAnnotations()
        {
        for annotation in self.annotations
            {
            annotation.annotationLayer.removeFromSuperlayer()
            }
        self.annotations = []
        }
        
    public func updateAnnotations()
        {
        for annotation in self.annotations
            {
            let issue = annotation.issue
            let offset = self.lineHeight * CGFloat(issue.location.line)
            let rect = NSRect(x: 5,y:self.bounds.size.height - offset,width: lineHeight,height: lineHeight)
            annotation.frame = rect
            let layer = annotation.annotationLayer
            layer.frame = rect
            }
        }
        
    public override func mouseDown(with event: NSEvent)
        {
        var point = self.convert(event.locationInWindow,from: nil)
        for annotation in self.annotations
            {
            if annotation.frame.contains(point)
                {
                self.delegate?.toggleAnnotation(annotation)
                }
            }
        }
        
    public override func layout()
        {
        super.layout()
        self.shapeLayer.frame = self.bounds
        let path = NSBezierPath()
        path.move(to: NSPoint(x:self.gutterWidth,y:0))
        path.line(to: NSPoint(x:self.gutterWidth,y:self.bounds.size.height))
        self.shapeLayer.path = path.cgPath
        self.updateLineNumbers()
        self.updateAnnotations()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
