//
//  NSColor+Extensions.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation
import AppKit
import SwiftUI

extension NSColor
    {
    public static let argonLawnGreen:NSColor = NSColor(hex: 0x7cfc00)
    public static let argonChinesePurple:NSColor = NSColor(hex: 0x720B98)
    public static var argonYellow:NSColor = NSColor(red:247,green:194,blue:66)
    public static var argonXcodePink:NSColor = NSColor(red:255,green:0,blue:123)
    public static let argonRed:NSColor = NSColor(red:215,green:74,blue:91)
    public static let argonCoral:NSColor = NSColor(red:238,green:135,blue:118)
    public static let argonPink:NSColor = NSColor(red:231,green:77,blue:144)
    public static let argonBlue:NSColor = NSColor(red:56,green:125,blue:127)
    public static let argonPurple:NSColor = NSColor(red:171,green:69,blue:228)
    public static let argonGreen:NSColor = NSColor(red:104,green:190,blue:157)
    public static let argonCyan:NSColor = NSColor(red:87,green:200,blue:188)
    public static let argonDeepOrange:NSColor = NSColor(hex: 0xFF8000)
    public static let argonCheese:NSColor = NSColor(hex: 0xffa600)
    public static let argonSizzlingRed:NSColor = NSColor(hex: 0xff3855)
    public static let argonCetaceanBlue:NSColor = NSColor(hex: 0x001440)
    public static let argonPomelo:NSColor = NSColor(hex: 0x408000)
    public static let argonPersianRose:NSColor = NSColor(hex: 0xfe28a2)
    public static let argonZomp:NSColor = NSColor(hex: 0x39a78e)
    public static let argonChartreuse:NSColor = NSColor(hex: 0xdfff00)
    public static let argonSalmonPink:NSColor = NSColor(hex: 0xff91a4)
    public static let argonNeonFuchsia:NSColor = NSColor(hex: 0xfe4164)
    public static let argonIvory:NSColor = NSColor(hex: 0xf5e1a4)
    public static let argonStoneTerrace:NSColor = NSColor(hex: 0xa09484)
    public static let argonBayside:NSColor = NSColor(hex: 0x5fc9bf)
    public static let argonMangoGreen:NSColor = NSColor(hex: 0x96ff00)
    public static let argonSeaGreen:NSColor = NSColor(hex: 0x007563)
    public static let argonDarkGray:NSColor = NSColor(hex: 0x121212)
    public static let argonNeonYellow:NSColor = NSColor(hex: 0xF3F315)
    public static let argonNeonOrange = NSColor(red: 237.0/255.0,green: 111.0/255.0,blue:45.0/255.0,alpha:1)
    public static let argonNeonGreen = NSColor(red: 128.0/255.0,green: 189.0/255.0,blue:4.0/255.0,alpha:1)
    public static let argonPlainPink = NSColor(red: 255.0/255.0,green: 0.0/255.0,blue:123.0/255.0,alpha:1)
    public static let argonKeywordGreen = NSColor(red: 0/255.0,green: 144/255.0,blue:99/255.0,alpha:1)
    public static let argonConstantBlue = NSColor(red: 0/255.0,green: 195.0/255.0,blue:175.0/255.0,alpha:1)
    public static let argonNamingYellow = NSColor(red: 255.0/255.0,green: 181.0/255.0,blue:0.0/255.0,alpha:1)
    public static let argonLime = NSColor(red: 122.0/255.0,green: 154.0/255.0,blue:1.0/255.0,alpha:1)
    public static let argonNeonPink = NSColor(red: 255.0/255.0,green: 0/255.0,blue:153.0/255.0,alpha:1)
    public static let argonSexyPink = NSColor(red: 255.0/255.0,green: 63/255.0,blue:131/255.0,alpha:1)
        
    public static let argonXGreen = NSColor(hex: 0x80BD04)
    public static let argonXOrange = NSColor(hex: 0xFD8F3F)
    public static let argonXBlue = NSColor(hex: 0x00C3AF)
    public static let argonXPurple = NSColor(hex: 0xAA0D91)
    public static let argonXGray = NSColor(hex: 0x0A0A0A)
    public static let argonXCoral = NSColor(hex: 0xFC6A5D)
    public static let argonXIvory = NSColor(hex: 0xD08F69)
    public static let argonXWhite = NSColor(hex: 0xCCCCCC)
    public static let argonXSmoke = NSColor(hex: 0x738276)
    public static let argonXSeaBlue = NSColor(hex: 0x108080)
    public static let argonXCornflower = NSColor(hex: 0x5482FF)
    public static let argonXKeyword = NSColor(hex: 0x009063)
    public static let argonXLightBlue = NSColor(hex: 0x009586)
    public static let argonXIdentifier = NSColor(hex: 0x80BD04)
    
    public static let argonThemeBlueGreen = NSColor(hex: 0x009063)
    public static let argonThemeOrange = NSColor(hex: 0xFD8F3F)
    public static let argonThemeGreen = NSColor(hex: 0x80BD04)
    public static let argonThemeCyan = NSColor(hex: 0x00C3AF)
    public static let argonThemeBlue = NSColor(hex: 0x0095B6)
    public static let argonThemePink = NSColor(hex: 0xFF007B)
    
    public var swiftUIColor: Color
        {
        var components:[CGFloat] = [0,0,0]
        self.getComponents(&components)
        return(Color(red:components[0],green:components[1],blue:components[2]))
        }
        
    convenience init(red:Int,green:Int,blue:Int)
        {
        self.init(red: CGFloat(red)/255.0,green: CGFloat(green)/255.0,blue:CGFloat(blue)/255.0,alpha: 1.0)
        }
        
    convenience init(hex:Int)
        {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: CGFloat(red)/255.0,green: CGFloat(green)/255.0,blue:CGFloat(blue)/255.0,alpha: 1.0)
        }
        
    public func withAlpha(_ alpha:CGFloat) -> NSColor
        {
        var components:[CGFloat] = [0,0,0]
        self.getComponents(&components)
        return(NSColor(red:components[0],green:components[1],blue:components[2],alpha: alpha))
        }
    }

