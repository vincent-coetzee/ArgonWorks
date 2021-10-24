//
//  FileItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import AppKit

public typealias FileItems = Array<FileItem>

public class FileItem
    {
    public var lineNumber: Int?
        {
        return(nil)
        }
        
    public var isIssue: Bool
        {
        return(false)
        }
        
    public var tintColor: NSColor
        {
        return(NSColor.argonThemePink)
        }
        
    public var icon: NSImage
        {
        return(NSImage(named: "CartonCircleIcon")!)
        }
        
    public var displayString: String
        {
        ""
        }
        
    public var childCount: Int
        {
        return(0)
        }
        
    public var isExpandable: Bool
        {
        false
        }
        
    public func child(atIndex: Int) -> FileItem
        {
        fatalError()
        }
        
    public func configure(cell: FileItemCellView)
        {
        self.icon.isTemplate = true
        cell.imageView?.image = self.icon
        cell.imageView?.contentTintColor = self.tintColor
        cell.textField?.stringValue = self.displayString
        }
    }
    
public class PackageItem: FileItem
    {
    public override var tintColor: NSColor
        {
        return(NSColor.argonSizzlingRed)
        }
        
    public override var displayString: String
        {
        self.name + " " + self.date.displayString
        }
        
    public override var childCount: Int
        {
        self.kids.count
        }
        
    public override var isExpandable: Bool
        {
        true
        }
        
    public override func child(atIndex: Int) -> FileItem
        {
        self.kids[atIndex]
        }
        
    private let date: Date
    private let name: String
    private let path: String
    private var kids: FileItems = []
    
    init(name: String,path: String,date: Date)
        {
        self.name = name
        self.path = path
        self.date = date
        }
        
    public func appendItem(_ item: FileItem)
        {
        self.kids.append(item)
        }
    }

public class SourceItem: FileItem
    {
    public override var tintColor: NSColor
        {
        return(NSColor.argonLime)
        }
        
    public override var displayString: String
        {
        self.name
        }
        
    public override var childCount: Int
        {
        0
        }
        
    public override var isExpandable: Bool
        {
        true
        }
        
    public override func child(atIndex: Int) -> FileItem
        {
        fatalError()
        }
        
    private let name: String
    private let path: String
    
    init(name: String,path: String)
        {
        self.name = name
        self.path = path
        }
    }
    
public class WarningGroupItem: FileItem
    {
    public override var icon: NSImage
        {
        return(NSImage(systemSymbolName: "triangle.fill", accessibilityDescription: "Filled triangle")!)
        }
        
    public override var tintColor: NSColor
        {
        return(NSColor.argonBrightYellowCrayola)
        }
        
    public override var displayString: String
        {
        "Issues"
        }
        
    public override var childCount: Int
        {
        self.kids.count
        }
        
    public override var isExpandable: Bool
        {
        self.kids.count > 0
        }
        
    public override func child(atIndex: Int) -> FileItem
        {
        self.kids[atIndex]
        }
        
    private var kids: FileItems = []
    
    override init()
        {
        }
        
    public func appendIssue(line:Int,message: String)
        {
        self.kids.append(IssueItem(line:line,message: message))
        }
        
    public func appendIssue(_ issue:IssueItem)
        {
        self.kids.append(issue)
        }
        
    public func sort()
        {
        self.kids = self.kids.sorted{($0 as! IssueItem).line < ($1 as! IssueItem).line}
        }
    }

public class IssueItem: FileItem
    {
    public override var icon: NSImage
        {
        if self.kids.isEmpty
            {
            return(NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Error triangle")!)
            }
        return(NSImage(systemSymbolName: "triangle.fill", accessibilityDescription: "Filled triangle")!)
        }
        
    public override var lineNumber: Int?
        {
        return(self.line)
        }
        
    public override var isIssue: Bool
        {
        return(true)
        }
        
    public override var tintColor: NSColor
        {
        return(NSColor.argonBrightYellowCrayola)
        }
        
    public override var displayString: String
        {
        if self.line == -1
            {
            return(self.message)
            }
        return("LINE: \(self.line) \(self.message)")
        }
        
    public override var childCount: Int
        {
        self.kids.count
        }
        
    public override var isExpandable: Bool
        {
        self.kids.count > 0
        }
        
    public override func child(atIndex: Int) -> FileItem
        {
        self.kids[atIndex]
        }
        
    public let line: Int
    public let message: String
    private var kids: FileItems = []
    
    init(line: Int,message:String)
        {
        self.message = message
        self.line = line
        }
        
    public func appendSubissue(message: String)
        {
        self.kids.append(IssueItem(line: -1,message: message))
        }
    }

public class SymbolItem: FileItem
    {
    public override var tintColor: NSColor
        {
        if self.symbol.isInvokable
            {
            return(NSColor.argonThemeBlueGreen)
            }
        else if symbol.isClass
            {
            return(NSColor.argonThemePink)
            }
        else if symbol.isSlot
            {
            return(NSColor.argonThemeBlue)
            }
        return(NSColor.argonNeonOrange)
        }
        
    public override var icon: NSImage
        {
        if self.symbol.isEnumerationCase || self.symbol.isSlot
            {
            return(NSImage(systemSymbolName: "circle.circle", accessibilityDescription: nil)!)
            }
        if self.symbol.isModule
            {
            return(NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)!)
            }
        if self.symbol.isInvokable
            {
            return(NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: nil)!)
            }
        return(NSImage(systemSymbolName: "circle.dashed", accessibilityDescription: nil)!)
        }
        
    public override var displayString: String
        {
        self.symbol.displayString
        }
        
    public override var childCount: Int
        {
        self.kids.count
        }
        
    public override var isExpandable: Bool
        {
        self.kids.count > 0
        }
        
    public override func child(atIndex: Int) -> FileItem
        {
        self.kids[atIndex]
        }
        
    public let symbol: Symbol
    private var kids: FileItems = []
    
    init(symbol: Symbol)
        {
        self.symbol = symbol
        self.kids = self.symbol.children.map{SymbolItem(symbol: $0)}
        }
    }
