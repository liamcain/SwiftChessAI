//
//  SingleThreadedSearch.swift
//  ChessAI
//
//  Created by Zack Meath on 12/10/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class SingleThreadedSearch {
    
    var eval: Evaluate
    var game: Game
    var bestMove: GameMove?
    var side: GamePiece.Side
    var maxDepth: Int
    
    init(game: Game, side: GamePiece.Side){
        eval = Evaluate()
        bestMove = nil
        self.side = side
        self.game = game
        self.maxDepth = 5
    }
    
    func getBestMove() -> GameMove {
        return self.bestMove!
    }
    
    func alphaBetaSearch(game: Game, depth: Int, var alpha: Int, var beta: Int) -> Int {
        if depth == 0 { // || game.isGameOver() {
            return eval.evaluateGame(game)
        }
        let minimize = game.turn == GamePiece.Side.BLACK
        var value: Int = minimize ? 999999 : -999999
        let options = GameOptions()
        options.legal = false // false // for efficiency
        
        for move in game.generateMoves(options) {
            game.makeMove(move)
            if game.kingAttacked(game.turn == GamePiece.Side.WHITE ? GamePiece.Side.BLACK : GamePiece.Side.WHITE) {
                game.undoMove()
                continue
            }
            let current = alphaBetaSearch(game, depth: depth-1, alpha: alpha, beta: beta)
            game.undoMove()
            if minimize {
                // MINimize
                if current < value {
                    value = current
                }
                if value < beta {
                    beta = value
                    if depth == maxDepth {
                        bestMove = move
                    }
                }
                if value <= alpha {
                    // Trim the tree
                    return value
                }
            } else {
                // MAXimize
                if current > value {
                    value = current
                }
                if value > alpha {
                    alpha = value
                    if depth == maxDepth {
                        bestMove = move
                    }
                }
                if value >= beta {
                    // Trim the tree
                    return value
                }
            }
        }
        // print(String(depth) + ", Turn: " + String(game.turn) + ", value: " + String(value))
        
        return value
        
    }
    
    func updateCurrentNode(move: GameMove){
        // self.game.makeMove(move)
        self.bestMove = nil
        // Only exists so I don't have to change Bencarle.swift
    }
    func start(){
        // Only exists so I don't have to change Bencarle.swift
    }
}