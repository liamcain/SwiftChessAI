//
//  AI.swift
//  ChessAI
//
//  Created by Liam Cain on 12/6/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class AI: Player {
    
    let brain: Bencarle
    
    override init(side: Side, board: Board, game: Game) {
        brain = Bencarle(boardState: game, side: side)
        super.init(side: side, board: board, game: game)
    }
    
    override func update() {
        if let move = brain.nextMove {
            makeMove(move)
            brain.nextMove = nil
        } else {
            print("No next move")
        }
    }
    
    override func handleMove(move: GameMove?) {
        brain.handleMove(move)
        super.handleMove(move)
    }
    
    override func makeMove(move: GameMove) {
        game.makeMove(move)
        board.makeMove(move)
        super.makeMove(move)
    }
}