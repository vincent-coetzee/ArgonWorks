//
//  Initializer.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Initializer:Invokable
    {
    public override var firstInitializer: Initializer?
        {
        return(self)
        }
        
    internal private(set) var block = Block()
    internal var declaringClass: Class?
    
    public override var typeCode:TypeCode
        {
        .initializer
        }

    public override init(label: Label)
        {
        super.init(label: label)
        self.block = InitializerBlock(initializer: self)
        }
            
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.declaringClass = coder.decodeObject(forKey: "declaringClass") as? Class
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.block,forKey: "block")
        coder.encode(self.declaringClass,forKey: "declaringClass")
        super.encode(with: coder)
        }
}
