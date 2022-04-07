//
//  SurrogateClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/4/22.
//

import Foundation

public class SurrogateType: Type
    {
    public static var allSurrogates = Array<SurrogateType>()
    
    private let name: Name
    
    init(typeClass: TypeClass)
        {
        self.name = typeClass.fullName
        super.init(label: "")
        }
        
    public required init?(coder: NSCoder)
        {
        self.name = coder.decodeName(forKey: "name")
        super.init(coder: coder)
        Self.allSurrogates.append(self)
        }
        
    public required init(label: Label)
        {
        self.name = Name()
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encodeName(self.name,forKey: "name")
        super.encode(with: coder)
        }
        
    public func actualType(topModule: TopModule) -> Type
        {
        topModule.lookup(name: self.name) as! Type
        }
    }
