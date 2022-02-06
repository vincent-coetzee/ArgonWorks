//
//  Register.swift
//  Register
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public enum RegisterIndex:Int,CaseIterable,Comparable
    {
    public static func < (lhs: RegisterIndex, rhs: RegisterIndex) -> Bool
        {
        lhs.rawValue < rhs.rawValue
        }
    
    case NONE = 0
    case STACK = 184
    case FRAME = 1
    case CODE = 2
    case IP = 3
    case RESULT = 4
    case GPR1 = 20
    case GPR2 = 21
    case GPR3 = 22
    case GPR4 = 23
    case GPR5 = 24
    case GPR6 = 25
    case GPR7 = 26
    case GPR8 = 27
    case GPR9 = 28
    case GPR10 = 29
    case GPR11 = 30
    case GPR12 = 31
    case GPR13 = 32
    case GPR14 = 33
    case GPR15 = 34
    case GPR16 = 35
    case GPR17 = 36
    case GPR18 = 37
    case GPR19 = 38
    case GPR20 = 39
    case GPR21 = 40
    case GPR22 = 41
    case GPR23 = 42
    case GPR24 = 43
    case GPR25 = 44
    case GPR26 = 45
    case GPR27 = 46
    case GPR28 = 47
    case GPR29 = 48
    case GPR30 = 49
    case GPR31 = 50
    case GPR32 = 51
    case GPR33 = 52
    case GPR34 = 53
    case GPR35 = 54
    case GPR36 = 55
    case GPR37 = 56
    case GPR38 = 57
    case GPR39 = 58
    case GPR40 = 59
    case GPR41 = 60
    case GPR42 = 61
    case GPR43 = 62
    case GPR44 = 63
    case GPR45 = 64
    case GPR46 = 65
    case GPR47 = 66
    case GPR48 = 67
    case GPR49 = 68
    case GPR50 = 69
    case GPR51 = 70
    case GPR52 = 71
    case GPR53 = 72
    case GPR54 = 73
    case GPR55 = 74
    case GPR56 = 75
    case GPR57 = 76
    case GPR58 = 77
    case GPR59 = 78
    case GPR60 = 79
    case GPR61 = 80
    case GPR62 = 81
    case GPR63 = 82
    case GPR64 = 83
    case FPR1 = 100
    case FPR2 = 101
    case FPR3 = 102
    case FPR4 = 103
    case FPR5 = 104
    case FPR6 = 105
    case FPR7 = 106
    case FPR8 = 107
    case FPR9 = 108
    case FPR10 = 109
    case FPR11 = 110
    case FPR12 = 111
    case FPR13 = 112
    case FPR14 = 113
    case FPR15 = 114
    case FPR16 = 115
    case FPR17 = 116
    case FPR18 = 117
    case FPR19 = 118
    case FPR20 = 119
    case FPR21 = 120
    case FPR22 = 121
    case FPR23 = 122
    case FPR24 = 123
    case FPR25 = 124
    case FPR26 = 125
    case FPR27 = 126
    case FPR28 = 127
    case FPR29 = 128
    case FPR30 = 129
    case FPR31 = 130
    case FPR32 = 131
    case FPR33 = 132
    case FPR34 = 133
    case FPR35 = 134
    case FPR36 = 135
    case FPR37 = 136
    case FPR38 = 137
    case FPR39 = 138
    case FPR40 = 139
    case FPR41 = 140
    case FPR42 = 141
    case FPR43 = 142
    case FPR44 = 143
    case FPR45 = 144
    case FPR46 = 145
    case FPR47 = 146
    case FPR48 = 147
    case FPR49 = 148
    case FPR50 = 149
    case FPR51 = 150
    case FPR52 = 151
    case FPR53 = 152
    case FPR54 = 153
    case FPR55 = 154
    case FPR56 = 155
    case FPR57 = 156
    case FPR58 = 157
    case FPR59 = 158
    case FPR60 = 159
    case FPR61 = 160
    case FPR62 = 161
    case FPR63 = 162
    case FPR64 = 163
    case SR1 = 164
    case SR2 = 165
    case SR3 = 166
    case SR4 = 167
    case SR5 = 168
    case SR6 = 169
    case SR7 = 170
    case SR8 = 171
    case SR9 = 172
    case SR10 = 173
    case SR11 = 174
    case SR12 = 175
    case SR13 = 176
    case SR14 = 177
    case SR15 = 178
    case SR16 = 179
    case SR17 = 180
    case SR18 = 181
    case SR19 = 182
    case SR20 = 183
    
    public static var maximumRawValue: Int
        {
        Self.FPR64.rawValue
        }
        
    public init?(rawValue: Word)
        {
        if let value = Self(rawValue: Int(rawValue))
            {
            self = value
            return
            }
        return(nil)
        }
    }
    
public class Register: Equatable
    {
    public static func ==(lhs:Register,rhs:Register) -> Bool
        {
        lhs.index == rhs.index
        }
        
    public enum Contents
        {
        case slot(Slot)
        case expression(Expression)
        case none
        }

    public var rawValue: Word
        {
        Word(self.index.rawValue)
        }
        
    public var isIntegerRegister: Bool
        {
        return(self.index >= RegisterIndex.GPR1 || self.index <= RegisterIndex.GPR64)
        }
        
    public var isFloatingPointRegister: Bool
        {
        return(self.index >= RegisterIndex.FPR1 || self.index <= RegisterIndex.FPR64)
        }
        
    public var isStringRegister: Bool
        {
        return(self.index >= RegisterIndex.SR1 || self.index <= RegisterIndex.SR20)
        }
        
    public var registerFile: RegisterFile?
    public let index: RegisterIndex
    public var word: Word = 0
    public var contents: Contents = .none
    public var isLocked = false
    
    public init(index: RegisterIndex,word: Word)
        {
        self.index = index
        self.word = word
        }
        
    public func deallocate()
        {
        self.registerFile?.deallocateRegister(self)
        }
    }

    
