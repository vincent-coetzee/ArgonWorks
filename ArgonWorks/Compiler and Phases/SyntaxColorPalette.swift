//
//  SemanticDictionary.swift
//  SemanticDictionary
//
//  Created by Vincent Coetzee on 11/8/21.
//

import Foundation
import AppKit

public enum SyntaxColor: String
    {
    case text
    case keyword
    case name
    case string
    case `class`
    case integer
    case float
    case symbol
    case `operator`
    case identifier
    case systemClass
    case comment
    case byte
    case character
    case type
    case method
    case function
    case boolean
    case keypath
    case path
    case slot
    case directive
    case lineNumbers
    case background
    case constant
    case enumeration
    }
    
public enum TokenColor:Int
    {
    case text
    case keyword
    case identifier
    case string
    case integer
    case float
    case comment
    case symbol
    case systemClass
    }
    
public typealias SyntaxColorPalette = Dictionary<String,NSColor>

extension SyntaxColorPalette
    {
    public static let shared =
        {
        () -> SyntaxColorPalette in
        var palette = SyntaxColorPalette()
        palette[SyntaxColor.enumeration.rawValue] = NSColor.argonThemeCyan
        palette[SyntaxColor.keyword.rawValue] = NSColor(red: 63,green: 149,blue: 116)
        palette[SyntaxColor.text.rawValue] = NSColor.argonLime
        palette[SyntaxColor.name.rawValue] = NSColor.argonXIvory
        palette[SyntaxColor.string.rawValue] = NSColor.argonXBlue
        palette[SyntaxColor.comment.rawValue] = NSColor(red: 145,green: 92,blue: 176)
        palette[SyntaxColor.class.rawValue] = NSColor(hex: 0xE7B339)
        palette[SyntaxColor.identifier.rawValue] = NSColor.argonThemePink
        palette[SyntaxColor.integer.rawValue] = NSColor.argonZomp
        palette[SyntaxColor.float.rawValue] = NSColor.argonSizzlingRed
        palette[SyntaxColor.symbol.rawValue] = NSColor.argonSalmonPink
        palette[SyntaxColor.operator.rawValue] = NSColor(hex: 0xD0EE62)
        palette[SyntaxColor.systemClass.rawValue] = NSColor.argonSalmonPink
        palette[SyntaxColor.byte.rawValue] = NSColor.argonXSmoke
        palette[SyntaxColor.character.rawValue] = NSColor.argonXSmoke
        palette[SyntaxColor.type.rawValue] = NSColor.cyan
        palette[SyntaxColor.method.rawValue] = NSColor.argonThemeBlueGreen
        palette[SyntaxColor.function.rawValue] = NSColor.argonXSeaBlue
        palette[SyntaxColor.boolean.rawValue] = NSColor.argonBayside
        palette[SyntaxColor.path.rawValue] = NSColor.argonZomp
        palette[SyntaxColor.keypath.rawValue] = NSColor.argonZomp
        palette[SyntaxColor.slot.rawValue] = NSColor.argonCoral
        palette[SyntaxColor.directive.rawValue] = NSColor.argonYellow
        palette[SyntaxColor.lineNumbers.rawValue] = NSColor(hex: 0xA0A0A0)
        palette[SyntaxColor.constant.rawValue] = NSColor.argonCheese
        palette[SyntaxColor.background.rawValue] = NSColor.black
        return(palette)
        }()
        
    public static let booleanColor = SyntaxColorPalette.shared[SyntaxColor.boolean.rawValue]!
    public static let constantColor = SyntaxColorPalette.shared[SyntaxColor.constant.rawValue]!
    public static let byteColor = SyntaxColorPalette.shared[SyntaxColor.byte.rawValue]!
    public static let characterColor = SyntaxColorPalette.shared[SyntaxColor.character.rawValue]!
    public static let classColor = SyntaxColorPalette.shared[SyntaxColor.class.rawValue]!
    public static let commentColor = SyntaxColorPalette.shared[SyntaxColor.comment.rawValue]!
    public static let directiveColor = SyntaxColorPalette.shared[SyntaxColor.directive.rawValue]!
    public static let floatColor = SyntaxColorPalette.shared[SyntaxColor.float.rawValue]!
    public static let functionColor = SyntaxColorPalette.shared[SyntaxColor.function.rawValue]!
    public static let identifierColor = SyntaxColorPalette.shared[SyntaxColor.identifier.rawValue]!
    public static let integerColor = SyntaxColorPalette.shared[SyntaxColor.integer.rawValue]!
    public static let keywordColor = SyntaxColorPalette.shared[SyntaxColor.keyword.rawValue]!
    public static let keypathColor = SyntaxColorPalette.shared[SyntaxColor.keypath.rawValue]!
    public static let methodColor = SyntaxColorPalette.shared[SyntaxColor.method.rawValue]!
    public static let nameColor = SyntaxColorPalette.shared[SyntaxColor.name.rawValue]!
    public static let operatorColor = SyntaxColorPalette.shared[SyntaxColor.operator.rawValue]!
    public static let pathColor = SyntaxColorPalette.shared[SyntaxColor.path.rawValue]!
    public static let slotColor = SyntaxColorPalette.shared[SyntaxColor.slot.rawValue]!
    public static let stringColor = SyntaxColorPalette.shared[SyntaxColor.string.rawValue]!
    public static let systemClassColor = SyntaxColorPalette.shared[SyntaxColor.systemClass.rawValue]!
    public static let symbolColor = SyntaxColorPalette.shared[SyntaxColor.symbol.rawValue]!
    public static let textColor = SyntaxColorPalette.shared[SyntaxColor.text.rawValue]!
    public static let typeColor = SyntaxColorPalette.shared[SyntaxColor.type.rawValue]!
    public static let lineNumberColor = SyntaxColorPalette.shared[SyntaxColor.lineNumbers.rawValue]!
    public static let backgroundColor = SyntaxColorPalette.shared[SyntaxColor.background.rawValue]!
    public static let enumerationColor = SyntaxColorPalette.shared[SyntaxColor.enumeration.rawValue]!
    
    public static let textFont = NSFont(name:"Menlo",size:11)!
    }
