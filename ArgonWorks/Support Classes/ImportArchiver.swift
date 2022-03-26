//
//  ImportArchiver.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/10/21.
//

import Foundation

public class ImportArchiver: NSKeyedArchiver
    {
    public override init(requiringSecureCoding: Bool)
        {
        super.init(requiringSecureCoding: requiringSecureCoding)
        }
        
    public override init()
        {
        super.init()
        }
    }
