//
//  board.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Board: SKNode {
   
    var pieces: [[Piece?]] = [[Piece?]]()
    
    override init() {
        super.init()
        
        for i in 0...7 {
            var row = Array<Piece?>()
            for j in 0...7 {
                row.append(nil)
                let space = SKSpriteNode(imageNamed: "board-space")
                space.position = CGPoint(x:100*j+50, y:100*i+50)
                if (i + j) % 2 == 0 {
                    space.colorBlendFactor = 1.0
                    space.color = SKColor.redColor()
                    space.zPosition = ZPOSITION_BOARD_SPACE
                }
                addChild(space);
            }
            pieces.append(row)
        }
        reset()
    }
    
    func snapToSpace(piece: Piece) {
        let x = min(max(piece.position.x, SPACE_WIDTH/2), SPACE_WIDTH*8)
        let y = min(max(piece.position.y, SPACE_WIDTH/2), SPACE_WIDTH*8)
        
        let roundedX = SPACE_WIDTH * ceil(x / SPACE_WIDTH) - SPACE_WIDTH/2
        let roundedY = SPACE_WIDTH * ceil(y / SPACE_WIDTH) - SPACE_WIDTH/2
        
        let pt = CGPoint(x: roundedX, y: roundedY)
        let space = pointToSpace(pt)
       
        let pieceAtSpace = pieces[space.0][space.1]
        if pieceAtSpace != nil && pieceAtSpace != piece {
            pieceAtSpace?.removeFromParent()
        }
        
        pieces[space.0][space.1] = piece
        piece.position = pt
    }
    
    
    func reset() {
        // Delete all pieces
        for row in pieces {
            for piece in row {
                piece?.removeFromParent()
            }
        }
        
        // White Pawns
        for i in 0...7 {
            let p = Pawn(side: Piece.Side.WHITE)
            p.position = positionOnBoard(i, y: 1)
            p.zPosition = ZPOSITION_INACTIVE_PIECE
            pieces[i][1] = p
            addChild(p)
        }
        
        // Black Pawns
        for i in 0...7 {
            let p = Pawn(side: Piece.Side.BLACK)
            p.position = positionOnBoard(i, y: 6)
            p.zPosition = ZPOSITION_INACTIVE_PIECE
            pieces[i][6] = p
            addChild(p)
        }
        
        // Rooks
        let r1 = Rook(side: Piece.Side.WHITE)
        r1.position = positionOnBoard(7, y: 0)
        addChild(r1)
        let r2 = Rook(side: Piece.Side.WHITE)
        r2.position = positionOnBoard(0, y: 0)
        addChild(r2)
        let r3 = Rook(side: Piece.Side.BLACK)
        r3.position = positionOnBoard(7, y: 7)
        addChild(r3)
        let r4 = Rook(side: Piece.Side.BLACK)
        r4.position = positionOnBoard(0, y: 7)
        addChild(r4)
    }
    
    func pointToSpace(pt: CGPoint) -> (Int, Int) {
        let x = (Int)((pt.x - SPACE_WIDTH/2) / SPACE_WIDTH)
        let y = (Int)((pt.y - SPACE_WIDTH/2) / SPACE_WIDTH)
        return (x, y)
    }
    
    func positionOnBoard(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: x * 100 + 50, y: y * 100 + 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
