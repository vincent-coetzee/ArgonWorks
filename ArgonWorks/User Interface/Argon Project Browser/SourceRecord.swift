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
        
    public var itemKey: Int!
    public var primarySymbol: Symbol!
    public var attributes = Attributes()
    public var versionState: VersionState = .added
    public unowned var elementItem: ProjectElementItem!
    
    public var issues = CompilerIssues()
        {
        didSet
            {
            let warnings = self.issues.filter{$0.isWarning}.count
            let errors = self.issues.filter{!$0.isWarning}.count
            self.changed(aspect: "warningCount",with: warnings)
            self.changed(aspect: "errorCount",with: errors)
            }
        }
    
    public override init()
        {
        self.versionState = .added
        super.init()
        }
        
    required public init?(coder: NSCoder)
        {
        self.elementItem = coder.decodeObject(forKey: "elementItem") as? ProjectElementItem
        self.text = coder.decodeObject(forKey: "text") as! String
        self.attributes = coder.decodeObject(forKey: "attributes") as! Attributes
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.elementItem,forKey: "elementItem")
        coder.encode(self.text,forKey:"text")
        coder.encode(self.attributes,forKey: "attributes")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        self.issuesChanged()
        }
        
    internal func issuesChanged()
        {
        let aProject = self.elementItem.project
        let issues = aProject.allIssues
        let errorCount = issues.filter{!$0.isWarning}.count
        let warningCount = issues.filter{$0.isWarning}.count
        aProject.changed(aspect: "warningCount",with: warningCount,from: aProject)
        aProject.changed(aspect: "errorCount",with: errorCount,from: aProject)
        self.changed(aspect: "warningCount",with: self.issues.filter{$0.isWarning}.count,from: self)
        self.changed(aspect: "errorCount",with: self.issues.filter{!$0.isWarning}.count,from: self)
        }
        
    public func value(forAspect: String) -> Any?
        {
        if forAspect == "warningCount"
            {
            return(self.issues.filter{$0.isWarning}.count)
            }
        if forAspect == "errorCount"
            {
            return(self.issues.filter{!$0.isWarning}.count)
            }
        if forAspect == "lineCount"
            {
            return(self.text.components(separatedBy:"\n").count)
            }
        return(nil)
        }
        
    public func compilationDidSucceed(_ browserEditorView: BrowserEditorView,symbolValue: SymbolValue,affectedSymbols: Symbols)
        {
        self.elementItem.symbolValue = symbolValue
        }
        
    public func compilationDidFail(_ browserEditorView: BrowserEditorView,issues: CompilerIssues)
        {
        }
        
    public func sourceDidChange(_ sourceEditorView: BrowserEditorView)
        {
        self.text = sourceEditorView.sourceString
        let lineCount = self.text.components(separatedBy: "\n").count
        self.changed(aspect: "lineCount",with: lineCount,from: self)
        }
        
    public func sourceEditingDidBegin(_ browserEditorView: BrowserEditorView)
        {
        }
        
    public func sourceEditingDidEnd(_ browserEditorView: BrowserEditorView)
        {
        }
        
    public func compilationWillStart(_ browserEditorView: BrowserEditorView)
        {
        self.issues = []
        self.issuesChanged()
        self.text = browserEditorView.sourceString
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
