//
//  Argument.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct Argument:Displayable
    {
    public var displayString: String
        {
        let aTag = self.tag ?? "="
        return("\(aTag)::\(self.value.displayString)")
        }
    public let tag:String?
    public let value:Expression
    }

public typealias Arguments = Array<Argument>

extension Arguments
    {
    public var resultTypes: Array<Type>
        {
        return(self.map{$0.value.type})
        }
    }
//
//public typealias TypeResults = Array<TypeResult>
//
//extension TypeResults
//    {
//    public var isMisMatched: Bool
//        {
//        for result in self
//            {
//            switch(result)
//                {
//                case .undefined:
//                    return(true)
//                case .mismatch:
//                    return(true)
//                default:
//                    break
//                }
//            }
//        return(false)
//        }
//    }
