//
//  ArgonDateTime.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct ArgonDateTime:Comparable
    {
    public static func <(lhs:ArgonDateTime,rhs:ArgonDateTime) -> Bool
        {
        return(false)
        }
        
    private let date:ArgonDate
    private let time:ArgonTime
    
    init(day:String="0",month:String="0",year:String="0",hour:String="0",minute:String="0",second:String="0",millisecond:String="0")
        {
        self.date = ArgonDate(day:day,month:month,year:year)
        self.time = ArgonTime(hour:hour,minute:minute,second:second,millisecond:millisecond)
        }
    }

