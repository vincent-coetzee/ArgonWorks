//
//  ProcessorViewController.swift
//  ProcessorViewController
//
//  Created by Vincent Coetzee on 20/8/21.
//

import Cocoa

class ProcessorViewController: NSViewController
    {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var registersController: RegistersViewController!
    
    private var buffer: InstructionBuffer!
    
    private let virtualMachine = VirtualMachine.small
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.buffer = InstructionBuffer.samples(in: self.virtualMachine)
        }
        
    @IBAction func onLoadMethodClicked(_ sender:Any?)
        {
        }
        
    @IBAction func onForwardClicked(_ sender:Any?)
        {
//        let registersViewController = (self.view.window!.windowController as! ProcessorWindowController).registersViewController
        }
    
    }

extension ProcessorViewController: NSTableViewDataSource
    {
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        return(buffer.count)
        }
    }


extension ProcessorViewController: NSTableViewDelegate
    {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InstructionCellView"), owner: nil) as! InstructionCellView
        view.instruction = buffer[row]
        return(view)
        } 
    }
