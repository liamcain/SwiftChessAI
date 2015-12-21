//
//  Player.swift
//  ChessAI
//
//  Created by Liam Cain on 12/6/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Player {
    
    var isTurn: Bool
    var side: Side
    
    var board: Board
    var game: Game
    var opponent: Player?
    
    init(side: Side, board: Board, game: Game) {
        self.board = board
        self.game = game
        
        self.side = side
        isTurn = false
    }
    
    func lost() -> Bool {
        return isTurn && game.copy().inCheckmate()
    }
    
    func stalemate() -> Bool {
        return isTurn && game.copy().inStatemate()
    }
    
    func inCheck() -> Bool {
//        return false
        return isTurn && game.copy().inCheck(game.turn)
    }
    
    func makeMove(move: GameMove) {
        opponent?.handleMove(move)
        isTurn = false
    }
    
    func handleMove(move: GameMove?) {
        isTurn = true
        
//        if lost() {
//            board.inCheckmate()
//        } else if stalemate() {
//            board.inStalemate()
//        } else {
//            board.inCheck(inCheck())
//        }
    }
    
    func update() { }
    
    func mouseUp() { }
    func mouseDown(piece: Piece) { }
    func mouseDragged(position: CGPoint) { }
}