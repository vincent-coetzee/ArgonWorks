//
//  DeferredValueExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/9/21.
//

import Foundation

public class DeferredValueExpression: Expression
    {
    public override var type: Type
        {
        return(self._type)
        }
        
    private let name: Label
    private let _type: Type
    
    init(_ name:Label,type:Type)
        {
        self.name = name
        self._type = type
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.name = coder.decodeObject(forKey: "name") as! String
        self._type = coder.decodeType(forKey: "type")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.name,forKey: "name")
        coder.encodeType(self._type,forKey: "type")
        }
    }
