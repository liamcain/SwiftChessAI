//
//  node.swift
//  QueueLinkedList
//
//  Created by Jason Kim on 2014-06-06.
//  Copyright (c) 2014 Jason Kim. All rights reserved.
//

import Foundation

class Node<T> {
    var value: T?
    var next: Node<T>?
    var prev: Node<T>?
    
    init(value: T) {
        self.value = value
    }
}