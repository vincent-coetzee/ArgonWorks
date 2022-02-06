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
        
    public static func randomWordsWithDuplicates(maximum: Int) -> Array<EnglishWord>
        {
        var words = Self.randomWords(maximum: maximum)
        var index = 0
        while index < words.count
            {
            let count = Int.random(in: 0..<10)
            for _ in 0..<count
                {
                let target = Int.random(in: 0..<words.count-1)
                words.insert(words[index], at: target)
                }
            index += 5
            }
        return(words)
        }
        
    init(_ string:String)
        {
        self.string = string
        }
    }
