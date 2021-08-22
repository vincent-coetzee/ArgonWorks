//
//  ProcessorView.swift
//  ProcessorView
//
//  Created by Vincent Coetzee on 1/8/21.
//

import SwiftUI
//
//struct ProcessorView: View
//    {
//    @EnvironmentObject private var context:ExecutionContext
//    @State private var color:Color = .white
//    @State private var index:Int = 0
//    @State private var program = InnerPackedInstructionArrayPointer.allocate(numberOfInstructions: 100, in: VirtualMachine.shared.managedSegment)
//    
//    var body: some View
//        {
//        VStack
//            {
//        ForEach(self.context.allRegisters)
//            {
//            register in
//            HStack
//                {
//                Text("\(register)".aligned(.right,in:10) as String).inspectorFont()
//                Text(Word(self.context.register(atIndex: register)).bitString).inspectorFont().foregroundColor(self.context.changedRegisters.contains(register) ? .orange : .white)
//                }
//            }
//        Button(action:
//            {
//            do
//                {
//                try self.context.singleStep()
//                self.index += 1
//                }
//            catch
//                {
//                }
//            })
//            {
//            Text("Next")
//            }
//        ForEach(self.program.instructions)
//            {
//            instruction in
//            HStack
//                {
//                Text(" \(instruction.opcode)".aligned(.right,in:10)).inspectorFont().foregroundColor(instruction.id == self.index ? .orange : .white)
//                Text(instruction.operandText.aligned(.left,in:33)).inspectorFont().foregroundColor(instruction.id == self.index ? .orange : .white)
//                Spacer()
//                }
//            }
//        }
//        .padding(20)
//        .onAppear
//            {
//            self.$program.wrappedValue.append(.load,operand1: .integer(2021),result: .register(.r1))
//            self.$program.wrappedValue.append(.load,operand1: .integer(1965),result: .register(.r2))
//            self.$program.wrappedValue.append(.isub,operand1: .register(.r1),operand2: .register(.r2),result:.register(.r3))
//            self.$program.wrappedValue.append(.load,operand1: .integer(112000),result: .register(.r4))
//            self.$program.wrappedValue.append(.imul,operand1: .register(.r4),operand2: .integer(12),result: .register(.r5))
//            self.$program.wrappedValue.append(.imul,operand1: .register(.r5),operand2: .register(.r3),result: .register(.r6))
//            self.$program.wrappedValue.append(.load,operand1: .integer(200),result: .register(.r15))
//            let marker = self.$program.wrappedValue.append(.zero,result: .register(.r14)).fromHere("marker")
//            self.$program.wrappedValue.append(.inc,result: .register(.r14))
//            self.$program.wrappedValue.append(.dec,result: .register(.r15))
//            self.$program.wrappedValue.append(.breq,operand1: .register(.r15),operand2: .integer(0),result: .label(program.toHere(marker)))
//            self.$program.wrappedValue.rewind()
//            self.context.call(address: self.$program.wrappedValue.address)
//            }
//        }
//        
//    func initProgram()
//        {
//
//        }
//    }
//
//struct ProcessorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProcessorView()
//    }
//}

