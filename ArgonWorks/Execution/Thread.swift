//
//  Thread.swift
//  Thread
//
//  Created by Vincent Coetzee on 27/7/21.
//

import Foundation
import Interpreter

public struct Thread
    {
    private static var threadKey: pthread_key_t = pthread_key_t()
    private static var contextKey: pthread_key_t = pthread_key_t()
    private static var threads = Array<Thread>()
    
    public static func initThreads()
        {
        self.threadKey = pthread_key_t()
        pthread_key_create(&threadKey,nil)
        self.contextKey = pthread_key_t()
        pthread_key_create(&contextKey,nil)
        }
        
    public static var current:Thread
        {
        let address = pthread_getspecific(self.threadKey)
        if address == nil
            {
            let newThread = Thread()
            threads.append(newThread)
            pthread_setspecific(self.threadKey,unsafeBitCast(newThread,to: UnsafeRawPointer.self))
            return(newThread)
            }
        return(unsafeBitCast(address,to: Thread.self))
        }
        
//    public private(set) var context = ExecutionContext()
    }
