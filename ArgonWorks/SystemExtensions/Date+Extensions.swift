//
//  Date+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import Foundation

extension Date
    {
    public static var dateFormatter: DateFormatter =
        {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        return(formatter)
        }()
        
    public var displayString: String
        {
        Date.dateFormatter.string(from: self)
        }
    }
