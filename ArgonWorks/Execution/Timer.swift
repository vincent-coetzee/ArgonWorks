//
//  Timer.swift
//  Timer
//
//  Created by Vincent Coetzee on 1/8/21.
//

import Foundation

public class Timer
    {
    public func milliseconds() -> Int
        {
        var time:timeval = timeval()
        time.tv_sec = 0
        time.tv_usec = 0
        gettimeofday(&time,nil)
        let millis = time.tv_sec * 1000 + Int(time.tv_usec) / 1000
        return(millis)
        }
     
     public var displayString: String
        {
        return("\(self.stop()) milliseconds")
        }
        
    private var startTime:Int = 0
    
    init()
        {
        self.start()
        }
        
    public func time(_ closure: () -> Void) -> Int
        {
        self.start()
        closure()
        return(self.stop())
        }
        
    public func start()
        {
        self.startTime = self.milliseconds()
        }
        
    public func stop() -> Int
        {
        return(self.milliseconds() - self.startTime)
        }
    }
