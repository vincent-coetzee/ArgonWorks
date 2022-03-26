//
//  PlaceholderSymbol.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/2/22.
//

import Foundation

public class PlaceholderSymbol: Symbol
    {
    private static var count: Int = 1
    
    internal let number: Int
    
    required init(label: String)
        {
        self.number = Self.count
        Self.count += 1
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    }
