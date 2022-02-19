//
//  TypeUnion.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/2/22.
//

import Foundation

//public class TypeUnion: Type
//    {
//    public static func ==(lhs: TypeUnion,rhs: Type) -> Bool
//        {
//        if let right = rhs as? TypeUnion
//            {
//            return(lhs.types == right.types)
//            }
//        for type in lhs.types
//            {
//            if type != rhs
//                {
//                return(false)
//                }
//            }
//        return(true)
//        }
//        
//    private var types: Types
//    
//    override init()
//        {
//        self.types = []
//        super.init(label: "")
//        }
//        
//    init(types: Types)
//        {
//        self.types = types
//        super.init(label: "")
//        }
//        
//    required init?(coder: NSCoder)
//        {
//        self.types = coder.decodeObject(forKey: "types") as! Types
//        super.init(coder: coder)
//        }
//        
//    required init(label: Label)
//        {
//        self.types = []
//        super.init(label: label)
//        }
//        
//    public override func encode(with coder: NSCoder)
//        {
//        coder.encode(self.types,forKey: "types")
//        super.encode(with: coder)
//        }
//        
//    public func append(_ type: Type) -> Self
//        {
//        self.types.append(type)
//        return(self)
//        }
//    }
