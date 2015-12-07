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

class GameScene: SKScene {
    
    var board: Board = Board()
    var game: Game = Game()
    var players: [GamePiece.Side: Player]?
    
    override func didMoveToView(view: SKView) {
        self.addChild(board)
        
        game.reset()
        let human = Human(side: GamePiece.Side.WHITE, board: board, game: game)
        let ai    =    AI(side: GamePiece.Side.BLACK, board: board, game: game)
        
        human.opponent = ai
        ai.opponent = human
        
        players   = [GamePiece.Side.WHITE: human,
                     GamePiece.Side.BLACK: ai]
        
        reset()
    }
    
    func undo() {
        game.undoMove()
        board.clearBoard()
        board.updateFromFEN(game.generateFen())
    }
    
    func reset(){
        board.reset()
        game.reset()
        players![GamePiece.Side.WHITE]?.isTurn = true
        players![GamePiece.Side.WHITE]?.handleMove(nil)
        
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
}
