//
//  Capsule.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import Foundation

public class Capsule
    {
    public let path: URL
    public let date: Date
    public let key: UUID
    public var source: String = ""
    
    init(path: URL)
        {
        self.path = path
        self.date = Date()
        self.key = UUID()
        }
    }
