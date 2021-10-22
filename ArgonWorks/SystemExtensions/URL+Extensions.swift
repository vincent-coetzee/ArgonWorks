//
//  URL+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/10/21.
//

import Foundation

extension URL
    {
    public var hasFileExtension: Bool
        {
        let string = self.absoluteString as NSString
        return(!string.pathExtension.isEmpty)
        }
        
    public var fileExtension: String
        {
        let string = self.absoluteString as NSString
        return(string.pathExtension)
        }
        
    public var isAbsoluteFilePath: Bool
        {
        let string = self.absoluteString as NSString
        return(!string.isAbsolutePath)
        }
        
    public var isFilePath: Bool
        {
        let string = self.absoluteString as NSString
        return(string.contains("/"))
        }
    }
