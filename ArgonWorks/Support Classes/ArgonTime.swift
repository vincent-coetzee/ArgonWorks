//
//  ArgonTime.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public typealias ArgonTime = Word

extension ArgonTime
    {
    public var timeDisplayString: String
        {
        "\(hour):\(minute):(second):\(millisecond)"
        }
        
    public var hour: Int
        {
        Int((self & (Argon.kTimeHour << Argon.kTimeHourShift)) >> Argon.kTimeHourShift)
        }
        
    public var minute: Int
        {
        Int((self & (Argon.kTimeMinute << Argon.kTimeMinuteShift)) >> Argon.kTimeMinuteShift)
        }
        
    public var second: Int
        {
        Int((self & (Argon.kTimeSecond << Argon.kTimeSecondShift)) >> Argon.kTimeSecondShift)
        }
        
    public var millisecond: Int
        {
        Int((self & (Argon.kTimeMillisecond << Argon.kTimeMillisecondShift)) >> Argon.kTimeMillisecondShift)
        }
        
    init(hour:Int,minute:Int,second:Int,millisecond:Int)
        {
        var word = Word(hour) << Argon.kTimeHourShift
        word |= Word(minute) << Argon.kTimeMinuteShift
        word |= Word(second) << Argon.kTimeSecondShift
        word |= Word(millisecond) << Argon.kTimeMillisecondShift
        self = word
        }
    }
