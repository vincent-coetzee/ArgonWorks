//
//  ArgonProjectDocument.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 4/7/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType
    {
    static var argonProject: UTType
        {
        UTType(exportedAs: "com.macsemantics.argon.project")
        }
    }

struct ProjectDocument: FileDocument
    {
    var text: String

    init(text: String = "Hello, world!")
        {
        self.text = text
        }

    static var readableContentTypes: [UTType] { [.argonProject] }

    init(configuration: ReadConfiguration) throws
        {
        guard let data = configuration.file.regularFileContents,let string = String(data: data, encoding: .utf8) else
            {
            throw CocoaError(.fileReadCorruptFile)
            }
        text = string
        }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
        {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
        }
    }
