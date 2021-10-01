//
//  DeferredValueExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/9/21.
//

import Foundation

public class DeferredValueExpression: Expression
    {
    public override var resultType: Type
        {
        return(self.type)
        }
        
    private let name: Label
    private let type: Type
    
    init(_ name:Label,type:Type)
        {
        self.name = name
        self.type = type
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.name = coder.decodeObject(forKey: "name") as! String
        self.type = coder.decodeType(forKey: "type")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.name,forKey: "name")
        coder.encodeType(self.type,forKey: "type")
        }
    }
