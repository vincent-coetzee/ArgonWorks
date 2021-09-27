//
//  RegistersViewController.swift
//  RegistersViewController
//
//  Created by Vincent Coetzee on 21/8/21.
//

import Cocoa

class RegistersViewController: NSViewController
    {
    @IBOutlet var MIRegister: NSTextField!
    @IBOutlet var SSRegister: NSTextField!
    @IBOutlet var STSRegister: NSTextField!
    @IBOutlet var MSRegister: NSTextField!
    @IBOutlet var DSRegister: NSTextField!
    @IBOutlet var CPRegister: NSTextField!
    @IBOutlet var IPRegister: NSTextField!
    @IBOutlet var IIRegister: NSTextField!
    @IBOutlet var SPRegister: NSTextField!
    @IBOutlet var BPRegister: NSTextField!
    @IBOutlet var FPRegister: NSTextField!
    @IBOutlet var MPRegister: NSTextField!
    @IBOutlet var EPRegister: NSTextField!
    @IBOutlet var RETRegister: NSTextField!
    @IBOutlet var R0Register: NSTextField!
    @IBOutlet var R1Register: NSTextField!
    @IBOutlet var R2Register: NSTextField!
    @IBOutlet var R3Register: NSTextField!
    @IBOutlet var R4Register: NSTextField!
    @IBOutlet var R5Register: NSTextField!
    @IBOutlet var R6Register: NSTextField!
    @IBOutlet var R7Register: NSTextField!
    @IBOutlet var R8Register: NSTextField!
    @IBOutlet var R9Register: NSTextField!
    @IBOutlet var R10Register: NSTextField!
    @IBOutlet var R11Register: NSTextField!
    @IBOutlet var R12Register: NSTextField!
    @IBOutlet var R13Register: NSTextField!
    @IBOutlet var R14Register: NSTextField!
    @IBOutlet var R15Register: NSTextField!
    @IBOutlet var FR0Register: NSTextField!
    @IBOutlet var FR1Register: NSTextField!
    @IBOutlet var FR2Register: NSTextField!
    @IBOutlet var FR3Register: NSTextField!
    @IBOutlet var FR4Register: NSTextField!
    @IBOutlet var FR5Register: NSTextField!
    @IBOutlet var FR6Register: NSTextField!
    @IBOutlet var FR7Register: NSTextField!
    @IBOutlet var FR8Register: NSTextField!
    @IBOutlet var FR9Register: NSTextField!
    @IBOutlet var FR10Register: NSTextField!
    @IBOutlet var FR11Register: NSTextField!
    @IBOutlet var FR12Register: NSTextField!
    @IBOutlet var FR13Register: NSTextField!
    @IBOutlet var FR14Register: NSTextField!
    @IBOutlet var FR15Register: NSTextField!
    
    @IBOutlet var MIValue: NSTextField!
    @IBOutlet var SSValue: NSTextField!
    @IBOutlet var STSValue: NSTextField!
    @IBOutlet var MSValue: NSTextField!
    @IBOutlet var DSValue: NSTextField!
    @IBOutlet var CPValue: NSTextField!
    @IBOutlet var IPValue: NSTextField!
    @IBOutlet var IIValue: NSTextField!
    @IBOutlet var SPValue: NSTextField!
    @IBOutlet var BPValue: NSTextField!
    @IBOutlet var FPValue: NSTextField!
    @IBOutlet var MPValue: NSTextField!
    @IBOutlet var EPValue: NSTextField!
    @IBOutlet var RETValue: NSTextField!
    @IBOutlet var R0Value: NSTextField!
    @IBOutlet var R1Value: NSTextField!
    @IBOutlet var R2Value: NSTextField!
    @IBOutlet var R3Value: NSTextField!
    @IBOutlet var R4Value: NSTextField!
    @IBOutlet var R5Value: NSTextField!
    @IBOutlet var R6Value: NSTextField!
    @IBOutlet var R7Value: NSTextField!
    @IBOutlet var R8Value: NSTextField!
    @IBOutlet var R9Value: NSTextField!
    @IBOutlet var R10Value: NSTextField!
    @IBOutlet var R11Value: NSTextField!
    @IBOutlet var R12Value: NSTextField!
    @IBOutlet var R13Value: NSTextField!
    @IBOutlet var R14Value: NSTextField!
    @IBOutlet var R15Value: NSTextField!
    @IBOutlet var FR0Value: NSTextField!
    @IBOutlet var FR1Value: NSTextField!
    @IBOutlet var FR2Value: NSTextField!
    @IBOutlet var FR3Value: NSTextField!
    @IBOutlet var FR4Value: NSTextField!
    @IBOutlet var FR5Value: NSTextField!
    @IBOutlet var FR6Value: NSTextField!
    @IBOutlet var FR7Value: NSTextField!
    @IBOutlet var FR8Value: NSTextField!
    @IBOutlet var FR9Value: NSTextField!
    @IBOutlet var FR10Value: NSTextField!
    @IBOutlet var FR11Value: NSTextField!
    @IBOutlet var FR12Value: NSTextField!
    @IBOutlet var FR13Value: NSTextField!
    @IBOutlet var FR14Value: NSTextField!
    @IBOutlet var FR15Value: NSTextField!
    
    private var registerFields = Array<NSTextField>(repeating: NSTextField(), count: Instruction.Register.allCases.count)
    private var registerValueFields = Array<NSTextField>(repeating: NSTextField(), count: Instruction.Register.allCases.count)
    private var lastValues = Array<Word>(repeating: 0,count: Instruction.Register.allCases.count)
    private var virtualMachine: VirtualMachine?
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initRegisterFields()
        self.initRegisterValueFields()
        }
        
    override func viewDidAppear()
        {
        let windowController = self.view.window?.windowController as? ProcessorWindowController
        windowController!.registersViewController = self
        self.virtualMachine = windowController!.virtualMachine
        self.harvest()
        }
    private func harvest()
        {
        for register in Instruction.Register.allCases
            {
            let registerValue = self.virtualMachine!.registers[register.rawValue]
            let lastValue = self.lastValues[register.rawValue]
            self.registerValueFields[register.rawValue].stringValue = "\(registerValue)"
            self.registerFields[register.rawValue].stringValue = registerValue.bitString
            let color = lastValue != registerValue ? NSColor.argonNeonPink : NSColor.systemGray
            self.registerFields[register.rawValue].textColor = color
            self.registerValueFields[register.rawValue].textColor = color
            }
        }
        
    private func initRegisterFields()
        {
        registerFields[Instruction.Register.MI.rawValue] = self.MIRegister
        registerFields[Instruction.Register.SS.rawValue] = self.SSRegister
        registerFields[Instruction.Register.STS.rawValue] = self.STSRegister
        registerFields[Instruction.Register.MS.rawValue] = self.MSRegister
        registerFields[Instruction.Register.DS.rawValue] = self.DSRegister
        registerFields[Instruction.Register.CP.rawValue] = self.CPRegister
        registerFields[Instruction.Register.IP.rawValue] = self.IPRegister
        registerFields[Instruction.Register.II.rawValue] = self.IIRegister
        registerFields[Instruction.Register.SP.rawValue] = self.SPRegister
        registerFields[Instruction.Register.BP.rawValue] = self.BPRegister
        registerFields[Instruction.Register.FP.rawValue] = self.FPRegister
        registerFields[Instruction.Register.MP.rawValue] = self.MPRegister
        registerFields[Instruction.Register.EP.rawValue] = self.EPRegister
        registerFields[Instruction.Register.RET.rawValue] = self.RETRegister
        registerFields[Instruction.Register.R0.rawValue] = self.R0Register
        registerFields[Instruction.Register.R1.rawValue] = self.R1Register
        registerFields[Instruction.Register.R2.rawValue] = self.R2Register
        registerFields[Instruction.Register.R3.rawValue] = self.R3Register
        registerFields[Instruction.Register.R4.rawValue] = self.R4Register
        registerFields[Instruction.Register.R5.rawValue] = self.R5Register
        registerFields[Instruction.Register.R6.rawValue] = self.R6Register
        registerFields[Instruction.Register.R7.rawValue] = self.R7Register
        registerFields[Instruction.Register.R8.rawValue] = self.R8Register
        registerFields[Instruction.Register.R9.rawValue] = self.R9Register
        registerFields[Instruction.Register.R10.rawValue] = self.R10Register
        registerFields[Instruction.Register.R11.rawValue] = self.R11Register
        registerFields[Instruction.Register.R12.rawValue] = self.R12Register
        registerFields[Instruction.Register.R13.rawValue] = self.R13Register
        registerFields[Instruction.Register.R14.rawValue] = self.R14Register
        registerFields[Instruction.Register.R15.rawValue] = self.R15Register
        registerFields[Instruction.Register.FR0.rawValue] = self.FR0Register
        registerFields[Instruction.Register.FR1.rawValue] = self.FR1Register
        registerFields[Instruction.Register.FR2.rawValue] = self.FR2Register
        registerFields[Instruction.Register.FR3.rawValue] = self.FR3Register
        registerFields[Instruction.Register.FR4.rawValue] = self.FR4Register
        registerFields[Instruction.Register.FR5.rawValue] = self.FR5Register
        registerFields[Instruction.Register.FR6.rawValue] = self.FR6Register
        registerFields[Instruction.Register.FR7.rawValue] = self.FR7Register
        registerFields[Instruction.Register.FR8.rawValue] = self.FR8Register
        registerFields[Instruction.Register.FR9.rawValue] = self.FR9Register
        registerFields[Instruction.Register.FR10.rawValue] = self.FR10Register
        registerFields[Instruction.Register.FR11.rawValue] = self.FR11Register
        registerFields[Instruction.Register.FR12.rawValue] = self.FR12Register
        registerFields[Instruction.Register.FR13.rawValue] = self.FR13Register
        registerFields[Instruction.Register.FR14.rawValue] = self.FR14Register
        registerFields[Instruction.Register.FR15.rawValue] = self.FR15Register
        }
        
    private func initRegisterValueFields()
        {
        registerValueFields[Instruction.Register.MI.rawValue] = self.MIValue
        registerValueFields[Instruction.Register.SS.rawValue] = self.SSValue
        registerValueFields[Instruction.Register.STS.rawValue] = self.STSValue
        registerValueFields[Instruction.Register.MS.rawValue] = self.MSValue
        registerValueFields[Instruction.Register.DS.rawValue] = self.DSValue
        registerValueFields[Instruction.Register.CP.rawValue] = self.CPValue
        registerValueFields[Instruction.Register.IP.rawValue] = self.IPValue
        registerValueFields[Instruction.Register.II.rawValue] = self.IIValue
        registerValueFields[Instruction.Register.SP.rawValue] = self.SPValue
        registerValueFields[Instruction.Register.BP.rawValue] = self.BPValue
        registerValueFields[Instruction.Register.FP.rawValue] = self.FPValue
        registerValueFields[Instruction.Register.MP.rawValue] = self.MPValue
        registerValueFields[Instruction.Register.EP.rawValue] = self.EPValue
        registerValueFields[Instruction.Register.RET.rawValue] = self.RETValue
        registerValueFields[Instruction.Register.R0.rawValue] = self.R0Value
        registerValueFields[Instruction.Register.R1.rawValue] = self.R1Value
        registerValueFields[Instruction.Register.R2.rawValue] = self.R2Value
        registerValueFields[Instruction.Register.R3.rawValue] = self.R3Value
        registerValueFields[Instruction.Register.R4.rawValue] = self.R4Value
        registerValueFields[Instruction.Register.R5.rawValue] = self.R5Value
        registerValueFields[Instruction.Register.R6.rawValue] = self.R6Value
        registerValueFields[Instruction.Register.R7.rawValue] = self.R7Value
        registerValueFields[Instruction.Register.R8.rawValue] = self.R8Value
        registerValueFields[Instruction.Register.R9.rawValue] = self.R9Value
        registerValueFields[Instruction.Register.R10.rawValue] = self.R10Value
        registerValueFields[Instruction.Register.R11.rawValue] = self.R11Value
        registerValueFields[Instruction.Register.R12.rawValue] = self.R12Value
        registerValueFields[Instruction.Register.R13.rawValue] = self.R13Value
        registerValueFields[Instruction.Register.R14.rawValue] = self.R14Value
        registerValueFields[Instruction.Register.R15.rawValue] = self.R15Value
        registerValueFields[Instruction.Register.FR0.rawValue] = self.FR0Value
        registerValueFields[Instruction.Register.FR1.rawValue] = self.FR1Value
        registerValueFields[Instruction.Register.FR2.rawValue] = self.FR2Value
        registerValueFields[Instruction.Register.FR3.rawValue] = self.FR3Value
        registerValueFields[Instruction.Register.FR4.rawValue] = self.FR4Value
        registerValueFields[Instruction.Register.FR5.rawValue] = self.FR5Value
        registerValueFields[Instruction.Register.FR6.rawValue] = self.FR6Value
        registerValueFields[Instruction.Register.FR7.rawValue] = self.FR7Value
        registerValueFields[Instruction.Register.FR8.rawValue] = self.FR8Value
        registerValueFields[Instruction.Register.FR9.rawValue] = self.FR9Value
        registerValueFields[Instruction.Register.FR10.rawValue] = self.FR10Value
        registerValueFields[Instruction.Register.FR11.rawValue] = self.FR11Value
        registerValueFields[Instruction.Register.FR12.rawValue] = self.FR12Value
        registerValueFields[Instruction.Register.FR13.rawValue] = self.FR13Value
        registerValueFields[Instruction.Register.FR14.rawValue] = self.FR14Value
        registerValueFields[Instruction.Register.FR15.rawValue] = self.FR15Value
        }
    }
