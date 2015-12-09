//
//  Search.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class GameNode {
    
    var game: Game
    var move: GameMove?
    
    weak var parent: GameNode?
    var children: [GameNode]
    
    var material: Int?
    var kingSafety: Int?
    var centerControl: Int?
    var overallScore: Int?
   
    init(game: Game, gameMove: GameMove?=nil) {
        self.game = game
        self.move = gameMove
        children = [GameNode]()
    }
    
    func add(game: Game, move: GameMove) -> GameNode {
        let node = GameNode(game: game, gameMove: move)
        node.parent = self
        children.append(node)
        return node
    }
    
    var description: String {
        return  "(" + String(self.move?.fromIndex) + " -> " + String(self.move?.toIndex) + "): " + String(self.overallScore)
    }
}

class Search {
    
    var root: GameNode
    var leafQueue: Queue<GameNode>
    var eval: Evaluate
    
    init(game: Game) {
        root = GameNode(game: game.copy())
        leafQueue = Queue<GameNode>()
        leafQueue.enqueue(root)
        eval = Evaluate();
    }
    
    func start() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            while true {
                self.evaluateFromQueue()
            }
        }
    }
    
    func evaluateFromQueue(){
        if let node = leafQueue.dequeue() {
            
            // Check if node is a descendant of the current board state.
            var ancestor: GameNode? = node
            while ancestor?.parent != nil {
                ancestor = ancestor?.parent
            }
            if ancestor !== root { return }
            
            let options = GameOptions()
            options.legal = false
            
            let moves = node.game.generateMoves(options)
            for m in moves {
                let child = node.game.copy()
                child.makeMove(m)
                if !child.kingAttacked(child.turn) {
                    let childNode = node.add(child, move: m)
                    eval.evaluateNode(childNode)
                    leafQueue.enqueue(childNode)
                }
            }
        }
    }
    
    func updateRoot(move: GameMove) {
        for c in root.children {
            if c.move == move {
                root = c
                return
            }
        }
    }
    
    func search() -> GameMove {
         var bestMove: GameNode? = nil
         var bestScore: Int = -1
         for c in root.children {
             var bestOpponentMove: GameNode? = nil
             var bestOpponentScore: Int = -1
             for cc in c.children {
                 if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.BLACK && cc.overallScore > bestOpponentMove!.overallScore) {
                     bestOpponentMove = cc
                     bestOpponentScore = bestOpponentMove!.overallScore!
                 } else if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.WHITE && cc.overallScore < bestOpponentMove!.overallScore) {
                     bestOpponentMove = cc
                     bestOpponentScore = bestOpponentMove!.overallScore!
                 }
             }

             if bestMove == nil || (c.game.turn == GamePiece.Side.BLACK && c.overallScore! - bestOpponentScore > bestScore) {
                 bestMove = c
                 bestScore = bestMove!.overallScore! - bestOpponentScore
             } else if bestMove == nil || (c.game.turn == GamePiece.Side.WHITE && c.overallScore! - bestOpponentScore < bestScore) {
                 bestMove = c
                 bestScore = bestMove!.overallScore! - bestOpponentScore
             }
         }
         root = bestMove!
         return bestMove!.move!
     }
    
}