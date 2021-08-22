//
//  ClassEditingView.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import SwiftUI
//
//struct ClassEditingView: View
//    {
//    @State var label:String
//    @State var superclasses:Array<UUID> = []
//    @State var newSlotName:String = ""
//    @State var source: String = Argon.sampleSource
//    @State var theClass:Class
//    
//    init(someClass:Class)
//        {
//        self.theClass = someClass
//        self.label = someClass.label
//        }
//        
//    var body: some View
//        {
//        HStack
//            {
//            VStack
//                {
//                HStack
//                    {
//                    Spacer()
//                    Button("Compile", action: {})
//                    Button("Run",action: {})
//                    }
//                TokenMappingView(source: self.$source)
//                }
//            ClassDeclarationEditor(editedClass: self.theClass)
//            }
//        }
//        
//    private func onCancel()
//        {
//        }
//        
//    private func onOK()
//        {
//        }
//        
//    private func deleteSlot(_ slot:Slot)
//        {
//        }
//        
//    private func addSlot(_ binding:Binding<String>)
//        {
//        }
//    }
//
//struct ClassEditingView_Previews: PreviewProvider
//    {
//    static let aClass = Class(label:"SomeClass")
//    
//    static var previews: some View
//        {
//        ClassEditingView(someClass: aClass)
//        }
//    }
//
//struct ClassDeclarationEditor: View
//    {
//    @State private var editedClass: Class
//    
//    init(editedClass: Class)
//        {
//        self.editedClass = editedClass
//        }
//        
//    var body: some View
//        {
//        VStack
//            {
//            Text(self.editedClass.label)
//            .font(.system(size: 20, weight: .bold, design: .default)).foregroundColor(NSColor.argonXGreen.swiftUIColor)
//            Divider()
//            Text("\(self.editedClass.localSlots.count) slots defined here.")
//            Text("\(self.editedClass.localAndInheritedSlots.count) slots in total.")
//            Divider()
//            ForEach(self.superclassSlots(forClass: self.editedClass))
//                {
//                slot in
//                Text("\(slot.label) :: \(slot.type.label)")
//                }
//            Divider()
//            ForEach(self.editedClass.localSlots)
//                {
//                slot in
//                HStack
//                    {
//                    Text("\(slot.label) :: \(slot.type.label)")
//                    Spacer()
//                    Button(action:editSlot)
//                        {
//                        Image(systemName: "pencil.circle")
//                        }
//                    Button(action: deleteSlot)
//                        {
//                        Image(systemName: "delete.left")
//                        }
//                    Button(action: addSlot)
//                        {
//                        Image(systemName: "plus.app")
//                        }
//                    }
//                }
//            Spacer()
//            }
//            .frame(minWidth: 300)
//        }
//        
//    private func editSlot()
//        {
//        }
//        
//    private func deleteSlot()
//        {
//        }
//        
//    private func addSlot()
//        {
//        }
//        
//    private func superclassSlots(forClass aClass:Class) -> Array<Slot>
//        {
//        var slots = Array<Slot>()
//        for superclass in aClass.superclasses
//            {
//            slots.append(contentsOf: superclass.localAndInheritedSlots)
//            }
//        return(slots.sorted{$0.label < $1.label})
//        }
//    }
