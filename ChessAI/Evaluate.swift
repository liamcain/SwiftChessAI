//
//  Evaluate.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class GameNode {
    
    var game: Game
    var children: [GameNode]
    
    var material: Int?
    var kingSafety: Int?
    var centerControl: Int?
    
    init(game: Game) {
        self.game = game
        children = [GameNode]()
    }
    
    func add(game: Game) {
        children.append(GameNode(game: game))
    }
}


class Evaluate {
    
    var root: GameNode
    
    init(game: Game) {
        root = GameNode(game: game)
    }
    
    func start() {
        step(root)
    }
    
    func step(node: GameNode){
       
        let options = GameOptions()
        options.legal = false
        
        let moves = node.game.generateMoves(options)
        var child: Game
        for m in moves {
            child = node.game.copy()
            child.makeMove(m)
            print("Move number: \(child.move_number)")
            if !child.kingAttacked(child.turn) {
                node.add(child)
            }
        }
        
//        print("Size: \(node.children.count)")
        
        // Recurse forever
        for c in node.children {
//            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//            dispatch_async(dispatch_get_global_queue(priority, 0)) {
//                dispatch_async(dispatch_get_main_queue()) {
                    self.step(c)
//                }
//            }
        }
//        print("o")
    }
}