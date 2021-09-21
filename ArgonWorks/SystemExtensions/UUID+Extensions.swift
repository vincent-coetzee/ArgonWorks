//
//  UUID+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

fileprivate var _GeneratingSystemUUIDS = false
fileprivate var _UUIDIndex = 1

public func startGeneratingSystemUUIDs()
    {
    _GeneratingSystemUUIDS = true
    }
    
public func stopGeneratingSystemUUIDs()
    {
    _GeneratingSystemUUIDS = false
    }
    
extension UUID
    {
    public static func newUUID() -> UUID
        {
        if _GeneratingSystemUUIDS
            {
            //"E621E1F8-C36C-495A-93FC-0C247A3E6E5F".
            let index = _UUIDIndex
            _UUIDIndex += 1
            let bottomString = String(format: "%012X",index)
            return(UUID(uuidString: "00000000-0000-0000" + bottomString)!)
            }
        else
            {
            return(UUID())
            }
        }
    }
