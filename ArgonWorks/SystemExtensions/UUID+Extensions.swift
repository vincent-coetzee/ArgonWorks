//
//  UUID+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

fileprivate var _GeneratingSystemUUIDS = false
fileprivate var _UUIDIndex = 10


    
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
        
    public static func newUUID() -> UUID
        {
        if _GeneratingSystemUUIDS
            {
            //"E621E1F8-C36C-495A-93FC-0C247A3E6E5F".
            let index = _UUIDIndex
            _UUIDIndex += 1
            let bottomString = String(format: "%012X",index)
            let string = "00000000-0000-0000-0000-" + bottomString
            return(UUID(uuidString: string)!)
            }
        else
            {
            return(UUID())
            }
        }
    }
