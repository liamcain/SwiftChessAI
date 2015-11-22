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
    var legalMoves: [GameMove]?
    
    override func didMoveToView(view: SKView) {
        self.addChild(board)
        game.reset()
        legalMoves = game.generate_moves(GameOptions())
    }

    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let touchedPiece = nodeAtPoint(location)
        
        for piece in nodesAtPoint(location){
            if piece.isKindOfClass(Piece) {
                activePiece = touchedPiece as? Piece
                activePiece?.zPosition = ZPOSITION_ACTIVE_PIECE
                
                let space = activePiece?.boardSpace
                for move in legalMoves! {
//                    if move.fromIndex == activePiece?.boardSpace {
                        // highlight boardspace
//                    }
                }
                
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
            
            let nextSpace = board.closestSpace(activePiece!)
            let currentSpace = activePiece!.boardSpace
            
            // If we haven't moved the piece
            if nextSpace.0 == currentSpace.0 && nextSpace.1 == currentSpace.1 {
                board.snapback(activePiece!)
                return
            }
            
            let move = game.build_move(currentSpace, toPosition:nextSpace, promotionPiece: nil)
            
            if legalMoves!.contains(move) {
                board.movePieceToSpace(activePiece!, space: nextSpace)
                game.make_move(move)
                game.print_board()
                
                if (game.king_attacked(game.turn)) {
                    print("King is in check")
                }
                legalMoves = game.generate_moves(GameOptions())
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
