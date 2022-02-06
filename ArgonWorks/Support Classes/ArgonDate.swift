//
//  ArgonDate.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public typealias ArgonDate = Word

extension ArgonDate
    {
    public var dateDisplayString: String
        {
        "\(day)/\(month)/(year)"
        }
        
    public var day: Int
        {
        Int((self & (Argon.kDateDay << Argon.kDateDayShift)) >> Argon.kDateDayShift)
        }
        
    public var month: Int
        {
        Int((self & (Argon.kDateMonth << Argon.kDateMonthShift)) >> Argon.kDateMonthShift)
        }
        
    public var year: Int
        {
        Int((self & (Argon.kDateYear << Argon.kDateYearShift)) >> Argon.kDateYearShift)
        }
        
    init(day:Int,month:Int,year:Int)
        {
        var word = Word(day) << Argon.kDateDayShift
        word |= Word(month) << Argon.kDateMonthShift
        word |= Word(year) << Argon.kDateYearShift
        self = word
        }
    }
