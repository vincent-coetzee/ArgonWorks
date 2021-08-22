//
//  EnglishWord.swift
//  EnglishWord
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public struct EnglishWord
    {
    public var word:String
        {
        return(self.string)
        }
        
    private let string: String
    
    public static func allWords() -> Array<EnglishWord>
        {
            let path = Bundle.main.url(forResource: "words", withExtension: "txt")!
        let string = try! String(contentsOf: path)
        return(string.components(separatedBy: "\r\n").map{EnglishWord($0)})
        }
        
    public static func randomWords(maximum:Int) -> Array<EnglishWord>
        {
        let allWords = Self.allWords()
        let count = Int.random(in: 0...maximum)
        let total = allWords.count
        var selectedWords = Array<EnglishWord>()
        while selectedWords.count < count
            {
            let index = Int.random(in: 0...total - 1)
            selectedWords.append(allWords[index])
            }
        return(selectedWords)
        }
        
    init(_ string:String)
        {
        self.string = string
        }
    }
