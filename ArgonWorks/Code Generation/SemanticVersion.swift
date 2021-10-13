//
//  SemanticVersion.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class SemanticVersion: NSObject,NSCoding
    {
    public typealias StringLiteralType = String
    
    public let major: String
    public let minor: String
    public let patch: String
    
    init(major: String = "1",minor: String = "0",patch: String = "0")
        {
        self.major = major
        self.minor = minor
        self.patch = patch
        }
        
    init(major: Int = 1,minor: Int = 0,patch: Int)
        {
        self.major = "\(major)"
        self.minor = "\(minor)"
        self.patch = "\(patch)"
        }
        
    public required init(coder: NSCoder)
        {
        self.major = coder.decodeString(forKey: "major")!
        self.minor = coder.decodeString(forKey: "minor")!
        self.patch = coder.decodeString(forKey: "patch")!
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.major,forKey: "major")
        coder.encode(self.minor,forKey: "minor")
        coder.encode(self.patch,forKey: "patch")
        }
    }
