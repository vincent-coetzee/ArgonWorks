//
//  SourceRecord.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Foundation

public class SourceRecord:NSObject,NSCoding,AspectModel
    {
    public var lineCount: Int
        {
        self.text.components(separatedBy: "\n").count
        }
     
    public var affectedSymbols = Symbols()
    public let dependents = DependentSet()
    public let dependentKey = DependentSet.nextDependentKey
    public var text: String = ""
        {
        didSet
            {
            self.versionState = .modified
            }
        }
        
    public var attributes = Attributes()
    public var versionState: VersionState = .added
    
    public var issues = CompilerIssues()
        {
        didSet
            {
            self.changed(aspect: "issueCount",with: self.issues.count)
            }
        }
    
    public override init()
        {
        self.versionState = .added
        }
        
    required public init?(coder: NSCoder)
        {
        self.text = coder.decodeObject(forKey: "text") as! String
        self.attributes = coder.decodeObject(forKey: "attributes") as! Attributes
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.text,forKey:"text")
        coder.encode(self.attributes,forKey: "attributes")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        self.changed(aspect: "issueCount",with: self.issues.count)
        }
        
    public func value(forAspect: String) -> Any?
        {
        if forAspect == "issueCount"
            {
            return(self.issues.count)
            }
        return(nil)
        }
    }
    
public typealias SourceRecords = Array<SourceRecord>

public class SourceHistoryRecord: NSObject,NSCoding
    {
    public let date: Date
    public var previousRecord: SourceHistoryRecord?
    public let sourceRecord: SourceRecord
    
    init(date: Date,sourceRecord: SourceRecord)
        {
        self.date = date
        self.sourceRecord = sourceRecord
        self.previousRecord = nil
        }
        
    public required init?(coder: NSCoder)
        {
        self.date = (coder.decodeObject(forKey: "date") as! NSDate) as Date
        self.sourceRecord = coder.decodeObject(forKey: "sourceRecord") as! SourceRecord
        self.previousRecord = coder.decodeObject(forKey: "previousRecord") as? SourceHistoryRecord
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.date as NSDate,forKey: "date")
        coder.encode(self.sourceRecord,forKey: "sourceRecord")
        coder.encode(self.previousRecord,forKey: "previousRecord")
        }
    }

public class SourceHistory: NSObject,NSCoding
    {
    public let itemKey: Int
    public let firstRecord: SourceHistoryRecord!
    public let lastRecord: SourceHistoryRecord!
    
    public required init?(coder: NSCoder)
        {
        self.firstRecord = coder.decodeObject(forKey: "firstRecord") as? SourceHistoryRecord
        self.lastRecord = coder.decodeObject(forKey: "lastRecord") as? SourceHistoryRecord
        self.itemKey = coder.decodeInteger(forKey: "itemKey")
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.firstRecord,forKey: "firstRecord")
        coder.encode(self.lastRecord,forKey: "lastRecord")
        coder.encode(self.itemKey,forKey: "itemKey")
        }
    }
