//
//  ProjectVersionStateView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/3/22.
//

import Cocoa

class ProjectVersionStateView: NSTableCellView
    {
    public weak var item: ProjectItem!
        {
        didSet
            {
            self.valueModelImageView.imageValueModel = Transformer(model: AspectAdaptor(on: item, aspect: "versionState"))
                {
                (incoming:Any?) -> NSImage? in
                let versionState = incoming as! VersionState
                return(versionState.icon)
                }
            self.valueModelImageView.imageTintValueModel = Transformer(model: AspectAdaptor(on: item, aspect: "versionState"))
                {
                (incoming:Any?) -> NSColor? in
                let versionState = incoming as! VersionState
                return(versionState.iconTint)
                }
            }
        }

    private let valueModelImageView: ValueModelImageView
    
    public override init(frame: NSRect)
        {
        self.valueModelImageView = ValueModelImageView(frame: .zero)
        super.init(frame: frame)
        self.imageView = self.valueModelImageView
        self.addSubview(self.valueModelImageView)
        self.valueModelImageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.cell?.isBordered = false
        self.imageView?.cell?.isBezeled = false
        self.imageView!.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -4).isActive = true
        self.imageView!.widthAnchor.constraint(equalTo: self.imageView!.heightAnchor).isActive = true
        self.imageView!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.imageView!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
}
