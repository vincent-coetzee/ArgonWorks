//
//  UnresolvedExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Foundation

public class UnresolvedExpression: Expression
    {
    public override var isUnresolved: Bool
        {
        return(true)
        }
        
    public let label: Label
    
    init(label: Label)
        {
        self.label = label
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.label = coder.decodeString(forKey: "label")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.label,forKey: "label")
        super.encode(with: coder)
        }
    }
