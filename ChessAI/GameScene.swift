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
    
    override func mouseUp(theEvent: NSEvent) {
        if activePiece != nil {
            
            let legalMoves = game.generate_moves(GameOptions())
            let space = board.closestSpace(activePiece!)
            print(space)
            let move = game.build_move(activePiece!.boardSpace!, toPosition:space, promotionPiece: nil)
            
            if legalMoves.contains(move) {
                board.snapToSpace(activePiece!)
            }
            
            activePiece?.zPosition = ZPOSITION_INACTIVE_PIECE
            activePiece = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
