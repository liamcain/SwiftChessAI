//
//  Queue.swift
//  ChessAI
//
//  Created by Liam Cain on 12/5/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class Queue<T> {
    var count: Int = 0
    var head: Node<T>?
    var tail: Node<T>?
    
    init() { }
    
    func enqueue(value: T) {
        let node = Node<T>(value: value)
        if head == nil {
            head = node
            tail = node
        } else {
            node.next = head
            head?.prev = node
            head = node
        }
        count++
    }
    
    func dequeue() -> T? {
        if head == nil {
            return nil
        } else if head === tail {
            let temp = tail?.value
            head = nil
            tail = nil
            count--
            return temp
        } else {
            let temp = tail?.value
            tail = tail?.prev
            tail?.next = nil
            count--
            return temp
        }
    }
}
