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
    var currentNode: GameNode
    var leafQueue: Queue<GameNode>
    var eval: Evaluate
    var bestMove: GameNode?
    var side: GamePiece.Side
    
    
    init(game: Game, side: GamePiece.Side) {
        root = GameNode(game: game.copy())
        currentNode = root
        leafQueue = Queue<GameNode>()
        leafQueue.enqueue(currentNode)
        eval = Evaluate()
        bestMove = nil
        self.side = side
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
                if ancestor! !== currentNode {
                    ancestor = ancestor!.parent
                }
            }
            if ancestor == nil { return }
            
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
            // Throw this node away
        }
    }
    
    func updateCurrentNode(move: GameMove) {
        self.bestMove = nil
        for c in currentNode.children {
            if c.move == move {
                currentNode = c
                return
            }
        }
    }
    
    func getBestMove() -> GameMove {
        if (self.bestMove == nil) {
            print("NO BEST MOVE")
            if self.currentNode.children.count == 0 {
               print("Caught up with tree generation")
            }
            self.bestMove = self.currentNode.children[0]
        }
        currentNode = self.bestMove!
        return self.currentNode.move!
    }
    
    func alphaBetaSearch(node: GameNode, depth: Int, var alpha: Int, beta: Int) -> Int {
        if node.children.count == 0 || depth == 0 {
            if node.overallScore == nil {
                eval.evaluateNode(node)
            }
            print("leaf score: " + String(node.overallScore!))
            return node.overallScore!
        }
        var score: Int = self.side == GamePiece.Side.WHITE ? -999999 : 999999
        for child in node.children {
            let current = alphaBetaSearch(child, depth: depth-1, alpha: alpha, beta: beta)
            
            if self.side == GamePiece.Side.WHITE {
                // MAXImize value
                if current > score {
                    score = current
                }
                if score > alpha {
                    alpha = score
                    if node === currentNode {
                        bestMove = child
                    }
                }
                if alpha >= beta {
                    print("a: " + String(alpha) + ", b: " + String(beta))
                    return beta
                }
            } else {
                // MINImize value
                if current < score {
                    score = current
                }
                if score < alpha {
                    alpha = score
                    if node === currentNode {
                        bestMove = child
                    }
                }
                if alpha <= beta {
                    print("a: " + String(alpha) + ", b: " + String(beta))
                    return beta
                }
                
            }
        }
        print(String(depth) + ", Turn: " + String(node.game.turn) + ", value: " + String(score))
        
        return score
        
    }
//    func search() -> GameMove {
//         var bestMove: GameNode? = nil
//         var bestScore: Int = -1
//         for c in currentNode.children {
//             var bestOpponentMove: GameNode? = nil
//             var bestOpponentScore: Int = -1
//             for cc in c.children {
//                 if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.BLACK && cc.overallScore > bestOpponentMove!.overallScore) {
//                     bestOpponentMove = cc
//                     bestOpponentScore = bestOpponentMove!.overallScore!
//                 } else if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.WHITE && cc.overallScore < bestOpponentMove!.overallScore) {
//                     bestOpponentMove = cc
//                     bestOpponentScore = bestOpponentMove!.overallScore!
//                 }
//             }
//
//             if bestMove == nil || (c.game.turn == GamePiece.Side.BLACK && c.overallScore! + bestOpponentScore > bestScore) {
//                 bestMove = c
//                 bestScore = bestMove!.overallScore! + bestOpponentScore
//             } else if bestMove == nil || (c.game.turn == GamePiece.Side.WHITE && c.overallScore! + bestOpponentScore < bestScore) {
//                 bestMove = c
//                 bestScore = bestMove!.overallScore! + bestOpponentScore
//             }
//         }
//         currentNode = bestMove!
//         return bestMove!.move!
//     }
    
    
    
}