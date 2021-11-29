//
//  Macro.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 11/10/21.
//

import Foundation

public class MacroParameter: Symbol
    {
    public var value: String = ""

    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        self.value = coder.decodeString(forKey: "value")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.value,forKey: "value")
        super.encode(with: coder)
        }
    }
   
public typealias MacroParameters = Array<MacroParameter>

public class Macro: Symbol
    {
    public var parameterCount: Int
        {
        return(self.parameters.count)
        }
        
    private var text: String
    private var parameters: Array<MacroParameter> = []
    
    init(label: Label,parameters: MacroParameters,text: String)
        {
        self.parameters = parameters
        self.text = text
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        self.text = coder.decodeString(forKey: "text")!
        self.parameters = coder.decodeObject(forKey: "parameters") as! MacroParameters
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        self.text = ""
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.text,forKey: "text")
        coder.encode(self.parameters,forKey: "parameters")
        super.encode(with: coder)
        }
        
    public func applyParameters(_ elements:Array<Token>) -> String
        {
        let count = min(elements.count,self.parameterCount)
        var theString = self.text
        for index in 0..<count
            {
            let replacement = elements[index].stringValue
            let name = self.parameters[index].label
            var parameterName = "%%\(name)"
            var string = theString as NSString
            theString = string.replacingOccurrences(of: parameterName, with: "\"\(replacement)\"")
            parameterName = "%\(name)"
            string = theString as NSString
            theString = string.replacingOccurrences(of: parameterName, with: replacement)
            }
        return(theString)
        }
}
