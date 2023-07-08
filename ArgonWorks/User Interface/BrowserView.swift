//
//  BrowserView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/9/21.
//

import Cocoa

class BrowserView: NSView,Pane
    {
    public var layoutFrame: LayoutFrame = .zero
    
    private let browser = SymbolBrowserView()
    
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        self.initBrowser()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initBrowser()
        {
        let header = HeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(header)
        header.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        header.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        header.bottomAnchor.constraint(equalTo: self.topAnchor,constant: 20).isActive = true
        browser.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(browser)
        self.browser.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.browser.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.browser.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        self.browser.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
    public func setBrowserColor(_ color:NSColor,childType: ChildType,initialSymbols: Symbols)
        {
        browser.foregroundColor = color
        browser.iconTintColor = color
        browser.childType = childType
        browser.symbols = initialSymbols
        }
    }
    
