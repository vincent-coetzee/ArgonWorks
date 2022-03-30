//
//  ProjectElementItemView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/3/22.
//

import Cocoa

public class ProjectElementItemView: ProjectItemView
    {
    private let warningCounter: IconLabelView
    private let errorCounter: IconLabelView
    private let lineCounter: IconLabelView
    
    public init(frame: NSRect,elementItem: ProjectElementItem)
        {
        var sourceModel = AspectAdaptor(on: elementItem.sourceItem.sourceRecord,aspect: "warningCount")
        var valueModel = Transformer(model: sourceModel)
            {
            incoming -> String in
            let value = incoming as! Int
            return("\(value) warning" + (value == 1 ? "" : "s"))
            }
        var image = NSImage(named: "IconMarker")!
        image.isTemplate = true
        self.warningCounter = IconLabelView(imageValueModel: ValueHolder(value: image), imageEdge: .left, valueModel: valueModel)
        self.warningCounter.iconTintColor = NSColor.argonCheese
        sourceModel = AspectAdaptor(on: elementItem.sourceItem.sourceRecord,aspect: "errorCount")
        valueModel = Transformer(model: sourceModel)
            {
            incoming -> String in
            let value = incoming as! Int
            return("\(value) error" + (value == 1 ? "" : "s"))
            }
        self.errorCounter = IconLabelView(imageValueModel: ValueHolder(value: image), imageEdge: .left, valueModel: valueModel)
        self.errorCounter.iconTintColor = NSColor.argonSizzlingRed
        sourceModel = AspectAdaptor(on: elementItem.sourceItem.sourceRecord,aspect: "lineCount")
        valueModel = Transformer(model: sourceModel)
            {
            incoming -> String in
            let value = incoming as! Int
            return("\(value) line" + (value == 1 ? "" : "s"))
            }
        image = NSImage(named: "IconEmpty")!
        image.isTemplate = true
        self.lineCounter = IconLabelView(imageValueModel: ValueHolder(value: image), imageEdge: .left, valueModel: valueModel)
        self.lineCounter.iconTintColor = NSColor.argonNeonGreen
        super.init(frame: frame)
        }
        
    internal override func initConstraints()
        {
        super.initConstraints()
        self.addSubview(self.warningCounter)
        self.addSubview(self.errorCounter)
        self.addSubview(self.lineCounter)
        self.viewTextTrailingConstraint.isActive = false
        self.viewText.trailingAnchor.constraint(equalTo: self.warningCounter.leadingAnchor,constant: -4).isActive = true
        self.errorCounter.translatesAutoresizingMaskIntoConstraints = false
        self.warningCounter.translatesAutoresizingMaskIntoConstraints = false
        self.errorCounter.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -8).isActive = true
        self.errorCounter.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.errorCounter.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.warningCounter.trailingAnchor.constraint(equalTo: self.errorCounter.leadingAnchor,constant: -8).isActive = true
        self.errorCounter.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.errorCounter.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.lineCounter.translatesAutoresizingMaskIntoConstraints = false
        self.lineCounter.trailingAnchor.constraint(equalTo: self.warningCounter.leadingAnchor,constant: -8).isActive = true
        self.lineCounter.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.lineCounter.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
        
//    public override func layout()
//        {
//        super.layout()
//        let width = self.bounds.size.height
//        let height = self.bounds.size.height
//        self.viewImage.frame = NSRect(x: 0,y: 0,width: width,height: height)
//        let stringSize = self.item.measureString(self.viewText.stringValue, withFont: self.font, inWidth: width)
//        let delta = (height - stringSize.height) / 2
//        self.viewText.frame = NSRect(x: width + 4,y:delta,width: stringSize.width,height: stringSize.height)
//        let errorCounterSize = self.errorCounter.intrinsicContentSize
//        self.errorCounter.frame = NSRect(x: self.bounds.size.width - 4 - errorCounterSize.width,y: 0,width: errorCounterSize.width,height: errorCounterSize.height)
//        let warningCounterSize = self.warningCounter.intrinsicContentSize
//        self.warningCounter.frame = NSRect(x: self.bounds.size.width - 8 - ( errorCounterSize.width +  warningCounterSize.width),y: 0,width: warningCounterSize.width,height: warningCounterSize.height)
//        }
    }
