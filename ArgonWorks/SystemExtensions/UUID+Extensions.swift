//
//  UUID+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

fileprivate var _GeneratingSystemUUIDS = false
fileprivate var _UUIDIndex = 10

fileprivate var SystemUUIDCounter = 1
    
extension UUID
    {
    public static func startSystemUUIDs()
        {
        _GeneratingSystemUUIDS = true
        }
    
    public static func stopSystemUUIDs()
        {
        _GeneratingSystemUUIDS = false
        }
    
    init(index: Int)
        {
        let bottomString = String(format: "%012X",index)
        let string = "00000000-0000-0000-0000-" + bottomString
        self.init(uuidString: string)!
        }
        
    public static func resetSystemUUIDCounter()
        {
        SystemUUIDCounter = 1
        }
        
    public static func systemUUID(_ integer:Int) -> UUID
        {
        let index = SystemUUIDCounter
        SystemUUIDCounter += 1
        let bottomString = String(format: "%012X",index)
        let topString = String(format: "%08X",integer)
        let string = topString + "-0000-0000-0000-" + bottomString
        return(UUID(uuidString: string)!)
        }
    }
