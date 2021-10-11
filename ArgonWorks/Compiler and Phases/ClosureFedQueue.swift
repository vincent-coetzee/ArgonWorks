//
//  ClosureFedQueue.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 11/10/21.
//

//import Foundation
//
//public class ClosureFedQueue<Element>where Element:Equatable
//    {
//    private var slack: Array<Element> = []
//    private let closure: () -> Element
//    
//    init(_ closure: @escaping () -> Element)
//        {
//        self.closure = closure
//        }
//        
//    public func nextElement() -> Element
//        {
//        if self.slack.isEmpty
//            {
//            return(self.closure())
//            }
//        let element = self.slack.first!
//        self.slack.removeAll(where: {$0 == element})
//        return(element)
//        }
//        
//    public func peekElement(count: Int) -> Element
//        {
//        var last:Element!
//        for _ in 0..<count
//            {
//            let element = self.closure()
//            self.slack.append(element)
//            last = element
//            }
//        return(last)
//        }
//    }
