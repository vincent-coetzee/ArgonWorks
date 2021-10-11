//
//  SettingsPanelViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/10/21.
//

import Cocoa

class SettingsPanelViewController: NSViewController
    {
    @IBOutlet var tableView: NSTableView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        // Do view setup here.
        }
    
    @IBAction func onCancelClicked(_ sender: Any?)
        {
        let controller = self.view.window?.windowController
        controller?.dismissController(self)
        self.view.window?.orderOut(self)
        }

    @IBAction func onSaveClicked(_ sender: Any?)
        {
        }
    }

extension SettingsPanelViewController: NSTableViewDataSource
    {
    }
    
extension SettingsPanelViewController: NSTableViewDelegate
    {
    }
