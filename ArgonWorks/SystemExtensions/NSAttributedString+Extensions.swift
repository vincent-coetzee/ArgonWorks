//
//  NSAttributedString+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 1/3/22.
//

import Foundation

extension NSAttributedString
    {
    public var attributes: Dictionary<NSAttributedString.Key,Any>
        {
        var range: NSRange = NSRange(location: 0,length: 0)
        let dict = self.attributes(at: 0, effectiveRange: &range)
        return(dict)
        }
    }
