//
//  ListView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/10/21.
//

import AppKit

public protocol ListViewDelegate
    {
    func listView(_ listView: ListView,didSelectView: NSView)
    }
    
public class ListView: NSView, NSTableViewDataSource, NSTableViewDelegate
    {
    @IBOutlet var tableView: NSTableView!
    
    public var delegate: ListViewDelegate?
    
    public var list: Array<NSView>?
        {
        didSet
            {
            if self.list.isNotNil
                {
                self.tableView.reloadData()
                }
            }
        }
        
    public var stringList: Array<String>?
        {
        didSet
            {
            if self.stringList.isNotNil
                {
                self.list = []
                for string in self.stringList!
                    {
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableCellView"), owner: nil) as? NSTableCellView
                        {
                        cell.textField?.stringValue = string
                        self.list?.append(cell)
                        }
                    }
                self.tableView.reloadData()
                }
            }
        }
    
    
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        let nib = NSNib(nibNamed: "ListView",bundle: nil)
        nib?.instantiate(withOwner: self, topLevelObjects: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
        
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        let nib = NSNib(nibNamed: "ListView",bundle: nil)
        nib?.instantiate(withOwner: self, topLevelObjects: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        }
    
    public func tableViewSelectionDidChange(_ notification: Notification)
        {
        let row = self.tableView.selectedRow
        if row != -1
            {
            let view = self.list![row]
            self.delegate?.listView(self, didSelectView: view)
            }
        }
        
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
//        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableCellView"), owner: nil) as? NSTableCellView
//            {
//            cell.textField?.stringValue = self.list![row]
//            return(cell)
//            }
        return(self.list![row])
        }
        
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        return(self.list?.count ?? 0)
        }
    }
