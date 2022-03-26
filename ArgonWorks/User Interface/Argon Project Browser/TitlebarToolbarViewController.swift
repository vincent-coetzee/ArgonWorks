//
//  TitlebarToolbarViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/3/22.
//

import Cocoa

public class TitlebarToolbarViewController: NSTitlebarAccessoryViewController
    {
    init()
        {
        super.init(nibName: nil, bundle: nil)
        self.layoutAttribute =  .left
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView()
        {
        self.view = NSSegmentedControl(labels: ["a","b","c","d"], trackingMode: .selectOne, target: self, action: #selector(self.buttonSelected))
        }
        
    @IBAction func buttonSelected(_ any: Any?)
        {
        }
        
    public override func viewDidLayout()
        {
        super.viewDidLayout()
        var frame = self.view.frame
        frame.size.width = 160
        self.view.frame = frame
        }
    }
