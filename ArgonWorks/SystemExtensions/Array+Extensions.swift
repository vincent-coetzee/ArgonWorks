//
//  Array+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/10/21.
//

import Foundation

public func max<T>(_ array: Array<T>) -> T where T:Comparable
    {
    if array.isEmpty
        {
        fatalError("Empty array")
        }
    var value:T?
    for element in array
        {
        value = value.isNil ? element : (value! > element ? value! : element)
        }
    return(value!)
    }
    
extension Array
    {
    public func appending(_ element:Element) -> Self
        {
        var newArray = self
        newArray.append(element)
        return(newArray)
        }
    }
