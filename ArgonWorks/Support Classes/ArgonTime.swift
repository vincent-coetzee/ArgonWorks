//
//  ArgonTime.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct ArgonTime:Comparable,Hashable
    {
    public static func <(lhs:ArgonTime,rhs:ArgonTime) -> Bool
        {
        return(false)
        }
        
    private let hour:UInt
    private let minute:UInt
    private let second:UInt
    private let millisecond:UInt
    
    init(hour:Int,minute:Int,second:Int,millisecond:Int = 0)
        {
        self.hour = UInt(hour)
        self.minute = UInt(minute)
        self.second = UInt(second)
        self.millisecond = UInt(millisecond)
        }
    
    init(hour:String,minute:String,second:String,millisecond:String = "0")
        {
        self.hour = UInt(hour)!
        self.minute = UInt(minute)!
        self.second = UInt(second)!
        self.millisecond = UInt(millisecond)!
        }
    }
