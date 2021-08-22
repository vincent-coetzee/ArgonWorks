//
//  ArgonDate.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct ArgonDate:Comparable,Hashable
    {
    public static func <(lhs:ArgonDate,rhs:ArgonDate) -> Bool
        {
        return(false)
        }
        
    private let day:Int
    private let monthIndex:Int
    private let year:Int
    
    init(day:Int,month:Int,year:Int)
        {
        self.day = Int(day)
        self.monthIndex = Int(month)
        self.year = Int(year)
        }
        
    init(day:String,month:String,year:String)
        {
        self.day = Int(day)!
        self.monthIndex = Int(month)!
        self.year = Int(year)!
        }
    }
