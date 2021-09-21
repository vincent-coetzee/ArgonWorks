//
//  PageServer.swift
//  PageServer
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class PageServer
    {
    public static let shared = PageServer.openStore()
    
    private static let kStorePath = "/Users/vincent/Desktop/Argon.argons"
    
    private static let kPageBitCount = 14
    private static let kMaximumPageCount =  (1 << kPageBitCount) - 1
    
    public static func initializeStore(virtualMachine: VirtualMachine,pageCount: Int)
        {
        let fileHandle = fopen(Self.kStorePath,"wb+")
        var lastPageOffset = Word(0)
        var nextPageOffset = Word(Page.kPageSizeInBytes)
        for index in 0..<pageCount
            {
            if index == pageCount - 1
                {
                nextPageOffset = 0
                }
            let page = Page(virtualMachine: virtualMachine,lastPageOffset: lastPageOffset, nextPageOffset: nextPageOffset)
            page.writeToFile(fileHandle,atIndex: index)
            lastPageOffset += Word(Page.kPageSizeInBytes)
            nextPageOffset += Word(Page.kPageSizeInBytes)
            }
        fclose(fileHandle)
        }
        
    public static func openStore() -> PageServer
        {
        return(PageServer())
        }
        
    private var nextPageOffset = 512 * Page.kPageSizeInBytes
    private var fileHandle: UnsafeMutablePointer<FILE>?
    private var virtualMachine: VirtualMachine!
    
    init()
        {
        }
        
    public func findOrMakePage() -> Page
        {
        if let page = self.findFreePage()
            {
            return(page)
            }
        let page = Page(virtualMachine: self.virtualMachine,lastPageOffset: Word(self.nextPageOffset - Page.kPageSizeInBytes), nextPageOffset: Word(self.nextPageOffset + Page.kPageSizeInBytes))
        self.nextPageOffset += Page.kPageSizeInBytes
        page.writeToFile(self.fileHandle!)
        return(page)
        }
        
    private func findFreePage() -> Page?
        {
        return(nil)
        }
        
    private func loadMasterPage()
        {
        }
        
    private func loadMasterCatalogue()
        {
        }
        
    private func initPageFaultHandler()
        {
        }
        
    public func allocateString(_ string: String) -> Address
        {
        fatalError()
        }
        
    public func loadPage(fileOffset: Int) -> Page
        {
        fatalError()
        }
        
    public func loadPage(index: Word) -> Word?
        {
        return(nil)
        }
        
    public func load(into: Page,atOffset: Int)
        {
        }
    }
