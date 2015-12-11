//
//  GameScene.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright (c) 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

func == (left:(Int, Int), right: (Int, Int)) -> Bool {
    return left.0 == right.0 && left.1 == right.1
}

protocol ChessGameDelegate {
    func gameDidCheckmate()
    func gameDidStatemate()
}

class GameScene: SKScene, ChessGameDelegate {
    
    var board: Board = Board()
    var game: Game = Game()
    var players: [Side: Player]?
    
    override func didMoveToView(view: SKView) {
        self.addChild(board)
        
        game.reset()
        let human = Human(side: .WHITE, board: board, game: game)
//        let ai    =    AI(side: .BLACK, board: board, game: game)
        let ai    =    Human(side: .BLACK, board: board, game: game)
        players   = [.WHITE: human, .BLACK: ai]
        
        human.opponent = ai
        ai.opponent = human
        reset()
    }
    
    func undo() {
        game.undoMove()
        loadFEN(game.generateFen())
    }
    
    func reset(){
        board.reset()
        game.reset()
        players![.WHITE]?.isTurn = true
        players![.WHITE]?.handleMove(nil)
        
    }
    
    func loadFEN(fen: String) {
        game.loadFromFen(fen)
        board.clearBoard()
        board.updateFromFEN(game.generateFen())
        if game.turn == .BLACK {
            players![.BLACK]?.handleMove(nil)
            players![.WHITE]?.isTurn = false
        } else {
            players![.WHITE]?.handleMove(nil)
            players![.BLACK]?.isTurn = false
        }
    }
    
    func currentPlayer() -> Player {
        return players![game.turn]!
    }

    override func mouseDown(theEvent: NSEvent) {
        assert(players != nil)
        
        let location = theEvent.locationInNode(self)
        for piece in nodesAtPoint(location){
            if piece.isKindOfClass(Piece) {
                currentPlayer().mouseDown(piece as! Piece)
                return
            }
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        currentPlayer().mouseDragged(theEvent.locationInNode(self))
    }
    
    override func mouseUp(theEvent: NSEvent) {
        currentPlayer().mouseUp()
    }
    
    override func update(currentTime: CFTimeInterval) {
        currentPlayer().update()
    }
    
    func gameDidCheckmate() { }
    
    func gameDidStatemate() { }
}
