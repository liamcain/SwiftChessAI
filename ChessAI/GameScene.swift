//
//  GameScene.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright (c) 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var board: Board = Board()
    var game: Game = Game()
    
    var activePiece: Piece?
    
    override func didMoveToView(view: SKView) {
        self.addChild(board)
        game.reset()
    }

    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let touchedPiece = nodeAtPoint(location)
        
        for piece in nodesAtPoint(location){
            if piece.isKindOfClass(Piece) {
                activePiece = touchedPiece as? Piece
                activePiece?.zPosition = ZPOSITION_ACTIVE_PIECE
                break
            }
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        activePiece?.position = location
    }
    
    func undo() {
        game.undo_move()
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if activePiece != nil {
            
            let legalMoves = game.generate_moves(GameOptions())
            let nextSpace = board.closestSpace(activePiece!)
            let currentSpace = activePiece!.boardSpace
            
            if nextSpace.0 == currentSpace.0 && nextSpace.1 == currentSpace.1 {
                board.snapback(activePiece!)
                return
            }
            
            let move = game.build_move(currentSpace, toPosition:nextSpace, promotionPiece: nil)
            
            if legalMoves.contains(move) {
                board.snapToSpace(activePiece!)
                game.make_move(move)
            } else {
                board.snapback(activePiece!)
            }
        
            activePiece?.zPosition = ZPOSITION_INACTIVE_PIECE
            activePiece = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
