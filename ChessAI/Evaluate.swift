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
    
    init() {
        let game = Game()
        root = GameNode(game: game)
    }
    
    func step(node: GameNode){
        let options = GameOptions()
        options.legal = false
        
        let moves = node.game.generateMoves(options)
        var child: Game
        for m in moves {
            child = node.game.copy()
            child.makeMove(m)
            if !child.kingAttacked(child.turn) {
                node.add(child)
            }
        }
    }
    
}