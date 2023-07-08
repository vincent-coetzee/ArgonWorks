//
//  Domain.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public enum DomainError: Error
    {
    case invalidPath(String)
    case unableToReadObjectFile(String)
    case duplicateModule(String)
    case invalidObjectFile(String)
    case unableToImport
    }
    
public class Domain: Loader
    {
    public var canonicalPath: String
        {
        return("//domains/\(self.label)")
        }
        
    public let topModule: TopModule
    private let label: Label
    
    init(label: Label)
        {
        self.label = label
        fatalError()
        }
        
    public func compileIn(source:String,reportingContext: Reporter)
        {
        }
        
    public func loadIn(objectFilePath path: String) throws
        {
//        guard let url = URL(string: path) else
//            {
//            throw(DomainError.invalidPath(path))
//            }
//        guard let data = try? Data(contentsOf: url) else
//            {
//            throw(DomainError.unableToReadObjectFile(path))
//            }
//        guard let importer = try? ImportUnarchiver(forReadingFrom: data, loader: self, topModule: self.topModule) else
//            {
//            throw(DomainError.unableToImport)
//            }
//        guard let objectFile = try? importer.decodeTopLevelObject() as? ObjectFile else
//            {
//            throw(DomainError.invalidObjectFile(path))
//            }
//        guard self.topModule.lookup(label: objectFile.module.label).isNil else
//            {
//            throw(DomainError.duplicateModule(objectFile.module.label))
//            }
//        self.topModule.addSymbol(objectFile.module)
        }
    }
