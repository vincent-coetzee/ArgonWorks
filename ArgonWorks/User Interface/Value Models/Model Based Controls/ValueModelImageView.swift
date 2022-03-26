//
//  ModelImageView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Cocoa

public class ValueModelImageView: NSImageView,Dependent
    {
    public let dependentKey = DependentSet.nextDependentKey
    
    public var imageTintValueModel: ValueModel?
        {
        willSet
            {
            self.imageTintValueModel?.removeDependent(self)
            }
        didSet
            {
            self.contentTintColor = self.imageTintValueModel?.value as? NSColor
            self.imageTintValueModel?.addDependent(self)
            }
        }
        
    public var imageValueModel: ValueModel?
        {
        willSet
            {
            self.imageValueModel?.removeDependent(self)
            }
        didSet
            {
            self.imageValueModel?.addDependent(self)
            if let anImage = self.imageValueModel?.value as? NSImage
                {
                self.image = anImage
                if anImage.isTemplate,self.imageTintValueModel.isNotNil,let tint = self.imageTintValueModel?.value as? NSColor
                    {
                    self.contentTintColor = tint
                    }
                }
            }
        }
        
    public func update(aspect: String,with argument: Any?,from sender: Model)
        {
        if aspect == "value" && sender.dependentKey == self.imageValueModel?.dependentKey
            {
            self.image = argument as? NSImage
            return
            }
        if aspect == "value" && sender.dependentKey == self.imageTintValueModel?.dependentKey && (self.imageTintValueModel!.value as? NSColor).isNotNil
            {
            self.contentTintColor = self.imageTintValueModel?.value as? NSColor
            return
            }
        }
    }
