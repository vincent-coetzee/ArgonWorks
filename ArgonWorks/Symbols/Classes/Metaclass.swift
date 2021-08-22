//
//  Metaclass.swift
//  Metaclass
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class Metaclass: Class
    {
    public override var displayString: String
        {
        return("\(self.label) class")
        }
        
    public override var isMetaclassClass: Bool
        {
        return(true)
        }
        
    private let theClass: Class?
    
    public override var metaclass: Metaclass?
        {
        return(nil)
        }
        
    public init(label:Label,class:Class?)
        {
        self.theClass = `class`
        super.init(label: label)
        }
}
