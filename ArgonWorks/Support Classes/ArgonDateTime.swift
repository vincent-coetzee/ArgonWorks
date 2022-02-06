//
//  ArgonDateTime.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public typealias ArgonDateTime = Word

extension ArgonDateTime
    {
    public var dateTimeDisplayString: String
        {
        "\(day)/\(month)/(year) \(hour):\(minute):\(second):\(millisecond)"
        }
        
    init(day:Int,month:Int,year:Int,hour:Int,minute:Int,second:Int,millisecond:Int)
        {
        var word = Word(day) << Argon.kDateDayShift
        word |= Word(month) << Argon.kDateMonthShift
        word |= Word(year) << Argon.kDateYearShift
        word |= Word(hour) << Argon.kTimeHourShift
        word |= Word(minute) << Argon.kTimeMinuteShift
        word |= Word(second) << Argon.kTimeSecondShift
        word |= Word(millisecond) << Argon.kTimeMillisecondShift
        self = word
        }
    }
