//
//  Piece.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Piece: SKSpriteNode {
   
    var side: Side
    var type: Type
    var boardSpace: (Int, Int)
    
    enum Type {
        case KING
        case QUEEN
        case ROOK
        case KNIGHT
        case BISHOP
        case PAWN
    }
    
    enum Side {
        case WHITE
        case BLACK
    }
    
    init(side: Side, type: Type, space: (Int, Int), texture: SKTexture) {
        self.side = side
        self.type = type
        self.boardSpace = space
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.zPosition = ZPOSITION_INACTIVE_PIECE
    }
    
    func setSpace(x: Int, y: Int) {
        position = CGPoint(x: CGFloat(x) * SPACE_WIDTH + HALF_SPACE_WIDTH,
                           y: CGFloat(y) * SPACE_WIDTH + HALF_SPACE_WIDTH)
        boardSpace = (x, y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boardIndex() -> Int {
        return (7 - boardSpace.1) * 16 + boardSpace.0
    }

}
