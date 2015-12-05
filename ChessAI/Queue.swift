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
    var head: Node<T> = Node<T>()
    var tail: Node<T> = Node<T>()
    
    init() {
    }
    
    func isEmpty() -> Bool {
        return self.count == 0
    }
    
    func enqueue(value: T) {
        let node = Node<T>(value: value)
        if self.isEmpty() {
            self.head = node
            self.tail = node
        } else {
            node.next = self.head
            self.head = node
        }
        self.count++
    }
    
    func dequeue() -> T? {
        if self.isEmpty() {
            return nil
        } else if self.count == 1 {
            let temp: Node<T> = self.tail
            self.count--
            return temp.value
        } else {
            let temp: Node<T> = self.tail
            
            // ??????
            
            self.count--
            return temp.value
        }
    }
}
