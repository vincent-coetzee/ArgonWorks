//
//  FileSlice.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/3/22.
//

import Foundation

public typealias FileStream = UnsafeMutablePointer<FILE>

extension FileStream
    {
    public var currentOffset:Int
        {
        return(ftell(self))
        }
        
    public init?(path: String)
        {
        if let handle = fopen(path,"rb")
            {
            self = handle
            return
            }
        return(nil)
        }
        
    public func seek(to: Int)
        {
        fseek(self,to,SEEK_SET)
        }
        
    public func nextPut(_ integer: Int)
        {
        var integerValue = integer
        fwrite(&integerValue,MemoryLayout<Int>.size,1,self)
        }
        
    public func nextPut(_ string: String)
        {
        self.nextPut(string.count)
        fwrite(string,MemoryLayout<CChar>.size,string.count,self)
        }
        
    public func nextInt() -> Int
        {
        var integer: Int = 0
        fread(&integer,MemoryLayout<Int>.size,1,self)
        return(integer)
        }
        
    public func nextString() -> String?
        {
        let length = self.nextInt()
        guard length > 0 else
            {
            return(nil)
            }
        let characters = UnsafeMutablePointer<CChar>.allocate(capacity: length + 1)
        fread(characters,MemoryLayout<CChar>.size,length,self)
        let string = String(cString: characters)
        characters.deallocate()
        return(string)
        }
        
    public func writeString(_ string: String?)
        {
        var count:Int = string?.count ?? 0
        fwrite(&count,MemoryLayout<Int>.size,1,self)
        if let theString = string
            {
            var outString = theString
            fwrite(&outString,MemoryLayout<CChar>.size,count,self)
            }
        }
    }
    
public class SourceFile
    {
    private let file: FileStream
    
    init(path: String) throws
        {
        if let newFile = fopen(path,"wt+")
            {
            self.file = newFile
            }
        else
            {
            throw(CompilerIssue(location: .zero,message: "Unable to open file t '\(path)'."))
            }
        }
        
    public func checkIn(source: String)
        {
        
        }
    }
    
public class ChangeSlice
    {
    public let key: Int
    public let sourceOffset: Int
    public var previousSliceOffset: Int
    public var source = ""
    
    init(key: Int,source: String)
        {
        self.key = key
        self.source = source
        self.sourceOffset = 0
        self.previousSliceOffset = 0
        }
        
    public init(file: FileStream)
        {
        self.key = file.nextInt()
        self.sourceOffset = file.nextInt()
        self.previousSliceOffset = file.nextInt()
        self.loadSource(file: file)
        }
     
    private func loadSource(file: FileStream)
        {
        let currentOffset =  file.currentOffset
        file.seek(to: self.sourceOffset)
        self.source = file.nextString()!
        file.seek(to: currentOffset)
        }
        
    public func write(file: FileStream)
        {
        let offset = file.currentOffset
        file.nextPut(self.source)
        file.nextPut(self.key)
        file.nextPut(offset)
        file.nextPut(self.previousSliceOffset)
        }
        
    public func previousSlice(file: FileStream) -> ChangeSlice
        {
        let currentOffset = file.currentOffset
        file.seek(to: self.previousSliceOffset)
        let previousSlice = ChangeSlice(file: file)
        file.seek(to: currentOffset)
        return(previousSlice)
        }
    }

public class SliceFile
    {
    public class func openOrCreate(atPath: String) -> SliceFile
        {
        let isNew = FileManager.default.fileExists(atPath: atPath)
        let fileStream = fopen(atPath,"wb+")!
        let sliceFile = SliceFile(file: fileStream)
        sliceFile.isNew = isNew
        if isNew
            {
            fileStream.nextPut(MemoryLayout<Int>.size)
            sliceFile.lastSliceOffset = MemoryLayout<Int>.size
            }
        else
            {
            sliceFile.lastSliceOffset = fileStream.nextInt()
            }
        return(sliceFile)
        }
        
    private let file: FileStream
    public var isNew = false
    public var lastSliceOffset: Int = 0
    
    public init(file: FileStream)
        {
        self.file = file
        }
        
    public func appendSlice(_ slice: ChangeSlice)
        {
        slice.previousSliceOffset = self.lastSliceOffset
        self.lastSliceOffset = self.file.currentOffset
        slice.write(file: self.file)
        let currentOffset = file.currentOffset
        file.seek(to: 0)
        file.nextPut(self.lastSliceOffset)
        file.seek(to: currentOffset)
        }
    }
