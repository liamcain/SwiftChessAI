//
//  board.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Board: SKNode {
   
    var pieces: [Piece] = Array<Piece>()
    
    override init() {
        super.init()
        
        for i in 0...7 {
            for j in 0...7 {
                let space = SKSpriteNode(imageNamed: "board-space")
                space.position = CGPoint(x:100*j+50, y:100*i+50)
                if (i + j) % 2 == 0 {
                    space.colorBlendFactor = 1.0
                    space.color = SKColor.redColor()
                    space.zPosition = ZPOSITION_BOARD_SPACE
                    
                }
                addChild(space);
            }
        }
        reset()
    }
    
    func snapToSpace(piece: Piece) {
        let x = piece.position.x
        let y = piece.position.y
        
        let roundedX = SPACE_WIDTH * ceil(x / SPACE_WIDTH) - SPACE_WIDTH/2
        let roundedY = SPACE_WIDTH * ceil(y / SPACE_WIDTH) - SPACE_WIDTH/2
        piece.position = CGPoint(x: roundedX, y: roundedY)
    }
    
    func reset() {
        // Delete all pieces
        for piece in pieces {
            piece.removeFromParent()
        }
        
        // White Pawns
        for i in 0...7 {
            let p = Pawn(side: Piece.Side.WHITE)
            p.position = positionOnBoard(i, y: 1)
            p.zPosition = ZPOSITION_INACTIVE_PIECE
            addChild(p)
        }
        
        // Black Pawns
        for i in 0...7 {
            let p = Pawn(side: Piece.Side.BLACK)
            p.position = positionOnBoard(i, y: 6)
            p.zPosition = ZPOSITION_INACTIVE_PIECE
            addChild(p)
        }
        
        
    }
    
    func positionOnBoard(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: x * 100 + 50, y: y * 100 + 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
