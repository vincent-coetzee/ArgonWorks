//
//  SemanticVersion.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/3/22.
//

import Foundation

//public class GregorianVersion: NSObject,NSCoding
//    {
//    private static let k60Bits = Word(0b111111)
//    private static let kYearBits = Word(0b111111111111)
//    private static let k60BitsLength = Word(6)
//    private static let kSecondShift = Word(0 * GregorianVersion.k60BitsLength)
//    private static let kMinuteShift = Word(1 * GregorianVersion.k60BitsLength)
//    private static let kHourShift = Word(2 * GregorianVersion.k60BitsLength)
//    private static let kDayShift = Word(3 * GregorianVersion.k60BitsLength)
//    private static let kMonthShift = Word(4 * GregorianVersion.k60BitsLength)
//    private static let kYearShift = Word(5 * GregorianVersion.k60BitsLength)
//    
//    public static func versionNow() -> GregorianVersion
//        {
//        var time = time(nil)
//        let tmPointer = localtime(&time)
//        let tm = tmPointer!.pointee
//        let year = Int(tm.tm_year + 1900)
//        let month = Int(tm.tm_mon + 1)
//        let day = Int(tm.tm_mday)
//        let hour = Int(tm.tm_hour)
//        let minute = Int(tm.tm_min)
//        let second = Int(tm.tm_sec)
//        return(GregorianVersion(year: year,month: month,day: day,hour: hour,minute: minute,second: second))
//        }
//        
//    public var encodedValue: Word
//        {
//        var word = Word(self.year) << Self.kYearShift
//        word |= Word(self.month) << Self.kMonthShift
//        word |= Word(self.day) << Self.kDayShift
//        word |= Word(self.hour) << Self.kHourShift
//        word |= Word(self.minute) << Self.kMinuteShift
//        word |= Word(self.second) << Self.kSecondShift
//        return(word)
//        }
//        
//    public var displayString: String
//        {
//        let yearString = String(format: "%04d",self.year)
//        let monthString = String(format: "%02d",self.month)
//        let dayString = String(format: "%02d",self.day)
//        let hourString = String(format: "%02d",self.hour)
//        let minuteString = String(format: "%02d",self.minute)
//        let secondString = String(format: "%02d",self.second)
//        return("\(yearString)/\(monthString)/\(dayString)-\(hourString):\(minuteString):\(secondString)")
//        }
//        
//    public let year: Int
//    public let month: Int
//    public let day: Int
//    public let hour: Int
//    public let minute: Int
//    public let second: Int
//    
//    public init(file: FileStream)
//        {
//        self.year = file.nextInt()
//        self.month = file.nextInt()
//        self.day = file.nextInt()
//        self.hour = file.nextInt()
//        self.minute = file.nextInt()
//        self.second = file.nextInt()
//        }
//        
//    init(encodedValue: Word)
//        {
//        self.year = Int((encodedValue >> Self.kYearShift) & Self.kYearBits)
//        self.month = Int((encodedValue >> Self.kMonthShift) & Self.k60Bits)
//        self.day = Int((encodedValue >> Self.kDayShift) & Self.k60Bits)
//        self.hour = Int((encodedValue >> Self.kHourShift) & Self.k60Bits)
//        self.minute = Int((encodedValue >> Self.kMinuteShift) & Self.k60Bits)
//        self.second = Int((encodedValue >> Self.kSecondShift) & Self.k60Bits)
//        }
//        
//    init(year: Int,month: Int,day: Int,hour:Int,minute:Int,second:Int)
//        {
//        assert(year < 4096)
//        assert(month < 13)
//        assert(day < 32)
//        assert(hour < 60)
//        assert(minute < 60)
//        assert(second < 60)
//        self.year = year
//        self.month = month
//        self.day = day
//        self.hour = hour
//        self.minute = minute
//        self.second = second
//        }
//        
//    public required init?(coder: NSCoder)
//        {
//        self.year = coder.decodeInteger(forKey: "year")
//        self.month = coder.decodeInteger(forKey: "month")
//        self.day = coder.decodeInteger(forKey: "day")
//        self.hour = coder.decodeInteger(forKey: "hour")
//        self.minute = coder.decodeInteger(forKey: "minute")
//        self.second = coder.decodeInteger(forKey: "second")
//        }
//        
//    public func encode(with coder: NSCoder)
//        {
//        coder.encode(self.year,forKey: "year")
//        coder.encode(self.month,forKey: "month")
//        coder.encode(self.day,forKey: "day")
//        coder.encode(self.hour,forKey: "hour")
//        coder.encode(self.minute,forKey: "minute")
//        coder.encode(self.second,forKey: "second")
//        }
//    }
