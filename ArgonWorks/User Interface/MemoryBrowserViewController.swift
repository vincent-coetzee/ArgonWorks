//
//  MemoryBrowserViewController.swift
//  MemoryBrowserViewController
//
//  Created by Vincent Coetzee on 20/8/21.
//

import Cocoa

public class MemorySlotItem
    {
    internal static let itemFont = NSFont(name: "Menlo",size: 10)!
    internal static let smallItemFont = NSFont(name: "Menlo",size: 8)!
    public let word: Word
    public let address: Word
    public var line: NSAttributedString

    public var childCount: Int
        {
        return(0)
        }
        
    public var isExpandable: Bool
        {
        return(false)
        }
        
    init(address: Word,word: Word)
        {
        self.address = address
        self.word = word
        let string = "0x\(self.address.addressString) -- \(self.word.bitString)"
        self.line = NSAttributedString(string: string,attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemeBlueGreen])
        }
        
    public func child(atIndex: Int) -> MemorySlotItem
        {
        fatalError()
        }
    }
    
public class MemoryObjectItem: MemorySlotItem
    {
    private let header: Header
    private let sizeInWords: Int
    private var children: Array<MemorySlotItem>?
    
    public override var childCount: Int
        {
        if self.children.isNil
            {
            self.buildChildren()
            }
        return(self.children!.count)
        }
        
    public override var isExpandable: Bool
        {
        return(true)
        }
        
    override init(address: Word,word: Word)
        {
        self.header = Header(word: word)
        self.sizeInWords = header.sizeInWords
        super.init(address: address,word: word)
        let string = "0x\(self.address.addressString) ---- \(self.word.bitString)"
        self.line = NSAttributedString(string: string,attributes: [.font: Self.itemFont,.foregroundColor: NSColor.systemGray])
        self.buildClassData()
        }
        
    private func buildClassData()
        {
//        if self.children.isNil
//            {
//            self.buildChildren()
//            }
//        let classAddress = self.children![1].word
//        let theClass = Class.classesByAddress[classAddress]
//        guard theClass.isNotNil else
//            {
//            let string = "0x\(self.address.addressString) ---- \(self.word.bitString)"
//            self.line = NSAttributedString(string: string,attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemePink])
//            let mutableString = NSMutableAttributedString(attributedString: self.line)
//            mutableString.append(NSAttributedString(string:" NO CLASS DATA FOUND",attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemePink]))
//            self.line = mutableString
//            return
//            }
//        var index = 0
//        for slot in theClass!.laidOutSlots.sorted(by: {$0.offset < $1.offset}).dropFirst()
//            {
//            let mutableString = NSMutableAttributedString(attributedString: self.children![index].line)
//            mutableString.append(NSAttributedString(string:" \(slot.label)",attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemeGreen]))
//            self.children![index].line = mutableString
//            if index == 0
//                {
//                print("MAGIC NUMBER IS \(Int(bitPattern: UInt(self.children![index].word)))")
//                }
//            if index == 1
//                {
//                let mutableString = NSMutableAttributedString(attributedString: self.children![index].line)
//                mutableString.append(NSAttributedString(string:" \(theClass!.label)",attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemePink]))
//                self.children![index].line = mutableString
//                }
//            if slot.isStringSlot
//                {
//                let string = InnerStringPointer(address: self.children![index].word).string
//                let mutableString = NSMutableAttributedString(attributedString: self.children![index].line)
//                mutableString.append(NSAttributedString(string: " \(string)",attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemePink]))
//                self.children![index].line = mutableString
//                }
//            if slot.isArraySlot
//                {
//                let anAddress = self.children![index].word
//                if anAddress == 0
//                    {
//                    self.children![index] = MemorySlotItem(address: 0,word: 0)
//                    }
//                else
//                    {
//                    let aWord = WordPointer(address: anAddress)![0]
//                    self.children![index] = MemoryArrayItem(address: anAddress,word: aWord,label: slot.label)
//                    }
//                }
//            index += 1
//            }
        }
        
    public override func child(atIndex: Int) -> MemorySlotItem
        {
        if self.children.isNil
            {
            self.buildChildren()
            }
        return(children![atIndex])
        }
        
    private func buildChildren()
        {
//        guard self.children.isNil else
//            {
//            return
//            }
//        self.children = []
//        let wordPointer = WordPointer(address: self.address)!
//        for index in 1..<self.sizeInWords
//            {
//            let word = wordPointer[index]
//            let wordAddress = self.address + Word(MemoryLayout<Word>.size * index)
//            children!.append(MemorySlotItem(address: wordAddress,word: word))
//            }
        }
    }
    
public class MemoryArrayItem: MemorySlotItem
    {
//    private let pointer: InnerArrayPointer
    private var children: Array<MemorySlotItem>?
    private let label: String
    
    public override var isExpandable: Bool
        {
        return(true)
        }
        
    init(address: Word,word: Word,label: String)
        {
//        self.pointer = InnerArrayPointer(address: address)
        self.label = label
        super.init(address: address,word: word)
        let mutableString = NSMutableAttributedString(attributedString: self.line)
        mutableString.append(NSAttributedString(string:" \(label)",attributes: [.font: Self.itemFont,.foregroundColor: NSColor.argonThemeOrange]))
        self.line = mutableString
        }
        
    public override var childCount: Int
        {
        if self.children.isNil
            {
            self.buildChildren()
            }
        return(self.children!.count)
        }
        
    private func buildChildren()
        {
//        self.children = []
//        for index in 0..<pointer.count
//            {
//            let address = pointer[index]
//            let aWord = WordPointer(address: address)![0]
//            self.children!.append(MemoryObjectItem(address: address,word: aWord))
//            }
        }
        
    public override func child(atIndex: Int) -> MemorySlotItem
        {
        if self.children.isNil
            {
            self.buildChildren()
            }
        return(self.children![atIndex])
        }
    }
//    
//class MemoryBrowserViewController: NSViewController
//    {
//    @IBOutlet var outliner: NSOutlineView!
//    
//    private var virtualMachine = VirtualMachine.small
//    private var memorySlots = Array<MemorySlotItem>()
//    
//    override func viewDidLoad()
//        {
//        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(windowResizedNotification(_:)), name: NSWindow.didResizeNotification, object: self.view.window)
//        let startAddress = self.virtualMachine.managedSegment.startOffset
//        let endAddress = self.virtualMachine.managedSegment.endOffset
//        var address = startAddress
//        var index = 0
//        let wordPointer = WordPointer(address: address)!
//        while address < endAddress
//            {
//            let header = Header(wordPointer[index])
//            self.memorySlots.append(MemoryObjectItem(address: address,word: wordPointer[index]))
//            index += header.sizeInWords
//            address += Word(header.sizeInWords * MemoryLayout<Word>.size)
//            }
//        self.outliner.reloadData()
//        }
//        
//    public override func viewDidAppear()
//        {
//        super.viewDidAppear()
//        if let rectObject = RectObject(forKey: UserDefaultsKey.memoryWindowRectangle.rawValue,on: UserDefaults.standard)
//            {
//            self.view.window?.setFrame(rectObject.rect, display: true, animate: true)
//            }
//        }
//        
//    @IBAction func windowResizedNotification(_ notification:NSNotification)
//        {
//        if let frame = self.view.window?.frame
//            {
//            let rectObject = RectObject(frame)
//            rectObject.setValue(forKey: UserDefaultsKey.memoryWindowRectangle.rawValue,on: UserDefaults.standard)
//            }
//        }
//    }
//    
//extension MemoryBrowserViewController: NSOutlineViewDataSource
//    {
//    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
//        {
//        if item == nil
//            {
//            return(self.memorySlots.count)
//            }
//        else
//            {
//            let slot = item as! MemorySlotItem
//            return(slot.childCount)
//            }
//        }
//
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
//        {
//        if item.isNil
//            {
//            return(self.memorySlots[index])
//            }
//        else if let slot = item as? MemorySlotItem
//            {
//            return(slot.child(atIndex: index))
//            }
//        fatalError()
//        }
//
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
//        {
//        let slot = item as! MemorySlotItem
//        return(slot.isExpandable)
//        }
//    }
//
//extension MemoryBrowserViewController:NSOutlineViewDelegate
//    {
//    public func outlineViewSelectionDidChange(_ notification: Notification)
//        {
//        }
//        
//    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
//        {
//        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MemorySlotCellView"), owner: nil) as! MemorySlotCellView
//        let anItem = item as! MemorySlotItem
//        view.memorySlotItem = anItem
//        view.textField?.attributedStringValue = anItem.line
//        return(view)
//        }
//        
////    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
////        {
////        let view = RowView(selectionColor: ArgonPalette.shared.kModuleColor)
////        return(view)
////        }
//    }
//
//
